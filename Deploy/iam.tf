locals {
  lambdaRolePredefinedPolicies = [
    "AmazonDynamoDBFullAccess"
  ]
}

module "lambda-role" {
  source = "./modules/role"

  roleName             = "${var.project}-lambda-role"
  principalType        = "Service"
  principalIdentifiers = ["lambda.amazonaws.com"]
  predefinedPolicies   = local.lambdaRolePredefinedPolicies
}
