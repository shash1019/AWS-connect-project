
output "bucket_name" { value = aws_s3_bucket.site.bucket }
output "website_url" { value = "http://${aws_s3_bucket.site.bucket}.s3-website-${var.aws_region}.amazonaws.com" }