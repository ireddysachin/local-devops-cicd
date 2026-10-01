resource "aws_ecs_task_definition" "app_task" {
  family                   = "local-devops-app"
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"

  container_definitions = jsonencode([
    {
      name      = "local-devops-app"
      image     = "localhost:5100/000000000000/us-east-1/local-devops-app:${var.image_tag}"
      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5001
          protocol      = "tcp"
        }
      ]
    }
  ])
}