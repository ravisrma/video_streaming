terraform {
  backend "s3" {
    bucket         = "video-streaming-08"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}