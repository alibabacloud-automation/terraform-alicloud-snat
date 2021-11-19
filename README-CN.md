terraform-alicloud-snat
=======================

本 Module 用于在阿里云的 Nat 网关下批量添加[Snat条目](https://www.alibabacloud.com/help/zh/doc-detail/65183.htm)。
SNAT功能可以为专有网络中无公网IP的ECS实例提供访问互联网的代理服务。

本 Module 支持创建以下资源:

* [snat_entry](https://www.terraform.io/docs/providers/alicloud/r/snat.html)

## Terraform 版本

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.71.1 |

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

支持设置待创建的资源
```hcl
// 创建vpc和vswitch
module "vpc" {
  source = "alibaba/vpc/alicloud"
  # ... omitted
}
// 创建ecs 实例
module "ecs-instance" {
  source = "alibaba/ecs-instance/alicloud"
  # ... omitted
}
// 创建一个新的nat 网关
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

## 示例

* [完整使用示例](https://github.com/terraform-alicloud-modules/terraform-alicloud-snat/tree/master/examples/complete) 展示所有可配置的参数。
* [待创建资源的示例](https://github.com/terraform-alicloud-modules/terraform-alicloud-snat/tree/master/examples/computed) 展示配置哪些待创建资源的参数，用于解决`value of 'count' cannot be computed`的问题。

## 注意事项
本Module从版本v1.0.2开始已经移除掉如下的 provider 的显示设置：
```hcl
provider "alicloud" {
  profile                 = var.profile != "" ? var.profile : null
  shared_credentials_file = var.shared_credentials_file != "" ? var.shared_credentials_file : null
  region                  = var.region != "" ? var.region : null
  skip_region_validation  = var.skip_region_validation
  configuration_source    = "terraform-alicloud-modules/snat"
}
```

如果你依然想在Module中使用这个 provider 配置，你可以在调用Module的时候，指定一个特定的版本，比如 1.0.1:

```hcl
module "snat" {
  configuration_source    = "terraform-alicloud-modules/snat"
  version     = "1.0.1"
  region      = "cn-hangzhou"
  profile     = "Your-Profile-Name"

  create        = true
  snat_table_id = module.nat.this_snat_table_id
  snat_ips      = module.nat.this_eip_ips
}
```
如果你想对正在使用中的Module升级到 1.0.2 或者更高的版本，那么你可以在模板中显示定义一个相同Region的provider：
```hcl
provider "alicloud" {
  region  = "cn-hangzhou"
  profile = "Your-Profile-Name"
}
module "snat" {
  configuration_source    = "terraform-alicloud-modules/snat"
  create        = true
  snat_table_id = module.nat.this_snat_table_id
  snat_ips      = module.nat.this_eip_ips
}
```
或者，如果你是多Region部署，你可以利用 `alias` 定义多个 provider，并在Module中显示指定这个provider：

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

定义完provider之后，运行命令 `terraform init` 和 `terraform apply` 来让这个provider生效即可。

更多provider的使用细节，请移步[How to use provider in the module](https://www.terraform.io/docs/language/modules/develop/providers.html#passing-providers-explicitly)

提交问题
-------
如果在使用该 Terraform Module 的过程中有任何问题，可以直接创建一个 [Provider Issue](https://github.com/terraform-providers/terraform-provider-alicloud/issues/new)，我们将根据问题描述提供解决方案。

**注意:** 不建议在该 Module 仓库中直接提交 Issue。

作者
-------
Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com)

参考
---------
* [Terraform-Provider-Alicloud Github](https://github.com/terraform-providers/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://www.terraform.io/docs/providers/alicloud/index.html)

