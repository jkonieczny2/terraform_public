resource "aws_iam_instance_profile" "main" {
    name = var.name
    role = var.iam_role_name
}
