locals {
  snat_table_id = var.snat_table_id != "" ? var.snat_table_id : var.nat_gateway_id != "" ? concat(data.alicloud_nat_gateways.this.gateways[*].snat_table_id, [""])[0] : ""
}

data "alicloud_nat_gateways" "this" {
  ids = var.nat_gateway_id != "" ? [var.nat_gateway_id] : null
}

################################
# Snat Entries - Maps of entries
################################

# Snat entries with setting "source_cidrs"
locals {
  snat_with_source_cidrs = flatten(
    [
      for _, obj in var.snat_with_source_cidrs : [
        for _, cidr in obj.source_cidrs : {
          name        = obj.name
          source_cidr = cidr
          snat_ip     = obj.snat_ip
        }
      ]
    ]
  )
}

resource "alicloud_snat_entry" "snat_with_source_cidrs" {
  count = var.create ? length(local.snat_with_source_cidrs) : 0

  snat_table_id   = local.snat_table_id
  snat_entry_name = lookup(local.snat_with_source_cidrs[count.index], "name", format("tf-with-cidr%3d", count.index + 1))
  source_cidr     = local.snat_with_source_cidrs[count.index]["source_cidr"]
  snat_ip         = local.snat_with_source_cidrs[count.index]["snat_ip"]
}

# Snat entries with setting "vswitch_ids"
locals {
  snat_with_vswitch_ids = flatten(
    [
      for _, obj in var.snat_with_vswitch_ids : [
        for _, id in obj["vswitch_ids"] : {
          name              = obj.name
          source_vswitch_id = id
          snat_ip           = obj.snat_ip
        }
      ]
    ]
  )
}

resource "alicloud_snat_entry" "snat_with_vswitch_ids" {
  count = var.create ? length(local.snat_with_vswitch_ids) : 0

  snat_table_id     = local.snat_table_id
  snat_entry_name   = lookup(local.snat_with_vswitch_ids[count.index], "name", format("tf-with-id%3d", count.index + 1))
  source_vswitch_id = local.snat_with_vswitch_ids[count.index]["source_vswitch_id"]
  snat_ip           = local.snat_with_vswitch_ids[count.index]["snat_ip"]
}

# Snat entries with setting ecs "instance_ids"
locals {
  ecs_instance_ids = distinct(flatten([
    for _, obj in var.snat_with_instance_ids : [
      obj["instance_ids"]
    ]
    ])
  )

  ecs_instance_map = {
    for instance in data.alicloud_instances.this.instances :
    instance.id => instance.private_ip
  }

  snat_with_instance_ids = flatten(
    [
      for _, obj in var.snat_with_instance_ids : [
        for _, id in obj.instance_ids : {
          name        = obj.name
          source_cidr = length(local.ecs_instance_ids) > 0 ? format("%s/32", local.ecs_instance_map[id]) : ""
          snat_ip     = obj.snat_ip
        }
      ]
    ]
  )
}

data "alicloud_instances" "this" {
  ids = length(local.ecs_instance_ids) > 0 ? local.ecs_instance_ids : null
}

resource "alicloud_snat_entry" "snat_with_instance_ids" {
  count = var.create ? length(local.snat_with_instance_ids) : 0

  snat_table_id   = local.snat_table_id
  snat_entry_name = lookup(local.snat_with_instance_ids[count.index], "name", format("tf-with-instance-id%3d", count.index + 1))
  source_cidr     = local.snat_with_instance_ids[count.index]["source_cidr"]
  snat_ip         = local.snat_with_instance_ids[count.index]["snat_ip"]
}
