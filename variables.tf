variable "aws_access_key_id" {
  type = string
}

variable "aws_secret_key" {
  type = string
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "tags" {
  type = map
  description = "tags added to all the created resources"
  default = {
    Application = "n8n"
    TerraformManaged = true
  }
}
