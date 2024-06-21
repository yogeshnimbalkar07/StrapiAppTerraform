provider "aws" {
  region = var.aws_region
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = var.key_name
  public_key = file("${abspath(path.cwd)}/my-key.pub")
}

resource "aws_instance" "strapi_instance" {
  ami           = "ami-0f58b397bc5c1f2e8" 
  instance_type = var.instance_type
  key_name      = aws_key_pair.my_key_pair.key_name

  tags = {
    Name = "StrapiServer1"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update and install required packages
              sudo apt-get update

              #cmd for install node
              curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash 

              #for shell
              . ~/.nvm/nvm.sh

              #to install node 
              nvm install node

              #update dependencies
              sudo apt-get update

              nvm install 18

              # Install PM2 process manager
              sudo npm install -g pm2

              # Download and install Strapi
              mkdir /srv/strapi
              cd /srv/strapi

              #create strapi app by command
              npx create-strapi-app@latest my-project3 --quickstart

        
              # Start Strapi in production mode
              cd my-project3
              sudo npm run develop
              sudo npm run start

              EOF

  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "echo '${aws_instance.strapi_instance.public_ip}' > ip_address.txt"
  }
}

output "instance_public_ip" {
  value = aws_instance.strapi_instance.public_ip
}

