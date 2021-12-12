data "archive_file" "lambda-trigger" {
  type        = "zip"
  source_file = "${path.module}/lambda/trigger_action.py"
  output_path = "${path.module}/lambda/myzip/trigger_action.zip"
}

# Create a lambda function
# In terraform ${path.module} is the current directory.
resource "aws_lambda_function" "lambda_trigger_fct" {
  filename         = "${path.module}/lambda/myzip/trigger_action.zip"
  function_name    = "trigger_by_dynamodb_stream"
  role             = aws_iam_role.lambda_role_trigger_action.arn
  handler          = "trigger_action.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.lambda-trigger.output_base64sha256
    environment {
    variables = {
      dynamodb_table      = "${aws_dynamodb_table.dynamodb_table.name}"
      report_bucket_id    = "${aws_s3_bucket.fired_and_forget_project.id}"
    }
  }
}

#create an event source mapping so that this lambda gets triggered when DynamoDB stream has data in it
resource "aws_lambda_event_source_mapping" "event_stream" {
  event_source_arn  = aws_dynamodb_table.dynamodb_table.stream_arn
  function_name     = aws_lambda_function.lambda_trigger_fct.arn
  starting_position = "LATEST"
}
