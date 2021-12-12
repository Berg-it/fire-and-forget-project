resource "aws_iam_role" "lambda_role_trigger_action" {
  name               = "lambda_role_trigger_action"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
        "Service": "lambda.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_stream" {
  role       = aws_iam_role.lambda_role_trigger_action.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}

resource "aws_iam_policy" "lambda_dynamod_write_policy" {
  name = "dynamo-policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:UpdateItem"
      ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.dynamodb_table.arn}"
    },
    {
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": ["${aws_s3_bucket.fired_and_forget_project.arn}","${aws_s3_bucket.fired_and_forget_project.arn}/*"]
    }    
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_put" {
  role       = aws_iam_role.lambda_role_trigger_action.name
  policy_arn = aws_iam_policy.lambda_dynamod_write_policy.arn
}


resource "aws_iam_role" "api_gateway_role" {
  name               = "api_gateway_role"
  assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
    {
    "Action": "sts:AssumeRole",
    "Principal": {
        "Service": "apigateway.amazonaws.com"
    },
    "Effect": "Allow",
    "Sid": ""
    }
]
}
EOF
}

resource "aws_iam_policy" "lambda_dynamod_write_policy_api_gateway" {
  name = "lambda_dynamod_write_policy_api_gateway"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": 
    {
      "Action": [
        "dynamodb:PutItem",
        "dynamodb:GetItem"
        ],
      "Effect": "Allow",
      "Resource": "${aws_dynamodb_table.dynamodb_table.arn}"
    }    
  
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_attach_put_api_gateway" {
  role       = aws_iam_role.api_gateway_role.name
  policy_arn = aws_iam_policy.lambda_dynamod_write_policy_api_gateway.arn
}