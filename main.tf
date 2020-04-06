module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  namespace  = var.namespace
  stage      = var.stage
  name       = var.name
  delimiter  = var.delimiter
  attributes = var.attributes
  tags       = var.tags
}

resource "aws_s3_bucket" "playbooks_bucket" {
  bucket        = "${module.label.id}-playbooks"
  acl           = "private"
  tags          = module.label.tags
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "ssm_logs_bucket" {
  bucket        = "${module.label.id}-ssm-logs"
  acl           = "private"
  tags          = module.label.tags
  force_destroy = var.force_destroy
}

data "aws_iam_policy_document" "ssm_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ssm_instance_role" {
  name               = "${module.label.id}-ssm-playbook-instance-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role_policy.json
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "${module.label.id}-ssm-playbook-instance-profile"
  role = aws_iam_role.ssm_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ssm_core_access" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "ssm_playbook_access_policy" {
  name   = "${module.label.id}-playbook-access"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "SSMPlaybookAccess",
  "Statement": [
    {
      "Sid": "AllowAccess",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.playbooks_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.playbooks_bucket.id}/*",
        "arn:aws:s3:::${aws_s3_bucket.ssm_logs_bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.ssm_logs_bucket.id}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "playbook_access" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = aws_iam_policy.ssm_playbook_access_policy.arn
}