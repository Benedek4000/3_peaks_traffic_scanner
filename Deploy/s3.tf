module "s3_results" {
  source = "./modules/s3_bucket"

  bucket_name           = var.project
  principal_type        = "Service"
  principal_identifiers = ["lambda.amazonaws.com"]
}
