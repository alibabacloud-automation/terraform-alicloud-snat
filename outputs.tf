output "this_snat_entry_id_of_snat_with_source_cidrs" {
  description = "List of ids creating by snat_with_source_cidrs."
  value       = alicloud_snat_entry.snat_with_source_cidrs.*.snat_entry_id
}

output "this_snat_entry_name_of_snat_with_source_cidrs" {
  description = "List of names creating by snat_with_source_cidrs."
  value       = alicloud_snat_entry.snat_with_source_cidrs.*.snat_entry_name
}
output "this_snat_entry_id_of_snat_with_vswitch_ids" {
  description = "List of ids creating by snat_with_vswitch_ids."
  value       = alicloud_snat_entry.snat_with_vswitch_ids.*.snat_entry_id
}

output "this_snat_entry_name_of_snat_with_vswitch_ids" {
  description = "List of names creating by snat_with_vswitch_ids."
  value       = alicloud_snat_entry.snat_with_vswitch_ids.*.snat_entry_name
}
output "this_snat_entry_id_of_snat_with_instance_ids" {
  description = "List of ids creating by snat_with_instance_ids."
  value       = alicloud_snat_entry.snat_with_instance_ids.*.snat_entry_id
}
output "this_snat_entry_name_of_snat_with_instance_ids" {
  description = "List of names creating by snat_with_instance_ids."
  value       = alicloud_snat_entry.snat_with_instance_ids.*.snat_entry_name
}

output "this_snat_entry_id_of_computed_snat_with_source_cidrs" {
  description = "List of ids creating by computed_snat_with_source_cidrs."
  value       = alicloud_snat_entry.computed_snat_with_source_cidrs.*.snat_entry_id
}

output "this_snat_entry_name_of_computed_snat_with_source_cidrs" {
  description = "List of names creating by computed_snat_with_source_cidrs."
  value       = alicloud_snat_entry.computed_snat_with_source_cidrs.*.snat_entry_name
}
output "this_snat_entry_id_of_computed_snat_with_vswitch_ids" {
  description = "List of ids creating by computed_snat_with_vswitch_ids."
  value       = alicloud_snat_entry.computed_snat_with_vswitch_ids.*.snat_entry_id
}
output "this_snat_entry_name_of_computed_snat_with_vswitch_ids" {
  description = "List of names creating by computed_snat_with_vswitch_ids."
  value       = alicloud_snat_entry.computed_snat_with_vswitch_ids.*.snat_entry_name
}

