variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "ap-southeast-2"
}

variable "project" {
  type = string
  description = "Project name"
  default = "connect-chat"
}

variable "tags" {
    type = map(string)
    description = "tags to be used "
    default = {
      "project" = "connect-chat",
      "env" = "prod",
    
    }
  
}