variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket."
}

variable "principal_type" {
  type        = string
  description = "Bucket policy principal type."
}

variable "principal_identifiers" {
  type        = list(string)
  description = "Bucket policy principal identifiers."
}
