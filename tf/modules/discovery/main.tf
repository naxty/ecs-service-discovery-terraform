resource "aws_service_discovery_private_dns_namespace" "private_ns" {
  name = "private_ns"
  description = "Fargate discovery managed zone."
  vpc = "${var.vpc_id}"
}

output "namespace" {
  value = "${aws_service_discovery_private_dns_namespace.private_ns.name}"
}

resource "aws_service_discovery_service" "private_ns_discovery" {
  name = "example"

  dns_config {
    namespace_id = "${aws_service_discovery_private_dns_namespace.private_ns.id}"

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
output "disovery_ns" {
  value = "${aws_service_discovery_service.private_ns_discovery.id}"
}

output "private_ns_discovery_arn" {
  value = "${aws_service_discovery_service.private_ns_discovery.arn}"
}