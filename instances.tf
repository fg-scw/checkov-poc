resource "scaleway_instance_ip" "web_public" {
  zone = var.zone
  tags = concat([var.project_name, "web", var.environment], var.tags)
}

resource "scaleway_account_ssh_key" "this" {
  name       = "${var.project_name}-key"
  public_key = var.ssh_public_key
}

resource "scaleway_instance_server" "web_server" {
  name              = "${var.project_name}-web-01"
  type              = "PLAY2-PICO"
  image             = "ubuntu_jammy"
  zone              = var.zone
  ip_id             = scaleway_instance_ip.web_public.id
  security_group_id = scaleway_instance_security_group.web_public.id
  tags              = concat([var.project_name, "web", var.environment], var.tags)

  private_network {
    pn_id = scaleway_vpc_private_network.app_network.id
  }

  root_volume {
    size_in_gb = 20
  }

  cloud_init = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    users:
      - name: admin
        groups: sudo
        lock_passwd: true
        shell: /bin/bash
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ${var.ssh_public_key}
    runcmd:
      - ufw allow 80/tcp
      - ufw allow 443/tcp
      - ufw --force enable
  EOF
}
