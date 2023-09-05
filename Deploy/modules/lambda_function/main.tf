terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

locals {
  runtime = "python3.11"
}

data "template_file" "handler" {
  template = file("${var.source_path}/${var.function_name}/handler.py")
  vars = {
    GOOGLE_API_KEY = file("${var.misc_files}/google_api_key.txt")
    DYNAMODB_ID    = var.dynamodb_id
  }
}

data "archive_file" "lambda_archive" {
  type                    = "zip"
  source_content_filename = "${var.function_name}.py"
  source_content          = data.template_file.handler.rendered
  output_path             = "${var.build_files}/${var.function_name}.zip"
}

resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "pip install -r ${var.source_path}/${var.function_name}/requirements.txt --target ${var.source_path}/${var.function_name}/dependencies/python"
  }
}

data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${var.source_path}/${var.function_name}/dependencies"
  output_path = "${var.build_files}/${var.function_name}_dependencies.zip"

  depends_on = [null_resource.install_dependencies]
}

resource "aws_lambda_layer_version" "lambda_layer" {
  filename   = data.archive_file.lambda_layer.output_path
  layer_name = "${var.function_name}-dependencies"

  compatible_runtimes = [local.runtime]

  source_code_hash = data.archive_file.lambda_layer.output_base64sha256
}

resource "aws_lambda_function" "function" {
  filename      = data.archive_file.lambda_archive.output_path
  function_name = var.function_name
  role          = var.role_arn
  handler       = "${var.function_name}.handler"
  timeout       = 60
  layers        = [aws_lambda_layer_version.lambda_layer.arn]

  runtime = local.runtime

  source_code_hash = data.archive_file.lambda_archive.output_base64sha256
}

resource "aws_lambda_permission" "cloudwatch_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.function.function_name
  principal     = "events.amazonaws.com"

  source_arn = var.schedule_arn
}
