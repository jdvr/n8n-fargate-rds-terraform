resource "aws_iam_policy" "ecs_secret_access" {
  name = "ecs-secret-access"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "secretsmanager:*"
        ],
        "Resource" : [
          "arn:aws:secretsmanager:*:645360192489:secret:*",
          "arn:aws:kms:*:645360192489:key/*"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "secretsmanager:GetRandomPassword",
          "secretsmanager:ListSecrets"
        ],
        "Resource" : "*"
      }
    ]
  })

  tags = var.tags
}

data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "n8n_task_execution_role" {
  name               = "n8n-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
  tags               = var.tags
}

resource "aws_iam_role" "n8n_task_role" {
  name               = "n8n-task-role"
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "n8n_task_execution_role_attach_ecs_task_policy" {
  role       = aws_iam_role.n8n_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "n8n_task_execution_role_attach_ecs_secrets_access" {
  role       = aws_iam_role.n8n_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_secret_access.arn
}
