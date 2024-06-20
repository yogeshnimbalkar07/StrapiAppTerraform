provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "strapi1" {
  ami           = "ami-0f58b397bc5c1f2e8" 
  instance_type = var.instance_type
  key_name      = var.key_name

  tags = {
    Name = "StrapiServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update and install required packages
              sudo apt-get update
              sudo apt-get install -y curl

              # Install Node.js and npm
              curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
              sudo apt-get install -y nodejs

              # Install PM2 process manager
              sudo npm install -g pm2

              # Download and install Strapi
              mkdir /srv/strapi
              cd /srv/strapi
              sudo npm install strapi@latest -g

              # Create a new Strapi project
              sudo strapi new my-strapi-project --quickstart

              # Start Strapi in production mode
              cd my-strapi-project
              sudo npm run start

              # Optional: Set up Nginx or another reverse proxy for serving Strapi
              # Ensure to configure security groups and network settings as needed
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

