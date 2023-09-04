terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

data "aws_iam_policy_document" "s3-full-access" {
  statement {
    principals {
      type        = var.principal_type
      identifiers = var.principal_identifiers
    }

    actions = [
      "s3:*",
    ]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    effect  = "Deny"
    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.s3-full-access.json
}

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.bucket_name
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.bucket]
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "versioning-bucket-config" {
  depends_on = [aws_s3_bucket_versioning.bucket_versioning]

  bucket = aws_s3_bucket.bucket.id

  rule {
    id = "config"

    noncurrent_version_expiration {
      newer_noncurrent_versions = 7
      noncurrent_days           = 7
    }

    status = "Enabled"
  }
}
