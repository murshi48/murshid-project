provider "aws" {
  region = "ap-south-1"  # Change this to your preferred region
}

# Reference an existing security group by its ID
data "aws_security_group" "existing_sg" {
  id = "sg-0f53b7b301c580d75"  # Replace with your existing security group ID
}

# Fetch subnets (assuming you have this data block to fetch subnets)
data "aws_subnets" "custom_subnets" {
  filter {
    name   = "tag:Name"
    values = ["doraproject-subnet-public1-ap-south-1a"]  # Modify this to match your subnet tags
  }
}

# Create EC2 instance and install Docker using a user data script
resource "aws_instance" "docker_instance" {
  ami           = "ami-07b69f62c1d38b012"  # Replace with the latest Ubuntu AMI ID for your region
  instance_type = "t2.micro"               # Change the instance type if needed
  key_name      = "AWS-murshid"                   # Replace with your actual key name
  security_groups = [data.aws_security_group.existing_sg.id]

  # Choose the first subnet from the fetched subnets
  subnet_id = data.aws_subnets.custom_subnets.ids[0]  # Choose the first subnet ID

  # User data to install Docker automatically
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras enable docker
              yum install -y docker
              service docker start
              usermod -aG docker ec2-user
              EOF

  # Associate public IP address
  associate_public_ip_address = true

  # Add tags to the instance
  tags = {
    Name = "Docker EC2 Instance"
  }
}

# Output the public IP of the EC2 instance after it is created
output "instance_public_ip" {
  value = aws_instance.docker_instance.public_ip
}

