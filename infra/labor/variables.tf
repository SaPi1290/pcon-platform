variable "admin_ssh_public_key" {
  description = "Öffentlicher SSH-Schlüssel des Pcon-Admins (persönlicher Zugang)."
  type        = string
}

variable "ci_ssh_public_key" {
  description = "Öffentlicher SSH-Schlüssel der Pipeline (Ansible)."
  type        = string
}

variable "server_type" {
  description = "Hetzner-Servertyp der Labor-Control-Plane. 4 vCPU / 8 GB reichen für Gitea, Zabbix, step-ca und Pcon-API."
  type        = string
  default     = "cx33"
}

variable "location" {
  description = "Hetzner-Standort in Deutschland (fsn1 = Falkenstein, nbg1 = Nürnberg)."
  type        = string
  default     = "nbg1"
}
