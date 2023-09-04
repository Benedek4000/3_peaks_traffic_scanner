variable "source_path" {
  type        = string
  description = "The path that includes the source file."
}

variable "source_file" {
  type        = string
  description = "The source file for the lambda function."
}

variable "build_files" {
  type        = string
  description = "The build file source."
}

variable "region" {
  type        = string
  description = "Region of the instance server."
}

variable "role_arn" {
  type        = string
  description = "The ARN of the role the lambda function will assume."
}

variable "project" {
  type        = string
  description = "The name of the project."
}

variable "schedule_arn" {
  type        = string
  description = "ARN of the Cloudwatch Schedule to run the function."
}
