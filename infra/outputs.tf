output "instance_id" { value = aws_instance.demo.id }
output "public_ip"   { value = aws_instance.demo.public_ip }

output "bucket_name" { value = aws_s3_bucket.site.bucket }
output "website_url" { value = "http://${aws_s3_bucket.site.bucket}.s3-website-${var.aws_region}.amazonaws.com" }