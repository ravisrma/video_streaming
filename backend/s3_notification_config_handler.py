def lambda_handler(event, context):
    """
    Lambda function to handle S3 event notifications for video processing
    This function will be triggered by S3 events such as object creation
    and will initiate the necessary processing for the uploaded video files.
    """
    import json
    import boto3
    import os

    # Initialize AWS clients
    mediaconvert = boto3.client('mediaconvert')
    s3 = boto3.client('s3')

    # Get environment variables
    mediaconvert_role = os.environ.get('MEDIACONVERT_ROLE')
    mediaconvert_endpoint = os.environ.get('MEDIACONVERT_ENDPOINT')
    output_bucket = os.environ.get('OUTPUT_BUCKET')

    def start_mediaconvert_job(s3_bucket, s3_key):
        """
        Start a MediaConvert job for the uploaded video file
        """
        job_settings = {
            'Role': mediaconvert_role,
            'Settings': {
                'OutputGroups': [
                    {
                        'Name': 'File Group',
                        'Outputs': [
                            {
                                'ContainerSettings': {
                                    'Container': 'MP4'
                                },
                                'VideoDescription': {
                                    'CodecSettings': {
                                        'Codec': 'H.264'
                                    }
                                }
                            }
                        ]
                    }
                ],
                'Inputs': [
                    {
                        'FileInput': f's3://{s3_bucket}/{s3_key}'
                    }
                ]
            }
        }

        response = mediaconvert.create_job(**job_settings)
        print(f"Started MediaConvert job: {response['Job']['Id']}")

    # Process the S3 event
    try:
        for record in event['Records']:
            s3_bucket = record['s3']['bucket']['name']
            s3_key = record['s3']['object']['key']
            print(f"Processing file: s3://{s3_bucket}/{s3_key}")

            # Start MediaConvert job
            start_mediaconvert_job(s3_bucket, s3_key)

        return {
            'statusCode': 200,
            'body': json.dumps('Processing completed successfully')
        }

    except Exception as e:
        print(f"Error processing S3 event: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }