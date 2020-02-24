terraform-alicloud-snat
=======================

本 Module 用于在阿里云的 Nat 网关下批量添加[Snat条目](https://www.alibabacloud.com/help/zh/doc-detail/65183.htm)。
SNAT功能可以为专有网络中无公网IP的ECS实例提供访问互联网的代理服务。

本 Module 支持创建以下资源:

* [snat_entry](https://www.terraform.io/docs/providers/alicloud/r/snat.html)

## Terraform 版本

如果您正在使用 Terraform 0.12，Provider的版本 1.71.1+。

## 用法

指定已知的 cidr block, vswitch ids 和 ecs instance ids

```hcl
// 使用datasource获取存量的资源
data "alicloud_vpcs" "default" {
  is_default = true
}

data "alicloud_vswitches" "default" {
  ids = [data.alicloud_vpcs.default.vpcs.0.vswitch_ids[0]]
}

data "alicloud_instances" "default" {
  vpc_id = data.alicloud_vpcs.default.ids.0
}

// 创建一个新的网关
module "nat" {
  source = "terraform-alicloud-modules/nat-gateway/alicloud"
  region = var.region
  # ... omitted
}

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
```

支持设置待创建的资源
```hcl
// 创建vpc和vswitch
module "vpc" {
  source = "alibaba/vpc/alicloud"
  region = var.region
  # ... omitted
}
// 创建ecs 实例
module "ecs-instance" {
  source = "alibaba/ecs-instance/alicloud"
  region = var.region
  # ... omitted
}
// 创建一个新的nat 网关
module "nat" {
  source = "terraform-alicloud-modules/nat-gateway/alicloud"
  region = var.region
  # ... omitted
}

module "computed" {
  source = "terraform-alicloud-modules/snat/alicloud"
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
```

## 示例

* [完整使用示例](https://github.com/terraform-alicloud-modules/terraform-alicloud-snat/tree/master/examples/complete) 展示所有可配置的参数。
* [待创建资源的示例](https://github.com/terraform-alicloud-modules/terraform-alicloud-snat/tree/master/examples/computed) 展示配置哪些待创建资源的参数，用于解决`value of 'count' cannot be computed`的问题。

提交问题
-------
如果在使用该 Terraform Module 的过程中有任何问题，可以直接创建一个 [Provider Issue](https://github.com/terraform-providers/terraform-provider-alicloud/issues/new)，我们将根据问题描述提供解决方案。

**注意:** 不建议在该 Module 仓库中直接提交 Issue。

作者
-------
Created and maintained by He Guimin(@xiaozhu36 heguimin36@163.com)

参考
---------
* [Terraform-Provider-Alicloud Github](https://github.com/terraform-providers/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://www.terraform.io/docs/providers/alicloud/index.html)

