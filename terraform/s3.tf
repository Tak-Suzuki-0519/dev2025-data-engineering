# -----------------------------------
# S3
# -----------------------------------
# private bucket for admin use
resource "aws_s3_bucket" "private_admin" {
  bucket = "private-admin-bucket-20250215"
  tags = {
    Name = "private-admin-bucket-20250215"
  }
}
resource "aws_s3_bucket_versioning" "private_admin_versioning" {
  bucket = aws_s3_bucket.private_admin.id
  versioning_configuration {
    status = "Disabled"
  }
}
resource "aws_s3_bucket_public_access_block" "private_admin_ab" {
  bucket                  = aws_s3_bucket.private_admin.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
resource "aws_s3_bucket_ownership_controls" "private_admin_ownership" {
  bucket = aws_s3_bucket.private_admin.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
/*
resource "aws_s3_bucket_acl" "private_admin_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.private_admin_ownership]
  bucket     = aws_s3_bucket.private_admin.id
  acl        = "private"
}
resource "aws_s3_bucket_policy" "private_admin_policy" {
  bucket = aws_s3_bucket.private_admin.id
  policy = data.aws_iam_policy_document.limited_access_only_private_admin.json
}
data "aws_iam_policy_document" "limited_access_only_private_admin" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = # 特定のadminユーザを許可。
    }
    actions = [
      "S3:*",
    ]
    resources = [
      aws_s3_bucket.private_admin.arn,
      "${aws_s3_bucket.private_admin.arn}/*"
    ]
  }
}
*/