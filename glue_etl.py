# glue_etl.py
import sys
from awsglue.transforms import *
from pyspark.context import SparkContext
from pyspark.sql.functions import to_date, date_format # 日毎のパーティション化
from awsglue.context import GlueContext
from awsglue.job import Job

args = {}
sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext) # Jobクラスを使用することで、ジョブの開始、終了、エラーハンドリング、ログやメトリクスの収集など、Glueが提供するジョブ管理機能が利用可能
job.init("glue_job_etl", args)

# CSVの読み込み, JOIN
user_dynamic_frame = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": ["s3://private-admin-bucket-20250215/raw_data/user/"]},
    format="csv",
    format_options={"withHeader": True, "separator": ","}
)
user_df = user_dynamic_frame.toDF()
user_df = user_df.toDF("user_id", "first_name", "last_name", "gender", "created_at")

other_dynamic_frame = glueContext.create_dynamic_frame.from_options(
    connection_type="s3",
    connection_options={"paths": ["s3://private-admin-bucket-20250215/raw_data/item/"]},
    format="csv",
    format_options={"withHeader": True, "separator": ","}
)
item_df = other_dynamic_frame.toDF()
item_df = item_df.toDF("item_id", "item_name", "user_id", "transaction_date")

joined_df = user_df.join(item_df, on="user_id", how="inner")

# カラム選択, パーティション化
selected_df = joined_df.select(
    "user_id",
    "gender",
    "item_id",
    "item_name",
    "transaction_date"
)
selected_df_with_partition = selected_df.withColumn(
    "partition_key",
    date_format(to_date("transaction_date", "dd-MM-yyyy"), "yyyyMMdd")
)

# The code below is non-partitioned data. But fine about if the table is defined without partition keys.
selected_df_with_partition.write.partitionBy("partition_key") \
    .mode("overwrite") \
    .csv("s3://private-admin-bucket-20250215/loaded_data/")

job.commit()