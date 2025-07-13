
resource "aws_ssm_maintenance_window" "start_rds_cluster" {
  name              = "StartRDSCluster"
  schedule          = "cron(0 7 ? * MON-FRI *)"
  duration          = 1
  cutoff            = 0
  schedule_timezone = "Brazil/East"
}

resource "aws_ssm_maintenance_window_target" "start_rds_cluster" {
  window_id     = aws_ssm_maintenance_window.start_rds_cluster.id
  resource_type = "RESOURCE_GROUP"

  targets {
    key    = "resource-groups:ResourceTypeFilters"
    values = ["AWS::RDS::DBCluster"]
  }

  targets {
    key    = "resource-groups:Name"
    values = ["MaintenanceWindowRDSClusters"]
  }
}

resource "aws_ssm_maintenance_window_task" "start_rds_cluster" {
  max_concurrency  = "100%"
  max_errors       = "100%"
  priority         = 1
  task_arn         = "AWS-StartStopAuroraCluster"
  task_type        = "AUTOMATION"
  window_id        = aws_ssm_maintenance_window.start_rds_cluster.id
  service_role_arn = aws_iam_role.maintenance_window_service.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.start_rds_cluster.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "ClusterName"
        values = ["{{RESOURCE_ID}}"]
      }

      parameter {
        name   = "Action"
        values = ["Start"]
      }

      parameter {
        name   = "AutomationAssumeRole"
        values = [aws_iam_role.start_stop_aurora_cluster_task.arn]
      }
    }
  }
}

resource "aws_ssm_maintenance_window" "stop_rds_cluster" {
  name              = "StopRDSCluster"
  schedule          = "cron(0 19 ? * MON-FRI *)"
  duration          = 1
  cutoff            = 0
  schedule_timezone = "Brazil/East"
}

resource "aws_ssm_maintenance_window_target" "stop_rds_cluster" {
  window_id     = aws_ssm_maintenance_window.stop_rds_cluster.id
  resource_type = "RESOURCE_GROUP"

  targets {
    key    = "resource-groups:ResourceTypeFilters"
    values = ["AWS::RDS::DBCluster"]
  }

  targets {
    key    = "resource-groups:Name"
    values = ["MaintenanceWindowRDSClusters"]
  }
}

resource "aws_ssm_maintenance_window_task" "stop_rds_cluster" {
  max_concurrency  = "100%"
  max_errors       = "100%"
  priority         = 1
  task_arn         = "AWS-StartStopAuroraCluster"
  task_type        = "AUTOMATION"
  window_id        = aws_ssm_maintenance_window.stop_rds_cluster.id
  service_role_arn = aws_iam_role.maintenance_window_service.arn

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.stop_rds_cluster.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$LATEST"

      parameter {
        name   = "ClusterName"
        values = ["{{RESOURCE_ID}}"]
      }

      parameter {
        name   = "Action"
        values = ["Stop"]
      }

      parameter {
        name   = "AutomationAssumeRole"
        values = [aws_iam_role.start_stop_aurora_cluster_task.arn]
      }
    }
  }
}
