# -----------------------------------
# Lake Formation
# -----------------------------------
resource "aws_lakeformation_resource" "lakeformation" {
  arn = aws_s3_bucket.private_admin.arn
}
# Sets Admins for the Data Lake Settings
resource "aws_lakeformation_data_lake_settings" "settings" {
  admins = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AdminRole"
  ]
}
/*
# S3やデータカタログ等に対する権限を設定
resource "aws_lakeformation_permissions" "db_permission" {
}
*/