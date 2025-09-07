#!/bin/bash
# Video Streaming App Artifact Deployment Script (for CI)
# Packages Lambdas, updates frontend config, uploads frontend to S3 using outputs.json

set -e

APP_NAME="VideoStreamingApp"
AWS_REGION="ap-south-1"
TERRAFORM_DIR="terraform"
OUTPUTS_FILE="$TERRAFORM_DIR/outputs.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

get_terraform_output() {
    local output_name=$1
    jq -r ".${output_name}.value" "$OUTPUTS_FILE"
}

package_lambda() {
    local function_name=$1
    local source_file=$2
    local output_dir="lambda-packages"
    local current_dir=$(pwd)
    local zip_file="${current_dir}/${output_dir}/${function_name}.zip"
    print_status "Packaging Lambda function: $function_name" >&2
    if [ ! -f "backend/${source_file}" ]; then
        print_error "Source file does not exist: backend/${source_file}" >&2
        exit 1
    fi
    mkdir -p $output_dir
    local temp_dir=$(mktemp -d)
    cp "backend/${source_file}" "${temp_dir}/lambda_function.py"
    if [ -f "backend/requirements.txt" ]; then
        print_status "Installing dependencies for $function_name..." >&2
        local pip_cmd="pip"
        if command -v pip3 &> /dev/null; then
            pip_cmd="pip3"
        fi
        $pip_cmd install -r backend/requirements.txt -t $temp_dir --quiet --no-deps --upgrade
        find $temp_dir -name "*.pyc" -delete
        find $temp_dir -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
        find $temp_dir -name "*.dist-info" -type d -exec rm -rf {} + 2>/dev/null || true
        find $temp_dir -name "tests" -type d -exec rm -rf {} + 2>/dev/null || true
    fi
    cd $temp_dir
    zip -r "$zip_file" . -q
    local zip_exit_code=$?
    cd "$current_dir"
    if [ $zip_exit_code -ne 0 ]; then
        print_error "Failed to create zip file for $function_name" >&2
        rm -rf $temp_dir
        exit 1
    fi
    if [ ! -f "$zip_file" ]; then
        print_error "Zip file was not created: $zip_file" >&2
        rm -rf $temp_dir
        exit 1
    fi
    rm -rf $temp_dir
    print_success "Created package: $zip_file" >&2
    local file_size=$(ls -lh "$zip_file" | awk '{print $5}')
    print_status "Package size: $file_size" >&2
    echo "$zip_file"
}

upload_lambda_package() {
    local zip_file=$1
    local function_name=$(basename $zip_file .zip)
    local s3_key="lambda-packages/${function_name}.zip"
    local lambda_bucket=$(get_terraform_output "lambda_deployment_bucket_name")
    print_status "Uploading $zip_file to S3..."
    if [ ! -f "$zip_file" ]; then
        print_error "Zip file does not exist: $zip_file"
        exit 1
    fi
    print_status "Zip file details: $(ls -lh "$zip_file")"
    if ! aws s3 ls "s3://$lambda_bucket" --region $AWS_REGION >/dev/null 2>&1; then
        print_error "Lambda deployment bucket does not exist: $lambda_bucket"
        exit 1
    fi
    if aws s3 cp "$zip_file" "s3://$lambda_bucket/$s3_key" --region $AWS_REGION; then
        print_success "Successfully uploaded $zip_file"
        echo $s3_key
    else
        print_error "Failed to upload $zip_file to s3://$lambda_bucket/$s3_key"
        exit 1
    fi
}

package_and_upload_lambdas() {
    print_status "Packaging and uploading Lambda functions..."
    local video_processor_zip=$(package_lambda "video-processor" "video_processor.py")
    local video_streamer_zip=$(package_lambda "video-streamer" "video_streamer.py")
    local video_lister_zip=$(package_lambda "video-lister" "video_lister.py")
    local completion_handler_zip=$(package_lambda "mediaconvert-completion-handler" "mediaconvert_completion_handler.py")
    upload_lambda_package "$video_processor_zip"
    upload_lambda_package "$video_streamer_zip"
    upload_lambda_package "$video_lister_zip"
    upload_lambda_package "$completion_handler_zip"
    print_success "All Lambda functions packaged and uploaded"
    rm -rf lambda-packages
}

update_frontend_config() {
    print_status "Updating frontend configuration with Terraform outputs..."
    USER_POOL_ID=$(get_terraform_output "user_pool_id")
    USER_POOL_CLIENT_ID=$(get_terraform_output "user_pool_client_id")
    IDENTITY_POOL_ID=$(get_terraform_output "identity_pool_id")
    API_URL=$(get_terraform_output "apigateway_url")
    CLOUDFRONT_DOMAIN=$(get_terraform_output "cloudfront_domain_name")
    CONTENT_BUCKET=$(get_terraform_output "content_bucket_name")
    WEB_BUCKET=$(get_terraform_output "web_bucket_name")
    if [[ ! -f "frontend/config.js" ]]; then
        print_error "Frontend configuration file not found: frontend/config.js"
        exit 1
    fi
    cp frontend/config.js frontend/config.js.backup
    sed -i.tmp "s/region: '[^']*'/region: '${AWS_REGION}'/g" frontend/config.js
    sed -i.tmp "s/userPoolId: '[^']*'/userPoolId: '${USER_POOL_ID}'/g" frontend/config.js
    sed -i.tmp "s/userPoolWebClientId: '[^']*'/userPoolWebClientId: '${USER_POOL_CLIENT_ID}'/g" frontend/config.js
    sed -i.tmp "s/identityPoolId: '[^']*'/identityPoolId: '${IDENTITY_POOL_ID}'/g" frontend/config.js
    sed -i.tmp "s|baseUrl: '[^']*'|baseUrl: '${API_URL}'|g" frontend/config.js
    sed -i.tmp "s/domain: '[^']*'/domain: '${CLOUDFRONT_DOMAIN}'/g" frontend/config.js
    sed -i.tmp "s/contentBucket: '[^']*'/contentBucket: '${CONTENT_BUCKET}'/g" frontend/config.js
    sed -i.tmp "s|https://[^/]*/thumbnails/|https://${CLOUDFRONT_DOMAIN}/thumbnails/|g" frontend/config.js
    rm -f frontend/config.js.tmp
    print_success "Frontend configuration updated with Terraform outputs"
    export WEB_BUCKET_NAME="$WEB_BUCKET"
}

