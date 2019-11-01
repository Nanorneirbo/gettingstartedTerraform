

variable "port" {
  description = "port number"
  type = number
  default = 8080
}
data "aws_vpc" "default"{
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_launch_configuration" "example" {
  image_id = "ami-0eff4f2497a2ce392"
  instance_type = "t2.micro"
  security_group = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_autoscaling_group" "example" {
  max_size = 2
  min_size = 10

  tag {
    key       ="Name"
    value     ="terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.port
    protocol = "tcp"
    to_port = var.port
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}
