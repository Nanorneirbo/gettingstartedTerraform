

variable "port" {
  description = "port number"
  type = number
  default = 8080
}

resource "aws_instance" "example" {
  ami = "ami-0eff4f2497a2ce392"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF


  tags = {
    Name = "nanos-instance"
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
