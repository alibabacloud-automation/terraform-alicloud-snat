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

#################
# Snat Entries
#################
variable "snat_with_source_cidrs" {
  description = "List of snat entries to create by cidr blocks. Each item valid keys: 'source_cidrs'(required, using comma joinor to set multi cidrs), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type = list(object({
    name         = optional(string, null)
    source_cidrs = optional(list(string), [])
    snat_ip      = optional(string, null)
  }))
  default = []
}

variable "snat_with_vswitch_ids" {
  description = "List of snat entries to create by vswitch ids. Each item valid keys: 'vswitch_ids'(required, using comma joinor to set multi vswitch ids), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type = list(object({
    name        = optional(string, null)
    vswitch_ids = optional(list(string), [])
    snat_ip     = optional(string, null)
  }))
  default = []
}

variable "snat_with_instance_ids" {
  description = "List of snat entries to create by ecs instance ids. Each item valid keys: 'instance_ids'(required, using comma joinor to set multi instance ids), 'snat_ip'(if not, use root parameter 'snat_ips', using comma joinor to set multi ips), 'name'(if not, will return one automatically)."
  type = list(object({
    name         = optional(string, null)
    instance_ids = optional(list(string), [])
    snat_ip      = optional(string, null)
  }))
  default = []
}
