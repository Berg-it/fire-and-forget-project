resource "aws_s3_bucket" "fired_and_forget_project" {
  bucket = "fired-and-forget-project"
  acl    = "private"
}