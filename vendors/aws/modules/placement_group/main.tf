resource "aws_placement_group" "main" {
    name = var.name
    strategy = var.strategy

    tags = {
        Description = var.description
    }
}
