resource "aws_dynamodb_table" "results" {
  name         = var.project
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "RouteAndTime"

  attribute {
    name = "RouteAndTime"
    type = "S"
  }
}
