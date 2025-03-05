# -----------------------------------
# IAM
# -----------------------------------
resource "aws_iam_role" "glue_service_role" {
  name = "glue_service_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "glue_service_role_attach" {
  role       = aws_iam_role.glue_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
/*
resource "aws_iam_policy_attachment" "glue_lambda_exe" {
  name       = "AWSLambda_FullAccess"
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  roles      = ["${aws_iam_role.role_glue.name}"]
}
*/
resource "aws_iam_role_policy" "role_policy_glue" {
  name = "role_policy_glue"
  role = aws_iam_role.glue_service_role.id

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "glue:*",
                "s3:GetBucketLocation",
                "s3:ListBucket",
                "s3:ListAllMyBuckets",
                "s3:GetBucketAcl"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::private-admin-bucket-20250215/*",
                "arn:aws:s3:::private-admin-bucket-20250215"
            ]
        }
    ]
}
  EOF
}
# athena
resource "aws_s3_bucket_policy" "athena_query_results" {
  bucket = "private-admin-bucket-20250215"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AthenaQueryResultsWrite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "athena.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::private-admin-bucket-20250215/athena_result/*"
      },
      {
        "Sid" : "AthenaGetBucketLocation",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "athena.amazonaws.com"
        },
        "Action" : "s3:GetBucketLocation",
        "Resource" : "arn:aws:s3:::private-admin-bucket-20250215"
      },
      {
        "Sid" : "AthenaListBucket",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "athena.amazonaws.com"
        },
        "Action" : "s3:ListBucket",
        "Resource" : "arn:aws:s3:::private-admin-bucket-20250215",
        "Condition" : {
          "StringLike" : {
            "s3:prefix" : "athena_result/*"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role" "lakeformation_admin" {
  name = "LakeFormationAdmin"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "lakeformation_admin_policy" {
  role       = aws_iam_role.lakeformation_admin.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLakeFormationDataAdmin"
}