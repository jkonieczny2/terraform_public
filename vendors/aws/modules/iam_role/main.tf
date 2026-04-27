data "aws_iam_policy_document" "assume_role" {
    statement {
        actions = ["sts:AssumeRole"]

        dynamic "principals" {
            for_each = toset(var.principals)

            content {
                type = principals.value.type
                identifiers = principals.value.identifiers
            }
        }
    }
}

data "aws_iam_policy_document" "resources" {
    dynamic "statement" {
        for_each = toset(var.policies)

        content {
            actions = statement.value.actions
            resources = statement.value.resources
        }
    }
}

resource "aws_iam_role" "main" {
    name = var.name
    description = var.description
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "resources" {
    count = ( length(var.policies) > 0 ) ? 1 : 0

    name = "${var.name}_resources"
    role = aws_iam_role.main.name
    policy = data.aws_iam_policy_document.resources.json
}

resource "aws_iam_role_policy_attachment" "main" {
    count = length(var.managed_policy_attachments)

    role = aws_iam_role.main.name
    policy_arn = var.managed_policy_attachments[count.index]
}