upload_frontend_to_s3() {
    print_status "Uploading frontend files to S3..."
    if [[ -z "$WEB_BUCKET_NAME" ]]; then
        print_error "Web bucket name not found. Cannot upload frontend files."
        exit 1
    fi
    TEMP_DIR=$(mktemp -d)
    cp -r frontend/* "$TEMP_DIR/"
    aws s3 cp "$TEMP_DIR/index.html" "s3://$WEB_BUCKET_NAME/" --content-type "text/html" --region $AWS_REGION
    for css_file in styles.css toast.css; do
        if [[ -f "$TEMP_DIR/$css_file" ]]; then
            aws s3 cp "$TEMP_DIR/$css_file" "s3://$WEB_BUCKET_NAME/" --content-type "text/css" --region $AWS_REGION
        fi
    done
    for js_file in utils.js config.js auth.js player.js app.js video-list.js; do
        if [[ -f "$TEMP_DIR/$js_file" ]]; then
            aws s3 cp "$TEMP_DIR/$js_file" "s3://$WEB_BUCKET_NAME/" --content-type "application/javascript" --region $AWS_REGION
        fi
    done
    for svg_file in *.svg; do
        if [[ -f "$TEMP_DIR/$svg_file" ]]; then
            aws s3 cp "$TEMP_DIR/$svg_file" "s3://$WEB_BUCKET_NAME/" --content-type "image/svg+xml" --region $AWS_REGION
        fi
    done
    for file in "$TEMP_DIR"/*; do
        filename=$(basename "$file")
        if [[ "$filename" != "index.html" && "$filename" != *.css && "$filename" != *.js && "$filename" != *.svg ]]; then
            aws s3 cp "$file" "s3://$WEB_BUCKET_NAME/" --region $AWS_REGION
        fi
    done
    rm -rf "$TEMP_DIR"
    print_success "Frontend files uploaded to S3 bucket: $WEB_BUCKET_NAME"
}

display_deployment_summary() {
    print_success "=== DEPLOYMENT SUMMARY ==="
    echo
    USER_POOL_ID=$(get_terraform_output "user_pool_id")
    API_URL=$(get_terraform_output "apigateway_url")
    CLOUDFRONT_DOMAIN=$(get_terraform_output "cloudfront_domain_name")
    WEB_BUCKET=$(get_terraform_output "web_bucket_name")
    UPLOAD_BUCKET=$(get_terraform_output "upload_bucket_name")
    CONTENT_BUCKET=$(get_terraform_output "content_bucket_name")
    echo -e "${GREEN}Frontend Application:${NC}"
    echo -e "  Website URL: ${BLUE}https://$CLOUDFRONT_DOMAIN${NC}"
    echo -e "  CloudFront Distribution: ${BLUE}https://$CLOUDFRONT_DOMAIN${NC}"
    echo
    echo -e "${GREEN}AWS Resources:${NC}"
    echo -e "  User Pool ID: ${BLUE}$USER_POOL_ID${NC}"
    echo -e "  API Gateway URL: ${BLUE}$API_URL${NC}"
    echo -e "  Upload Bucket: ${BLUE}$UPLOAD_BUCKET${NC}"
    echo -e "  Content Bucket: ${BLUE}$CONTENT_BUCKET${NC}"
    echo -e "  Web Bucket: ${BLUE}$WEB_BUCKET${NC}"
    echo
    echo -e "${GREEN}Next Steps:${NC}"
    echo -e "  1. Upload test videos to: ${BLUE}s3://$UPLOAD_BUCKET/${NC}"
    echo -e "  2. Wait for MediaConvert processing to complete"
    echo -e "  3. Access the application at: ${BLUE}https://$CLOUDFRONT_DOMAIN${NC}"
    echo -e "  4. Create user accounts and test different subscription types"
    echo
    echo -e "${YELLOW}Manual Upload Instructions:${NC}"
    echo -e "  aws s3 cp your-video.mp4 s3://$UPLOAD_BUCKET/"
    echo
}

main() {
    print_status "Starting artifact deployment of Video Streaming App (post-Terraform)..."
    print_status "App Name: $APP_NAME"
    print_status "AWS Region: $AWS_REGION"
    echo
    package_and_upload_lambdas
    echo
    update_frontend_config
    echo
    upload_frontend_to_s3
    echo
    display_deployment_summary
    print_success "Deployment completed successfully!"
}

case "${1:-deploy}" in
    deploy)
        main
        ;;
    frontend)
        update_frontend_config
        upload_frontend_to_s3
        ;;
    *)
        echo "Usage: $0 {deploy|frontend}"
        echo "  deploy   - Package/upload Lambdas, update/upload frontend (default)"
        echo "  frontend - Update/upload frontend files only"
        exit 1
        ;;
esac
