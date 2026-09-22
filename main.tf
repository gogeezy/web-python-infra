data "yandex_vpc_network" "app_network" {
  network_id = "enppp2ucirlhm5jr5nq5"
}

resource "yandex_vpc_subnet" "app_subnet" {
  name           = "tf-app-subnet"
  zone           = var.zone
  network_id     = data.yandex_vpc_network.app_network.id
  v4_cidr_blocks = ["10.20.1.0/24"]
}

resource "yandex_vpc_security_group" "app_sg" {
  name       = "tf-app-sg"
  network_id = data.yandex_vpc_network.app_network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }

  ingress {
    protocol       = "TCP"
    description    = "Application"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  egress {
    protocol       = "ANY"
    description    = "Allow outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2404-lts-oslogin"
}

resource "yandex_compute_instance" "app_vm" {
  name        = "tf-app-vm"
  hostname    = "tf-app-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 12
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.app_subnet.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.app_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/cloud-init.yaml", {
      ssh_public_key = file(pathexpand(var.ssh_public_key_path))
    })
  }
}
