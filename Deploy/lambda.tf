module "lambda_functions" {
  source = "./modules/lambda_function"

  for_each = toset(["checkTraffic"])

  source_path   = local.lambda_file_source
  function_name = each.value
  build_files   = local.build_file_source
  misc_files    = local.misc_file_source
  role_arn      = module.lambda-role.roleArn
  project       = var.project
  region        = var.region
  dynamodb_id   = aws_dynamodb_table.results.id

  schedule_arn = aws_cloudwatch_event_rule.traffic_check.arn
}
