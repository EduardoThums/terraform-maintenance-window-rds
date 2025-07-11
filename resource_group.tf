resource "aws_resourcegroups_group" "rds_clusters" {
  name = "MaintenanceWindowRDSClusters"

  resource_query {
    query = jsonencode({
      "ResourceTypeFilters" : [
        "AWS::RDS::DBCluster"
      ],
      "TagFilters" : [
        {
          "Key" : "maintenance-window",
          "Values" : ["enabled"]
        }
      ]
    })
  }
}
