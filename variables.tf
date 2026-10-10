variable "fsx_openzfs_file_systems" {
  description = <<EOT
Map of fsx_openzfs_file_systems, attributes below
Required:
    - deployment_type
    - subnet_ids
    - throughput_capacity
Optional:
    - automatic_backup_retention_days
    - backup_id
    - copy_tags_to_backups
    - copy_tags_to_volumes
    - daily_automatic_backup_start_time
    - delete_options
    - endpoint_ip_address_range
    - final_backup_tags
    - kms_key_id
    - preferred_subnet_id
    - region
    - route_table_ids
    - security_group_ids
    - skip_final_backup
    - storage_capacity
    - storage_type
    - tags
    - tags_all
    - weekly_maintenance_start_time
    - disk_iops_configuration (block):
        - iops (optional)
        - mode (optional)
    - read_cache_configuration (block):
        - size (optional)
        - sizing_mode (optional)
    - root_volume_configuration (block):
        - copy_tags_to_snapshots (optional)
        - data_compression_type (optional)
        - nfs_exports (optional, block):
            - client_configurations (required, block):
                - clients (required)
                - options (required)
        - read_only (optional)
        - record_size_kib (optional)
        - user_and_group_quotas (optional, block):
            - id (required)
            - storage_capacity_quota_gib (required)
            - type (required)
EOT

  type = map(object({
    deployment_type                   = string
    subnet_ids                        = list(string)
    throughput_capacity               = number
    tags                              = optional(map(string))
    storage_type                      = optional(string)
    storage_capacity                  = optional(number)
    skip_final_backup                 = optional(bool)
    security_group_ids                = optional(set(string))
    route_table_ids                   = optional(set(string))
    region                            = optional(string)
    preferred_subnet_id               = optional(string)
    final_backup_tags                 = optional(map(string))
    tags_all                          = optional(map(string))
    endpoint_ip_address_range         = optional(string)
    delete_options                    = optional(set(string))
    daily_automatic_backup_start_time = optional(string)
    copy_tags_to_volumes              = optional(bool)
    copy_tags_to_backups              = optional(bool)
    backup_id                         = optional(string)
    automatic_backup_retention_days   = optional(number)
    kms_key_id                        = optional(string)
    weekly_maintenance_start_time     = optional(string)
    disk_iops_configuration = optional(object({
      iops = optional(number)
      mode = optional(string)
    }))
    read_cache_configuration = optional(object({
      size        = optional(number)
      sizing_mode = optional(string)
    }))
    root_volume_configuration = optional(object({
      copy_tags_to_snapshots = optional(bool)
      data_compression_type  = optional(string)
      nfs_exports = optional(object({
        client_configurations = list(object({
          clients = string
          options = list(string)
        }))
      }))
      read_only       = optional(bool)
      record_size_kib = optional(number)
      user_and_group_quotas = optional(list(object({
        id                         = number
        storage_capacity_quota_gib = number
        type                       = string
      })))
    }))
  }))
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.root_volume_configuration == null || (v.root_volume_configuration.nfs_exports == null || (length(v.root_volume_configuration.nfs_exports.client_configurations) >= 1 && length(v.root_volume_configuration.nfs_exports.client_configurations) <= 25))
      )
    ])
    error_message = "Each client_configurations list must contain between 1 and 25 items"
  }
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.automatic_backup_retention_days == null || (v.automatic_backup_retention_days >= 0 && v.automatic_backup_retention_days <= 90)
      )
    ])
    error_message = "must be between 0 and 90"
  }
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.daily_automatic_backup_start_time == null || ((length(v.daily_automatic_backup_start_time) >= 5 && length(v.daily_automatic_backup_start_time) <= 5) && (can(regex("^([01]\\d|2[0-3]):?([0-5]\\d)$", v.daily_automatic_backup_start_time))))
      )
    ])
    error_message = "all of: must be between 5 and 5 characters; must be in the format HH:MM"
  }
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.root_volume_configuration == null || (v.root_volume_configuration.nfs_exports == null || (alltrue([for item in v.root_volume_configuration.nfs_exports.client_configurations : ((length(item.clients) >= 1 && length(item.clients) <= 128) && (can(regex("^[ -~]{1,128}$", item.clients))))])))
      )
    ])
    error_message = "all of: must be between 1 and 128 characters; must be either IP Address or CIDR"
  }
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.root_volume_configuration == null || (v.root_volume_configuration.nfs_exports == null || (alltrue([for item in v.root_volume_configuration.nfs_exports.client_configurations : (alltrue([for x in item.options : length(x) >= 1 && length(x) <= 128]))])))
      )
    ])
    error_message = "must be between 1 and 128 characters"
  }
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.root_volume_configuration == null || (v.root_volume_configuration.record_size_kib == null || (contains([4, 8, 16, 32, 64, 128, 256, 512, 1024], v.root_volume_configuration.record_size_kib)))
      )
    ])
    error_message = "must be one of: 4, 8, 16, 32, 64, 128, 256, 512, 1024"
  }
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.root_volume_configuration == null || (v.root_volume_configuration.user_and_group_quotas == null || alltrue([for item in v.root_volume_configuration.user_and_group_quotas : (item.storage_capacity_quota_gib >= 0 && item.storage_capacity_quota_gib <= 2147483647)]))
      )
    ])
    error_message = "must be between 0 and 2147483647"
  }
  validation {
    condition = alltrue([
      for k, v in var.fsx_openzfs_file_systems : (
        v.weekly_maintenance_start_time == null || ((length(v.weekly_maintenance_start_time) >= 7 && length(v.weekly_maintenance_start_time) <= 7) && (can(regex("^[1-7]:([01]\\d|2[0-3]):?([0-5]\\d)$", v.weekly_maintenance_start_time))))
      )
    ])
    error_message = "all of: must be between 7 and 7 characters; must be in the format d:HH:MM"
  }
  # Note: 11 additional provider-side validators are enforced at apply time but not mirrored as validation{} blocks here (bespoke or non-mechanically-translatable).
}

