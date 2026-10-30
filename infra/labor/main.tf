locals {
  name = "pcon-labor-rz"
  labels = {
    env  = "labor"
    role = "control-plane"
  }
}

resource "hcloud_ssh_key" "admin" {
  name       = "pcon-admin"
  public_key = var.admin_ssh_public_key
}

resource "hcloud_ssh_key" "ci" {
  name       = "pcon-ci"
  public_key = var.ci_ssh_public_key
}

# Hetzner-Firewall vor dem Server. Zusätzlich läuft nftables auf dem Host.
# SSH ist vorerst offen (nur Schlüssel, kein Root-Login), weil die Pipeline
# von wechselnden GitHub-IPs zugreift. Wird nach Aufbau von WireGuard eingeschränkt.
resource "hcloud_firewall" "rz" {
  name   = local.name
  labels = local.labels

  rule {
    description = "SSH (nur Schlüssel)"
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTP (nur für Zertifikatsausstellung)"
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "HTTPS (Kanal 1, Boxen)"
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "WireGuard (Kanal 2, Admin)"
    direction   = "in"
    protocol    = "udp"
    port        = "51820"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description = "Ping"
    direction   = "in"
    protocol    = "icmp"
    source_ips  = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "rz" {
  name         = local.name
  server_type  = var.server_type
  image        = "debian-13"
  location     = var.location
  labels       = local.labels
  ssh_keys     = [hcloud_ssh_key.admin.id, hcloud_ssh_key.ci.id]
  firewall_ids = [hcloud_firewall.rz.id]
  backups      = true

  delete_protection  = true
  rebuild_protection = true

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  # Legt den Admin-Benutzer "pcon" an und sperrt den Root-Login von Anfang an.
  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    admin_key = var.admin_ssh_public_key
    ci_key    = var.ci_ssh_public_key
  })

  lifecycle {
    # Änderungen an diesen Feldern würden den Server neu erzeugen.
    # Konfiguration nach dem ersten Start übernimmt ausschließlich Ansible.
    ignore_changes = [user_data, ssh_keys, image]
  }
}
