resource "aws_iam_policy" "start_stop_aurora_cluster_task" {
  name        = "AWSStartStopAuroraClusterTaskPolicy"
  path        = "/"
  description = "Allow start and stop aurora clusters"

  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "rds:StopDBCluster",
          "rds:StartDBCluster"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:rds:us-east-1:${data.aws_caller_identity.current.account_id}:cluster:*",
        "Condition" : {
          "StringEquals" : { "aws:ResourceTag/maintenance-window" : "enabled" }
        }
        "Sid" : "RdsStartStop"
      },
      {
        "Action" : "rds:DescribeDBClusters",
        "Effect" : "Allow",
        "Resource" : "*",
        "Sid" : "RdsDescribe"
      }
    ],
    "Version" : "2012-10-17"
  })
}


resource "aws_iam_role" "start_stop_aurora_cluster_task" {
  name = "AWSStartStopAuroraClusterTaskRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ssm.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "start_stop_aurora_cluster_task" {
  role       = aws_iam_role.start_stop_aurora_cluster_task.name
  policy_arn = aws_iam_policy.start_stop_aurora_cluster_task.arn
}

resource "aws_iam_policy" "maintenance_window_service" {
  name        = "MaintenanceWindowServicePolicy"
  path        = "/"
  description = "Role used for the SSM Maintenance Window service"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:SendCommand",
          "ssm:CancelCommand",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:GetCommandInvocation",
          "ssm:GetAutomationExecution",
          "ssm:StartAutomationExecution",
          "ssm:ListTagsForResource",
          "ssm:DescribeInstanceInformation",
          "ssm:GetParameters"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "resource-groups:ListGroups",
          "resource-groups:ListGroupResources"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "tag:GetResources"
        ],
        "Resource" : [
          "*"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : "iam:PassRole",
        "Resource" : aws_iam_role.start_stop_aurora_cluster_task.arn
        "Condition" : {
          "StringEquals" : {
            "iam:PassedToService" : [
              "ssm.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_iam_role" "maintenance_window_service" {
  name = "MaintenanceWindowServiceRole"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ssm.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "maintenance_window_service" {
  role       = aws_iam_role.maintenance_window_service.name
  policy_arn = aws_iam_policy.maintenance_window_service.arn
}
