provider "aws" {
  region = "us-east-1"
}

provider "github" {
  token = "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"
  owner = "KauanAmarante"
}

module "atlantis" {
  source  = "terraform-aws-modules/atlantis/aws"
  version = "4.2.0"

  name = "atlantis"

  # ECS Container Definition
  atlantis = {
    environment = [
      {
        name  = "ATLANTIS_GH_USER"
        value = "KauanAmarante"
      },
      {
        name  = "ATLANTIS_REPO_ALLOWLIST"
        value = "github.com/TCC-Kauan/IaC"
      }
    ]
    secrets = [
      {
        name      = "ATLANTIS_GH_TOKEN"
        valueFrom = "arn:aws:secretsmanager:us-east-1:147911601652:secret:ATLANTIS_GH_TOKEN-riv5F4:ATLANTIS_GH_TOKEN::"
      },
      {
        name      = "ATLANTIS_GH_WEBHOOK_SECRET"
        valueFrom = "arn:aws:secretsmanager:us-east-1:147911601652:secret:ATLANTIS_GH_WEBHOOK_SECRET-SjRSww:ATLANTIS_GH_WEBHOOK_SECRET::"
      },
    ]
  }

  # ECS Service
  service = {
    task_exec_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:147911601652:secret:ATLANTIS_GH_TOKEN-riv5F4",
      "arn:aws:secretsmanager:us-east-1:147911601652:secret:ATLANTIS_GH_WEBHOOK_SECRET-SjRSww",
    ]

    tasks_iam_role_policies = {
      AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
    }
  }
  service_subnets = ["subnet-01a8a160d57c72ebb", "subnet-0931fd638a6e75412"]
  vpc_id          = "vpc-0a883f2a76f958861"

  alb_subnets             = ["subnet-03fb35ba2eece89f4", "subnet-0f10a1fbd1e20dfee"]
  certificate_domain_name = "atlantis.kauan.dev"
  route53_zone_id         = "Z02700663JMFE0GRXEOOB"

  tags = {
    Environment = "prod"
    Terraform   = "true"
  }
}
