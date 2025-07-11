# Terraform Maintenance Window for RDS Cluster

Creates two maintenance windows that start and stop multiple RDS Clusters based on the tag "maintenance-window" equals to "enabled" on the clusters.

The clusters are started at 7AM and stopped at 7PM.
