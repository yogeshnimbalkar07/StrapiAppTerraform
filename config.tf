provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "strapi1" {
  ami           = "ami-0f58b397bc5c1f2e8" # Replace with your preferred AMI ID
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "StrapiServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y nodejs npm git
              curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
              sudo apt-get install -y nodejs
              sudo npm install pm2 -g
              sudo mkdir -p /srv/strapi
              sudo chown -R ubuntu:ubuntu /srv/strapi
              git clone https://github.com/yogeshnimbalkar07/StrapiAppTerraform /srv/strapi
              cd /srv/strapi
              npm install
              pm2 start npm --name "strapi" -- start
              EOF

  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "echo '${aws_instance.strapi.public_ip}' > ip_address.txt"
  }
}

output "instance_public_ip" {
  value = aws_instance.strapi.public_ip
}

