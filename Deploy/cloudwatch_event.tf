resource "aws_cloudwatch_event_rule" "traffic_check" {
  name                = "${var.project}-traffic-check"
  description         = "Checks the traffic every 15 minutes"
  schedule_expression = "cron(0,15,30,45 * * * ? *)"
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule  = aws_cloudwatch_event_rule.traffic_check.name
  arn   = module.lambda_functions["lambda_checkTraffic.py"].arn
  input = jsonencode({ "message" : "Triggered by CloudWatch Event Rule" })
}
