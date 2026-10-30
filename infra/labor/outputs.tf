output "rz_ipv4" {
  description = "Öffentliche IPv4-Adresse der Labor-Control-Plane."
  value       = hcloud_server.rz.ipv4_address
}

output "rz_ipv6" {
  description = "Öffentliche IPv6-Adresse der Labor-Control-Plane."
  value       = hcloud_server.rz.ipv6_address
}
