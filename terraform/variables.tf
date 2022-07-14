variable "aws_region" {
  type = string
  description = "Specified AWS Region"
  default = "us-east-1"
}

variable "aws_credentials_profile" {
  type = string
  description = "AWS Profile with the required access"
}

variable "aws_sns_phone_number" {
  type = string
  description = "Valid mobile phone for notifications"
}