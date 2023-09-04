variable "project" {}
variable "region" {}


locals {
  defaultTags = {
    project = var.project
  }

  lambda_file_source = "${path.root}/../Projects/lambda_functions"
  build_file_source  = "${path.root}/../Projects/build_files"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.defaultTags
  }
}
