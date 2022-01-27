Terraform Module for creating several SNAT entries for Nat Gateway on  Alibaba Cloud.    
terraform-alicloud-snat
===========================

English | [简体中文](https://github.com/terraform-alicloud-modules/terraform-alicloud-snat/blob/master/README-CN.md)

Terraform module used to create several [SNAT entries](https://www.alibabacloud.com/help/doc-detail/65183.htm) for an existing Nat Gateway on Alibaba Cloud. 
The SNAT function allows ECS instances that are not associated with a public IP address in a VPC to access the Internet.

These types of resources are supported:

* [snat_entry](https://www.terraform.io/docs/providers/alicloud/r/snat.html)

## Terraform versions

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.71.1|

## Usage

Specify the existing cidr block, vswitch ids and ecs instance ids

```hcl
// Fetch the existing resources
data "alicloud_vpcs" "default" {
  is_default = true
}

data "alicloud_vswitches" "default" {
  ids = [data.alicloud_vpcs.default.vpcs.0.vswitch_ids[0]]
}

data "alicloud_instances" "default" {
  vpc_id = data.alicloud_vpcs.default.ids.0
}

// create a new nat gateway
module "nat" {
  source = "terraform-alicloud-modules/nat-gateway/alicloud"
  # ... omitted
}

module "complete" {
  source = "../../"

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
```

Support to set the computed resources
```hcl
// Create vpc and vswitches
module "vpc" {
  source = "alibaba/vpc/alicloud"
  # ... omitted
}
// Create ecs instance
module "ecs-instance" {
  source = "alibaba/ecs-instance/alicloud"
  # ... omitted
}
// Create a new nat gateway
module "nat" {
  source = "terraform-alicloud-modules/nat-gateway/alicloud"
  # ... omitted
}

module "computed" {
  source = "terraform-alicloud-modules/snat/alicloud"

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
```

## Examples

* [Complete example](https://github.com/terraform-alicloud-modules/terraform-alicloud-snat/tree/master/examples/complete) shows all available parameters to configure snat entry.
* [Computed example](https://github.com/terraform-alicloud-modules/terraform-alicloud-snat/tree/master/examples/computed) shows how to specify computed values inside snat entry. (solution for `value of 'count' cannot be computed` problem).

## Notes
From the version v1.1.0, the module has removed the following `provider` setting:

```hcl
provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/snat"
}
```

If you still want to use the `provider` setting to apply this module, you can specify a supported version, like 1.0.1:

```hcl
module "snat" {
  source  = "terraform-alicloud-modules/snat/alicloud"
  version     = "1.0.1"
  region      = "cn-hangzhou"
  profile     = "Your-Profile-Name"
  create        = true
  snat_table_id = module.nat.this_snat_table_id
  snat_ips = module.nat.this_eip_ips
}
```

If you want to upgrade the module to 1.1.0 or higher in-place, you can define a provider which same region with
previous region:

```hcl
provider "alicloud" {
   region  = "cn-hangzhou"
   profile = "Your-Profile-Name"
}
module "snat" {
  source  = "terraform-alicloud-modules/snat/alicloud"
  create        = true
  snat_table_id = module.nat.this_snat_table_id
  snat_ips = module.nat.this_eip_ips
}
```
or specify an alias provider with a defined region to the module using `providers`:

```hcl
provider "alicloud" {
  region  = "cn-hangzhou"
  profile = "Your-Profile-Name"
  alias   = "hz"
}
module "snat" {
  source  = "terraform-alicloud-modules/snat/alicloud"
  providers = {
    alicloud = alicloud.hz
  }
  create        = true
  snat_table_id = module.nat.this_snat_table_id
  snat_ips      = module.nat.this_eip_ips
}
```

and then run `terraform init` and `terraform apply` to make the defined provider effect to the existing module state.
More details see [How to use provider in the module](https://www.terraform.io/docs/language/modules/develop/providers.html#passing-providers-explicitly)

Submit Issues
-------------

If you have any problems when using this module, please opening a [provider issue](https://github.com/terraform-providers/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend to open an issue on this repo.

Authors
-------
Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com)

Reference
---------
* [Terraform-Provider-Alicloud Github](https://github.com/terraform-providers/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://www.terraform.io/docs/providers/alicloud/index.html)