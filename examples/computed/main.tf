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

data "alicloud_images" "ubuntu" {
  name_regex = "ubuntu_18"
}
#############################################################
# Using module to create vswitch and instances
#############################################################
module "vpc" {
  source = "alibaba/vpc/alicloud"
  region = var.region

  create = true
  vpc_id = data.alicloud_vpcs.default.ids.0

  availability_zones = ["cn-hangzhou-e", "cn-hangzhou-f", "cn-hangzhou-g"]
  vswitch_cidrs      = [cidrsubnet(data.alicloud_vpcs.default.vpcs.0.cidr_block, 8, 8), cidrsubnet(data.alicloud_vpcs.default.vpcs.0.cidr_block, 8, 9), cidrsubnet(data.alicloud_vpcs.default.vpcs.0.cidr_block, 8, 10)]
}
module "group" {
  source = "alibaba/security-group/alicloud"
  region = var.region

  name   = "snat-service"
  vpc_id = data.alicloud_vpcs.default.ids.0
}

module "ecs-instance" {
  source = "alibaba/ecs-instance/alicloud"
  region = var.region

  number_of_instances = 2

  name                        = "my-ecs-cluster"
  use_num_suffix              = true
  instance_type               = "ecs.mn4.small"
  image_id                    = data.alicloud_images.ubuntu.ids.0
  vswitch_ids                 = [module.vpc.this_vswitch_ids.0]
  security_group_ids          = [module.group.this_security_group_id]
  associate_public_ip_address = false

  system_disk_category = "cloud_ssd"
  system_disk_size     = 50
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
module "computed" {
  source = "../../"
  region = var.region

  create        = true
  snat_table_id = module.nat.this_snat_table_id

  # Default snat ip, which will be used for all snat entries.
  snat_ips = module.nat.this_eip_ips

  # Open to computed CIDRs blocks
  computed_snat_with_source_cidr = [
    {
      name        = "vswitch-cidr"
      source_cidr = module.vpc.this_vswitch_cidr_blocks.2
      snat_ip     = module.nat.this_eip_ips[0]
    },
    {
      name        = "ecs-cidr-foo"
      source_cidr = format("%s/32", module.ecs-instance.this_private_ip.0)
      snat_ip     = module.nat.this_eip_ips[1]
    },
    {
      name        = "ecs-cidr-bar"
      source_cidr = format("%s/32", module.ecs-instance.this_private_ip.1)
      snat_ip     = module.nat.this_eip_ips[1]
    }
  ]

  # Open for computed vswitch ids
  computed_snat_with_vswitch_id = [
    {
      name       = "vswitch-id-foo"
      vswitch_id = module.vpc.this_vswitch_ids[0]
      snat_ip    = module.nat.this_eip_ips[2]
    },
    {
      name       = "vswitch-id-bar"
      vswitch_id = module.vpc.this_vswitch_ids[1]
      snat_ip    = module.nat.this_eip_ips[2]
    }
  ]
}