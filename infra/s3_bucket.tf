# define the bucket name
data "aws_caller_identity" "account_info" {}

locals { bucket_name = "${var.project}-${data.aws_caller_identity.account_info.account_id}-site-live" }  # must be globally unique

#create a s3 bucket resource called site and name provide a name
resource "aws_s3_bucket" "site" {
  bucket = local.bucket_name
  tags   = var.tags
}

# this block is to enable the s3 bucket to behave as a static website
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  index_document { suffix = "index.html" }
  error_document { key    = "error.html" }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_read" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.public_read.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  bucket = aws_s3_bucket.site.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.site.id
  key          = "index.html"
  source       = "${path.module}/../static-site/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../static-site/index.html")
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.site.id
  key          = "error.html"
  source       = "${path.module}/../static-site/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../static-site/error.html")
}