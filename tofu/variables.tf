variable "libvirt_disk_path" {
  description = "path for libvirt pool"
  default     = "/opt/lab/jackal-lab/vms"
}

variable "images" {
  type = map(string)
  description = "OS image and version map"
  default = {
    "ubuntu_2404": "./images/ubuntu-24.04-server-cloudimg-amd64.img",
    "ubuntu_2204": "./images/ubuntu-22.04-server-cloudimg-amd64.img"
    "debian_12": "./images/debian-12-genericcloud-amd64.qcow2",
    "debian_11": "./images/debian-11-genericcloud-amd64.qcow2",
    "leap_16": "./images/Leap-16.0-Minimal-VM.x86_64-kvm-and-xen.qcow2",
    "leap_156": "./images/openSUSE-Leap-15.6.x86_64-NoCloud.qcow2"
  }
}

variable "box" {
  type = string
  description = "os"
  default = "ubuntu_2404"
}

// post installation
variable "ssh_username" {
  description = "the ssh user to use"
  default     = "hussein"
}

variable "ssh_private_key" {
  description = "the private key to use"
  default     = "~/.ssh/id_rsa"
}

// resources
variable "disk_size_in_bytes" {
  description = "Disk volume for the vm"
  default = "128000000000"
}

variable "memory" {
  description = "Memory assigned for the virtual machine"
  default = "8000"
}

variable "cpus" {
  description = "CPU cores"
  default = 2
}

variable "num_nodes" {
  description = "Number of virtual machines to be created"
  default = 1
}