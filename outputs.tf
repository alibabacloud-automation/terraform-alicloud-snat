output "this_snat_entry_id_of_snat_with_source_cidrs" {
  description = "List of ids creating by snat_with_source_cidrs."
  value       = concat(alicloud_snat_entry.snat_with_source_cidrs.*.snat_entry_id, [""])[0]
}

output "this_snat_entry_name_of_snat_with_source_cidrs" {
  description = "List of names creating by snat_with_source_cidrs."
  value       = concat(alicloud_snat_entry.snat_with_source_cidrs.*.snat_entry_name, [""])[0]
}

output "this_snat_entry_id_of_snat_with_vswitch_ids" {
  description = "List of ids creating by snat_with_vswitch_ids."
  value       = concat(alicloud_snat_entry.snat_with_vswitch_ids.*.snat_entry_id, [""])[0]
}

output "this_snat_entry_name_of_snat_with_vswitch_ids" {
  description = "List of names creating by snat_with_vswitch_ids."
  value       = concat(alicloud_snat_entry.snat_with_vswitch_ids.*.snat_entry_name, [""])[0]
}

output "this_snat_entry_id_of_snat_with_instance_ids" {
  description = "List of ids creating by snat_with_instance_ids."
  value       = concat(alicloud_snat_entry.snat_with_instance_ids.*.snat_entry_id, [""])[0]
}

output "this_snat_entry_name_of_snat_with_instance_ids" {
  description = "List of names creating by snat_with_instance_ids."
  value       = concat(alicloud_snat_entry.snat_with_instance_ids.*.snat_entry_name, [""])[0]
}