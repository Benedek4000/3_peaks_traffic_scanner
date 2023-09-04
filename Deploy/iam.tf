locals {
  lambdaRolePredefinedPolicies = [
    "AmazonEC2FullAccess",
    "AmazonSSMFullAccess",
    "AmazonS3FullAccess"
  ]
}

module "lambda-role" {
  source = "./modules/role"

  roleName             = "${var.project}-lambda-role"
  principalType        = "Service"
  principalIdentifiers = ["lambda.amazonaws.com"]
  predefinedPolicies   = local.lambdaRolePredefinedPolicies
}
