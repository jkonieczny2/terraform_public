resource "aws_kms_key" "main" {
    description = var.description
    enable_key_rotation = var.enable_key_rotation
    rotation_period_in_days = var.rotation_period_in_days
    deletion_window_in_days = var.deletion_window_in_days
    policy = var.policy
}
