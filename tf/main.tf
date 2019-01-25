locals {
  enviroment = "ecs-sample"
}

provider "aws" {
  region = "${var.region}"
}


module "networking" {
  source = "./modules/networking"
  environment = "${local.enviroment}"
  vpc_cidr = "10.0.0.0/16"
  public_subnets_cidr = [
    "10.0.1.0/24"]
  private_subnets_cidr = [
    "10.0.10.0/24"]
  region = "${var.region}"
  availability_zones = "${var.availability_zones}"
}

module "discovery" {
  source = "./modules/discovery"

  vpc_id = "${module.networking.vpc_id}"
}
module "ecs" {
  source = "./modules/ecs"
  region = "${var.region}"

  environment = "${local.enviroment}"
  vpc_id = "${module.networking.vpc_id}"
  availability_zones = "${var.availability_zones}"
  subnets_ids = [
    "${module.networking.public_subnets_id}"]
  security_groups_ids = [
    "${module.networking.security_groups_ids}"
  ]
  private_service_count = 1
  private_image = "${var.ecr_registry}/${var.private_image}"
  public_image = "${var.ecr_registry}/${var.public_image}"
  discovery_registry_arn = "${module.discovery.private_ns_discovery_arn}"
}

