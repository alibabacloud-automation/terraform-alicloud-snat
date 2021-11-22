#################
# Provider
#################
variable "region" {
  description = "(Deprecated from version 1.1.0)The region used to launch this module resources."
  type        = string
  default     = ""
}

variable "profile" {
  description = "(Deprecated from version 1.1.0)The profile name as set in the shared credentials file. If not set, it will be sourced from the ALICLOUD_PROFILE environment variable."
  type        = string
  default     = ""
}
variable "shared_credentials_file" {
  description = "(Deprecated from version 1.1.0)This is the path to the shared credentials file. If this is not set and a profile is specified, $HOME/.aliyun/config.json will be used."
  type        = string
  default     = ""
}

variable "skip_region_validation" {
  description = "(Deprecated from version 1.1.0)Skip static validation of region ID. Used by users of alternative AlibabaCloud-like APIs or users w/ access to regions that are not public (yet)."
  type        = bool
  default     = false
}

####################
# Common parameters
####################
variable "create" {
  description = "Whether to create snat entries. If true, the 'snat_with_source_cidrs' or 'snat_with_vswitch_ids' or 'snat_with_instance_ids' should be set."
  type        = bool
  default     = true
}
variable "nat_gateway_id" {
  description = "The id of a nat gateway used to fetch the 'snat_table_id'."
  type        = string
  default     = ""
}
variable "snat_table_id" {
  description = "The snat table id to use on all snat entries. If not set, it can be fetched by setting 'nat_gateway_id'."
  type        = string
  default     = ""
}

variable "snat_ips" {
  description = "The public ip addresses to use on all snat entries."
  type        = list(string)
  default     = []
}

#################
# Snat Entries
#################
variable "snat_with_source_cidrs" {
  description = "List of snat entries to create by cidr blocks. Each item valid keys: 'source_cidrs'(required, using comma joinor to set multi cidrs), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type        = list(map(string))
  default     = []
}

variable "snat_with_vswitch_ids" {
  description = "List of snat entries to create by vswitch ids. Each item valid keys: 'vswitch_ids'(required, using comma joinor to set multi vswitch ids), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type        = list(map(string))
  default     = []
}

variable "snat_with_instance_ids" {
  description = "List of snat entries to create by ecs instance ids. Each item valid keys: 'instance_ids'(required, using comma joinor to set multi instance ids), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type        = list(map(string))
  default     = []
}

######################
# Computed Snat Entries
#######################
variable "computed_snat_with_source_cidr" {
  description = "List of computed snat entries to create by cidr blocks. Each item valid keys: 'source_cidr'(required), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type        = list(map(string))
  default     = []
}

variable "computed_snat_with_vswitch_id" {
  description = "List of computed snat entries to create by vswitch ids. Each item valid keys: 'vswitch_id'(required), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type        = list(map(string))
  default     = []
}

