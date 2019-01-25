resource "aws_cloudwatch_log_group" "ecs_service_logs" {
  name = "ecs_service_logs"

  tags {
    Environment = "${var.environment}"
  }
}
resource "aws_ecs_cluster" "cluster" {
  name = "${var.environment}-ecs-cluster"
}

data "template_file" "public_task_service" {
  template = "${file("${path.module}/tasks/public_task_definition.json")}"

  vars {
    public_image = "${var.public_image}"
    region = "${var.region}"
    log_group = "${aws_cloudwatch_log_group.ecs_service_logs.name}"

  }
}

data "template_file" "private_task_service" {
  template = "${file("${path.module}/tasks/private_task_definition.json")}"

  vars {
    private_image = "${var.private_image}"
    region = "${var.region}"
    log_group = "${aws_cloudwatch_log_group.ecs_service_logs.name}"

  }
}

resource "aws_ecs_task_definition" "public_service" {
  family = "${var.environment}_public"
  container_definitions = "${data.template_file.public_task_service.rendered}"
  requires_compatibilities = [
    "FARGATE"]
  network_mode = "awsvpc"
  cpu = "1024"
  memory = "4096"
  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn = "${aws_iam_role.ecs_execution_role.arn}"

}

resource "aws_ecs_task_definition" "private_service" {
  family = "${var.environment}_private"
  container_definitions = "${data.template_file.private_task_service.rendered}"
  requires_compatibilities = [
    "FARGATE"]
  network_mode = "awsvpc"
  cpu = "1024"
  memory = "4096"
  execution_role_arn = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn = "${aws_iam_role.ecs_execution_role.arn}"

}

resource "aws_iam_role_policy" "ecs_policy" {
  name = "ecs_execution_role_policy"
  policy = "${file("${path.module}/policies/ecs-policy.json")}"
  role = "${aws_iam_role.ecs_execution_role.id}"
}


resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = "${file("${path.module}/policies/ecs-job-service-execution-role.json")}"
}

resource "aws_security_group" "ecs_public_service" {
  vpc_id = "${var.vpc_id}"
  name = "${var.environment}-ecs-service-sg"
  description = "Allow egress from container"


  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags {
    Name = "${var.environment}-ecs-service-sg"
    Environment = "${var.environment}"
  }
}

data "aws_ecs_task_definition" "public_service" {
  task_definition = "${aws_ecs_task_definition.public_service.family}"
  depends_on = [
    "aws_ecs_task_definition.public_service"]
}

data "aws_ecs_task_definition" "private_service" {
  task_definition = "${aws_ecs_task_definition.private_service.family}"
  depends_on = [
    "aws_ecs_task_definition.private_service"]
}

resource "aws_ecs_service" "public_service" {
  name = "${var.environment}-public_service"
  task_definition = "${aws_ecs_task_definition.public_service.family}:${max("${aws_ecs_task_definition.public_service.revision}", "${data.aws_ecs_task_definition.public_service.revision}")}"
  desired_count = "1"
  launch_type = "FARGATE"
  cluster = "${aws_ecs_cluster.cluster.id}"

  network_configuration {
    security_groups = [
      "${aws_security_group.ecs_public_service.id}"]
    subnets = [
      "${var.subnets_ids}"]
    assign_public_ip =true
  }

}

resource "aws_ecs_service" "private_service" {
  name = "${var.environment}-private_service"
  task_definition = "${aws_ecs_task_definition.private_service.family}:${max("${aws_ecs_task_definition.private_service.revision}", "${data.aws_ecs_task_definition.private_service.revision}")}"
  desired_count = "${var.private_service_count}"
  launch_type = "FARGATE"
  cluster = "${aws_ecs_cluster.cluster.id}"

  network_configuration {
    security_groups = [
      "${var.security_groups_ids}",
      "${aws_security_group.ecs_public_service.id}"]
    subnets = [
      "${var.subnets_ids}"]
    assign_public_ip =true
  }

  service_registries {
    registry_arn = "${var.discovery_registry_arn}"
  }
}
