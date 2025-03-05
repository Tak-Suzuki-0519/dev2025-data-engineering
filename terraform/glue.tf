# -----------------------------------
# Glue
# -----------------------------------
resource "aws_glue_workflow" "workflow" {
  name = "workflow"
}
resource "aws_glue_catalog_database" "catalog" {
  name = "catalogdatabase"

  /* TODO Lake Formation
  create_table_default_permission {
    permissions = ["SELECT"]

    principal {
      data_lake_principal_identifier = "IAM_ALLOWED_PRINCIPALS"
    }
  }
*/

}
resource "aws_glue_catalog_table" "catalog_table" {
  name          = "catalogtable"
  database_name = aws_glue_catalog_database.catalog.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }
  partition_keys {
    name = "partition_key"
    type = "string"
  }
  storage_descriptor {
    location      = "s3://private-admin-bucket-20250215/raw_data/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet_serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = 1
      }
    }
    columns {
      name = "user_id"
      type = "int"
    }
    columns {
      name = "first_name"
      type = "string"
    }
    columns {
      name = "last_name"
      type = "string"
    }
    columns {
      name    = "gender"
      type    = "int"
      comment = "0 means men. 1 means woman. 2 means other."
    }
    columns {
      name    = "created_at"
      type    = "date"
      comment = "24-hour format"
    }
  }
}
resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.catalog.name
  name          = "crawler"
  role          = aws_iam_role.glue_service_role.arn
  # TODO iceberg_targetの設定を、後で実装するか含め確認

  s3_target {
    path        = "s3://${aws_s3_bucket.private_admin.bucket}/raw_data/"
    sample_size = 10 # the number of files in each leaf folder to be crawled
  }
}
resource "aws_glue_trigger" "raw_data_trigger" {
  name = "raw_data_trigger"
  type = "ON_DEMAND"

  actions {
    crawler_name = aws_glue_crawler.crawler.name
  }
}