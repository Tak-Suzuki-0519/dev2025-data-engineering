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
resource "aws_glue_catalog_table" "catalog_table_user" {
  name          = "catalog_table_user"
  database_name = aws_glue_catalog_database.catalog.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL = "TRUE"
    /*
    "parquet.compression" = "SNAPPY"
*/
  }
  partition_keys {
    name = "partition_key"
    type = "string"
  }
  storage_descriptor {
    location      = "s3://private-admin-bucket-20250215/raw_data/user/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "csv_serde_user"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = {
        "separatorChar" = ","
        "quoteChar"     = "\""
      }
    }
    /*
  storage_descriptor {
    location      = "s3://private-admin-bucket-20250215/raw_data/user/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet_serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = 1
      }
    }
*/
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
      name = "gender"
      type = "string"
    }
    columns {
      name = "created_at" # dd-MM-yyyy
      type = "date"
    }
  }
}
resource "aws_glue_catalog_table" "catalog_table_item" {
  name          = "catalog_table_item"
  database_name = aws_glue_catalog_database.catalog.name

  table_type = "EXTERNAL_TABLE"
  parameters = {
    EXTERNAL = "TRUE"
    /*
    "parquet.compression" = "SNAPPY"
*/
  }
  partition_keys {
    name = "partition_key"
    type = "string"
  }
  storage_descriptor {
    location      = "s3://private-admin-bucket-20250215/raw_data/item/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      name                  = "csv_serde_item"
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = {
        "separatorChar" = ","
        "quoteChar"     = "\""
      }
    }
    /*
  storage_descriptor {
    location      = "s3://private-admin-bucket-20250215/raw_data/item/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"

    ser_de_info {
      name                  = "parquet_serde"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = {
        "serialization.format" = 1
      }
    }
*/
    columns {
      name = "item_id"
      type = "int"
    }
    columns {
      name = "item_name"
      type = "string"
    }
    columns {
      name = "user_id"
      type = "int"
    }
    columns {
      name = "transaction_date" # dd-MM-yyyy
      type = "date"
    }
  }
}
resource "aws_glue_crawler" "crawler" {
  database_name = aws_glue_catalog_database.catalog.name
  name          = "crawler"
  role          = aws_iam_role.glue_service_role.arn
  # TODO iceberg_targetの設定を、後で実装するか含め確認

  s3_target {
    path        = "s3://private-admin-bucket-20250215/raw_data/user/"
    sample_size = 10 # the number of files in each leaf folder to be crawled
  }
  s3_target {
    path        = "s3://private-admin-bucket-20250215/raw_data/item/"
    sample_size = 10
  }
}
resource "aws_glue_trigger" "crawler_trigger" {
  name = "crawler_trigger"
  type = "ON_DEMAND"
  actions {
    crawler_name = aws_glue_crawler.crawler.name
  }
}
resource "aws_glue_trigger" "etl_trigger" {
  name = "etl_trigger"
  type = "ON_DEMAND"
  actions {
    job_name = aws_glue_job.glue_job_etl.name
  }
}
resource "aws_glue_job" "glue_job_etl" {
  name     = "glue_job_etl"
  role_arn = aws_iam_role.glue_service_role.arn
  command {
    script_location = "s3://private-admin-bucket-20250215/glue_etl.py"
    python_version  = 3
  }
  glue_version      = "5.0"
  default_arguments = {} # pyファイルで引数を渡さないため、空のまま
}