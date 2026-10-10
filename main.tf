resource "aws_fsx_openzfs_file_system" "fsx_openzfs_file_systems" {
  for_each = var.fsx_openzfs_file_systems

  deployment_type                   = each.value.deployment_type
  subnet_ids                        = each.value.subnet_ids
  throughput_capacity               = each.value.throughput_capacity
  tags                              = each.value.tags
  storage_type                      = each.value.storage_type
  storage_capacity                  = each.value.storage_capacity
  skip_final_backup                 = each.value.skip_final_backup
  security_group_ids                = each.value.security_group_ids
  route_table_ids                   = each.value.route_table_ids
  region                            = each.value.region
  preferred_subnet_id               = each.value.preferred_subnet_id
  final_backup_tags                 = each.value.final_backup_tags
  tags_all                          = each.value.tags_all
  endpoint_ip_address_range         = each.value.endpoint_ip_address_range
  delete_options                    = each.value.delete_options
  daily_automatic_backup_start_time = each.value.daily_automatic_backup_start_time
  copy_tags_to_volumes              = each.value.copy_tags_to_volumes
  copy_tags_to_backups              = each.value.copy_tags_to_backups
  backup_id                         = each.value.backup_id
  automatic_backup_retention_days   = each.value.automatic_backup_retention_days
  kms_key_id                        = each.value.kms_key_id
  weekly_maintenance_start_time     = each.value.weekly_maintenance_start_time

  dynamic "disk_iops_configuration" {
    for_each = each.value.disk_iops_configuration != null ? [each.value.disk_iops_configuration] : []
    content {
      iops = disk_iops_configuration.value.iops
      mode = disk_iops_configuration.value.mode
    }
  }

  dynamic "read_cache_configuration" {
    for_each = each.value.read_cache_configuration != null ? [each.value.read_cache_configuration] : []
    content {
      size        = read_cache_configuration.value.size
      sizing_mode = read_cache_configuration.value.sizing_mode
    }
  }

  dynamic "root_volume_configuration" {
    for_each = each.value.root_volume_configuration != null ? [each.value.root_volume_configuration] : []
    content {
      copy_tags_to_snapshots = root_volume_configuration.value.copy_tags_to_snapshots
      data_compression_type  = root_volume_configuration.value.data_compression_type
      dynamic "nfs_exports" {
        for_each = root_volume_configuration.value.nfs_exports != null ? [root_volume_configuration.value.nfs_exports] : []
        content {
          dynamic "client_configurations" {
            for_each = nfs_exports.value.client_configurations
            content {
              clients = client_configurations.value.clients
              options = client_configurations.value.options
            }
          }
        }
      }
      read_only       = root_volume_configuration.value.read_only
      record_size_kib = root_volume_configuration.value.record_size_kib
      dynamic "user_and_group_quotas" {
        for_each = root_volume_configuration.value.user_and_group_quotas != null ? root_volume_configuration.value.user_and_group_quotas : []
        content {
          id                         = user_and_group_quotas.value.id
          storage_capacity_quota_gib = user_and_group_quotas.value.storage_capacity_quota_gib
          type                       = user_and_group_quotas.value.type
        }
      }
    }
  }
}

