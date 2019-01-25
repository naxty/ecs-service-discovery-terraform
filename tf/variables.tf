variable "region" {
  description = "region of aws environment"
}
variable "availability_zones" {
  type="list"
}
variable "ecr_registry" {
  description = "url to ecr registry"
}

variable "public_image" {
  description = "public_image"
}
variable "private_image" {
  description = "private_image"
}
