data "aws_region" "current" {}

data "aws_secretsmanager_secret" "aws_default_keypair_pub" {
  name = var.secretsmanager_default_keypair_pub_name
}

data "aws_secretsmanager_secret_version" "aws_default_keypair_pub" {
  secret_id = data.aws_secretsmanager_secret.aws_default_keypair_pub.id
}

data "aws_secretsmanager_secret" "aws_default_keypair" {
  name = var.secretsmanager_default_keypair_name
}

data "aws_secretsmanager_secret_version" "aws_default_keypair" {
  secret_id = data.aws_secretsmanager_secret.aws_default_keypair.id
}

resource "aws_instance" "main" {
  ami                         = var.ami
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  private_ip                  = var.private_ip
  placement_group             = var.placement_group_id
  iam_instance_profile        = var.iam_instance_profile

  root_block_device {
    volume_size = var.root_block_size
    volume_type = var.root_block_volume_type != null ? var.root_block_volume_type : null
    throughput  = var.root_block_volume_type == "gp3" ? var.root_block_device_throughput : null
  }

  # allow e.g. Salt to ssh as root
  provisioner "remote-exec" {
    inline = [
      "echo ${data.aws_secretsmanager_secret_version.aws_default_keypair_pub.secret_string} | sudo tee /root/.ssh/authorized_keys"
    ]

    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = var.initial_user
      private_key = data.aws_secretsmanager_secret_version.aws_default_keypair.secret_string
    }
  }

  tags = {
    Name = var.name
  }
}

resource "aws_eip" "main" {
  count = var.eip_count

  ipam_pool_id = var.ipam_pool != null ? var.ipam_pool : null
}

resource "aws_eip_association" "main" {
  count = var.eip_count

  instance_id   = aws_instance.main.id
  allocation_id = aws_eip.main[count.index].id
}

resource "aws_ebs_volume" "main" {
  count = var.ebs_block_size == null ? 0 : 1

  availability_zone = var.availability_zone
  type              = var.ebs_volume_type
  size              = var.ebs_block_size
  iops              = contains(["io1", "io2", "gp3"], var.ebs_volume_type) ? var.ebs_volume_iops : null
  throughput        = contains(["gp3"], var.ebs_volume_type) ? var.ebs_volume_throughput : null
  final_snapshot    = var.snapshot_on_delete
}

resource "aws_volume_attachment" "main" {
  count = var.ebs_block_size == null ? 0 : 1

  device_name = var.ebs_volume_device_name
  volume_id   = aws_ebs_volume.main[count.index].id
  instance_id = aws_instance.main.id

  provisioner "remote-exec" {
    script = "${path.module}/scripts/mount.sh"

    connection {
      type        = "ssh"
      host        = var.eip_count == 0 ? aws_instance.main.public_ip : aws_eip.main[0].public_ip
      user        = "root"
      private_key = data.aws_secretsmanager_secret_version.aws_default_keypair.secret_string
    }
  }
}
