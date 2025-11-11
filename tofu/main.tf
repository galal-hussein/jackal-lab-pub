terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu+tcp://jackal-lab.hgalal.az/system"
}

resource "libvirt_pool" "server_pool" {
  count = var.num_nodes
  name = "${var.box}-${count.index}"
  type = "dir"
  target {
    path = "${var.libvirt_disk_path}/${var.box}-${count.index}"
  }
}

resource "libvirt_volume" "server_base" {
  count = var.num_nodes
  name = "${var.box}-${count.index}.qcow2"
  pool = libvirt_pool.server_pool[count.index].name
  source = var.images[var.box]
  format = "qcow2"
}

resource "libvirt_volume" "server_disk" {
  count = var.num_nodes
  name           = "disk-${count.index}.qcow2"
  size           = var.disk_size_in_bytes
  pool           = libvirt_pool.server_pool[count.index].name
  base_volume_id = libvirt_volume.server_base[count.index].id
}

data "template_file" "user_data" {
  count = var.num_nodes
  template = templatefile("${path.module}/config/cloud_init.yml", {
    hostname = "${var.box}-${count.index}"
  })
}

data "template_file" "network_config" {
  template = file("${path.module}/config/network_config.yml")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  count          = var.num_nodes
  name           = "commoninit-${count.index}.iso"
  user_data      = data.template_file.user_data[count.index].rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.server_pool[count.index].name
}

resource "libvirt_domain" "domain-server" {
  count  = var.num_nodes
  name   = "${var.box}-${count.index}"
  memory = var.memory
  vcpu   = var.cpus
  qemu_agent = true
  cloudinit = libvirt_cloudinit_disk.commoninit[count.index].id
  #firmware = "/usr/share/OVMF/OVMF_CODE.fd"

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    bridge = "br0"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  disk {
    volume_id = libvirt_volume.server_disk[count.index].id
  }

  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }

}
