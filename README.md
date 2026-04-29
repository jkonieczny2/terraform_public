# terraform_public

Terraform and related tooling used to provision AWS infrastructure. The layout was
built with Kubernetes-style workloads in mind (placement groups, CSI-friendly
IAM, Elastic IPs from an IPAM pool, and security groups suited to SSH and the
control plane).

---

## Contents

- [Design](#design)
  - [Modules](#modules)
  - [Scripts](#scripts)
- [Terraform CLI reference](#terraform-cli-reference)

---

## Design

### Modules

| Module                 | Purpose |
| ---------------------- | ------- |
| **ec2_instance**       | EC2 instance, EIP, optional EBS attachment, and SSH secrets via Secrets Manager for provisioners. |
| **ec2_instance_profile** | Attaches IAM roles to instances (e.g. Kubernetes CSI drivers that create EBS volumes). |
| **iam_role**           | IAM roles; used with `ec2_instance_profile` for CSI and similar patterns. |
| **kms**                | KMS key handling for encryption and rotation-oriented configuration. |
| **placement_group**    | Placement groups for low-latency node placement (typical for Kubernetes nodes). |
| **s3**                 | S3 bucket definitions. |
| **vpc**                | VPC, subnets, routing, and default security group rules (intra-VPC traffic and admin ingress from a configurable CIDR and ports). |
| **ipam_pool**          | Public IPAM pools so Elastic IPs are allocated from a dedicated, trackable range. |

### Scripts

| Script               | Role |
| -------------------- | ---- |
| `authenticate.py`    | Loads AWS credentials (via Secrets Manager) so local runs such as `terraform apply` can authenticate. |
| `setup.sh`           | Thin wrapper around `authenticate.py` so shell-friendly `eval` of export statements is straightforward. |
| `shutdown.py`        | Stops or starts EC2 instances in configured regions (useful to reduce cost when clusters are idle). |

See [`scripts/README`](scripts/README) for a short note on how `authenticate.py` and `setup.sh` interact.

---

## Terraform CLI reference

### Importing existing resources

```bash
terraform import <tf_resource_id> <aws_id>
```

Examples:

```bash
terraform import module.aws_ebs_csi_driver_role.aws_iam_role.main aws_ebs_csi_driver_role
terraform import module.aws_ebs_csi_driver_role_profile.aws_iam_instance_profile.main aws_ebs_csi_driver_role
```

*(Historical examples used the `tf` command alias in place of `terraform` where that alias exists.)*

---

## Production layout (`vendors/aws/environments/prod`)

Backend and local admin settings are kept out of version control:

- Copy **`backend.s3.tfbackend.example`** → **`backend.s3.tfbackend`** (gitignored) and run  
  `terraform init -backend-config=backend.s3.tfbackend`.
- Copy **`admin.auto.tfvars.example`** → **`admin.auto.tfvars`** (gitignored) for  
  `admin_ingress_cidr_ipv4` and `admin_ingress_tcp_ports`, or set the equivalent  
  `TF_VAR_*` environment variables.

Only the `.example` files are committed; real values stay local.
