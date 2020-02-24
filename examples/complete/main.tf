variable "region" {
  default = "cn-hangzhou"
}

provider "alicloud" {
  region = var.region
}

#############################################################
# Data sources to get VPC and vswitch details
#############################################################

data "alicloud_vpcs" "default" {
  is_default = true
}

data "alicloud_vswitches" "default" {
  ids = [data.alicloud_vpcs.default.vpcs.0.vswitch_ids[0]]
}

data "alicloud_instances" "default" {
  vpc_id = data.alicloud_vpcs.default.ids.0
}
#############################################################
# Using module to create a new nat gateway and bind two eip
#############################################################
module "nat" {
  source = "terraform-alicloud-modules/nat-gateway/alicloud"
  region = var.region

  name   = "nat-foo"
  vpc_id = data.alicloud_vpcs.default.ids.0
  create = true

  // create eips and bind them with nat
  create_eip    = true
  number_of_eip = 4
  eip_name      = "for-snat"
}

################################################
# Snat entries with complete set of arguments
################################################
module "complete" {
  source = "../../"
  region = var.region

  create        = true
  snat_table_id = module.nat.this_snat_table_id

  # Default snat ip, which will be used for all snat entries.
  snat_ips = module.nat.this_eip_ips

  # Open to CIDRs blocks
  snat_with_source_cidrs = [
    {
      name         = "source-cidrs-for"
      source_cidrs = join(",", [cidrsubnet(data.alicloud_vswitches.default.vswitches.0.cidr_block, 8, 10), cidrsubnet(data.alicloud_vswitches.default.vswitches.0.cidr_block, 8, 11)])
      snat_ip      = module.nat.this_eip_ips[0]
    },
    {
      name         = "source-cidrs-bar"
      source_cidrs = cidrsubnet(data.alicloud_vswitches.default.vswitches.0.cidr_block, 8, 12)
      snat_ip      = module.nat.this_eip_ips[1]
    }
  ]

  # Open for vswitch ids
  snat_with_vswitch_ids = [
    {
      vswitch_ids = join(",", data.alicloud_vpcs.default.vpcs.0.vswitch_ids)
      snat_ip     = module.nat.this_eip_ips[2]
    }
  ]

  # Open for ecs instance ids
  snat_with_instance_ids = [
    {
      name         = "form-ecs"
      instance_ids = join(",", data.alicloud_instances.default.ids)
      snat_ip      = module.nat.this_eip_ips[3]
    }
  ]
}
