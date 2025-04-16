resource "aws_ecr_repository" "dummy_app" {
  name = "${var.name_prefix}-dummy-app"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.name_prefix}-dummy-app"
    Environment = var.name_prefix
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.dummy_app.repository_url
}  