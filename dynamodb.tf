resource "aws_dynamodb_table" "dynamodb_table" {
  name             = "report-table"
  billing_mode     = "PROVISIONED"
  write_capacity   = 32
  read_capacity    = 32
  hash_key         = "Id"
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"

  attribute {
    name = "Id"
    type = "S"
  }
  /*
  attribute {
    name = "file-url"
    type = "S"
  }
  attribute {
    name = "status"
    type = "N" #0:false/1:true
  }*/
}