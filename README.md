# Jackal Lab  
*A small set of OpenTofu scripts to create virtual machines in my local lab environment*

---

## Overview
This repository provides a collection of [OpenTofu](https://opentofu.org) scripts used to spin up virtual machines in a local lab setup.  
It’s designed for **experimentation, development, and lab infrastructure** — **not production use**. Use at your own risk!

---

## Prerequisites  
- Opentofu
- Libvirt
- local registry (Optional)

---

## Getting Started  

### Clone the repository  
```bash  
git clone https://github.com/galal-hussein/jackal-lab-pub.git  
cd jackal-lab-pub  
```

### Install Opentofu and Libvirt
On your local machine install open tofu, and on the intended host machine, install libvirt libraries:

```bash
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager

```

In the `main.tf` change the libvirt host address to your machine's address:

```
provider "libvirt" {
  uri = "qemu+tcp://jackal-lab.hgalal.az/system"
}
```

### Setup Local Registry (Optional)

If you use these VMs to run Kubernetes (k3s/rke2) you'll likely pull many container images from Docker Hub. To speed things up and avoid rate limits, run a local registry mirror and configure your clusters to use it.

There is a registry/ directory with related files. Example cloud-init snippet used to write registry mirror configs into VMs:
```
ca-certs:
  trusted:
  - |
   -----BEGIN CERTIFICATE-----
   xxxxxxxxxx
   -----END CERTIFICATE-----
write_files:
  - path: /etc/rancher/rke2/registries.yaml
    content: |
      mirrors:
        docker.io:
          endpoint:
            - "https://registry.hgalal.az"
    owner: 'root:root'
    permissions: '0644'
  - path: /etc/rancher/k3s/registries.yaml
    content: |
      mirrors:
        docker.io:
          endpoint:
            - "https://registry.hgalal.az"
    owner: 'root:root'
    permissions: '0644'
```

### Download the images

The supported base images are declared as variables (example in variables.tf). Download the images and place them in the images/ directory.

Example images variable:

```
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
```

### Run the scripts:

Example to run 5 vms with ubuntu 24.04 image with 8Gigs of Ram and 6 cpu cores:

```
tofu init
tofu apply -var box=ubuntu_2404 -var num_nodes=5 -var memory=8000 -var cpus=6
```


Notes: 

> The scripts expect a bridged interface named br0 to exist on the libvirt host. Make sure it’s configured properly before running the scripts, the registry will also require generating your own certs for the registry in registry/config/ssl dir.

🖥️ Happy Virtualization!