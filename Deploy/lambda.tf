module "lambda_functions" {
  source = "./modules/lambda_function"

  for_each = toset(fileset("${local.lambda_file_source}", "**.*"))

  source_path = local.lambda_file_source
  source_file = each.value
  build_files = local.build_file_source
  role_arn    = module.lambda-role.roleArn
  project     = var.project
  region      = var.region

  schedule_arn = aws_cloudwatch_event_rule.traffic_check.arn
}
