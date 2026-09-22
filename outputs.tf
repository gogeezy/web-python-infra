output "app_vm_external_ip" {
  description = "Public IP address of application VM"
  value       = yandex_compute_instance.app_vm.network_interface[0].nat_ip_address
}

output "app_vm_internal_ip" {
  description = "Internal IP address of application VM"
  value       = yandex_compute_instance.app_vm.network_interface[0].ip_address
}

output "application_url" {
  description = "Application URL"
  value       = "http://${yandex_compute_instance.app_vm.network_interface[0].nat_ip_address}:8080"
}
