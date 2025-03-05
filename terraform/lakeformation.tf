# -----------------------------------
# Lake Formation
# -----------------------------------
resource "aws_lakeformation_resource" "lakeformation" {
  arn = aws_s3_bucket.private_admin.arn
}
# Sets Admins for the Data Lake Settings
resource "aws_lakeformation_data_lake_settings" "settings" {
  admins = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.admin_username}"
  ]
}
resource "aws_lakeformation_data_cells_filter" "user_id_filter" {
  table_data {
    database_name    = aws_glue_catalog_database.catalog.name
    name             = "user_id_filter"
    table_catalog_id = data.aws_caller_identity.current.account_id
    table_name       = "loaded_data"
    column_names     = ["col0"]
    row_filter {
      filter_expression = "col0 < 51"
    }
  }
}
/*
# S3やデータカタログ等に対する権限を設定
resource "aws_lakeformation_permissions" "db_permission" {
}
*/