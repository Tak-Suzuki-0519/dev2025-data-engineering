# -----------------------------------
# Athena
# -----------------------------------
resource "aws_athena_database" "athena_glue_etl" {
  name          = "athena_glue_etl"
  bucket        = "private-admin-bucket-20250215/loaded_data/"
  force_destroy = true # true for dev
}
resource "aws_athena_workgroup" "workgroup" {
  name = "workgroup"
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false
    result_configuration {
      output_location = "s3://private-admin-bucket-20250215/athena_result/"
    }
  }
}
data "aws_caller_identity" "current" {}
resource "aws_athena_data_catalog" "glue_catalog" {
  name        = "GlueDataCatalog"
  type        = "GLUE"
  description = "Glue Data Catalog"
  parameters = {
    "catalog-id" = data.aws_caller_identity.current.account_id
  }
}
/*
resource "aws_athena_named_query" "named_query" {
  name        = "named_query"
  workgroup   = aws_athena_workgroup.workgroup.id
  database    = aws_athena_database.athena_glue_etl.name
  query       = data.template_file.sql.rendered
}
data "template_file" "sql" {
  template = file("./src/queries/___.sql")
  vars = {
    athena_database_name = aws_athena_database.athena_glue_etl.name
    athena_table_name    = 
    log_bucket_name      = 
  }
}
*/