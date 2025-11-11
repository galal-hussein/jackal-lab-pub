output "instance_ips" {
  value = libvirt_domain.domain-server[*].network_interface[0].addresses[0]
}
