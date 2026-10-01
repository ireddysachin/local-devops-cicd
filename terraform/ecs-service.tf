resource "aws_ecs_service" "app_service" {
  name            = "local-devops-service"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  desired_count   = 1
}