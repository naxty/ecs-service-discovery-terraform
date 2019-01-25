variable "environment" {
  description = "The environment"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "availability_zones" {
  type = "list"
  description = "The azs to use"
}

variable "security_groups_ids" {
  type = "list"
  description = "The SGs to use"
}

variable "subnets_ids" {
  type = "list"
  description = "The private subnets to use"
}

variable "public_image" {
  description = "Image name in ecr of fargate_image"
}

variable "private_image" {
  description = "Image name in ecr of fargate_image"
}


variable "private_service_count" {
  default = "0"
}

variable "region" {
  description = "AWS region"
}
variable "discovery_registry_arn" {}
