// Configure the Google Cloud provider
provider "google" {
 credentials = "${file("~/cool-kit-233420-b8eeb713a6d7.json")}"
 project     = "cool-kit-233420"
 region      = "europe-west2"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

data "google_compute_image" "my_image" {
  project  = "ubuntu-os-cloud"
  family = "ubuntu-1604-lts"
  #licenses = [ "https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx", ]
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "cool-vm-${random_id.instance_id.hex}"
 machine_type = "n1-standard-2"
 zone         = "europe-west2-a"

 boot_disk {
   initialize_params {
     image = "${data.google_compute_image.my_image.self_link}"
   }

 }

 metadata = {
   sshKeys = "leon:${file("~/.ssh/id_rsa.pub")}"
   }

// Make sure flask is installed on all new instances for later steps
# metadata_startup_script = "sudo yum update; sudo yum install -yq build-essential python-pip rsync puppet git; gem install librarian-puppet"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }

 connection {
  host = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
  user = "leon"
  type = "ssh"
  private_key = "${file(var.key_path)}"
  timeout = "1m"
 }

 provisioner "remote-exec" {
  scripts = [
    "bootstrap.sh"
  ]
 }
}


// A variable for extracting the external ip of the instance
output "ip" {
 value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}
