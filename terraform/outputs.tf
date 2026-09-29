output "artifact_bucket_name" {
  description = "Name of the Terraform-managed S3 bucket"
  value       = aws_s3_bucket.artifacts.bucket
}