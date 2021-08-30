resource "aws_key_pair" "my-key" {
  key_name   = "devops14_2021"
  public_key = file("${path.module}/mini_key.txt")
  
}

resource "aws_instance" "devops14_2021" {
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my-key.key_name
  tags = {
   "Name" = element(var.tags,0)
  }
}


resource "aws_security_group" "devops14_2021" {
  name = "devops14_2021"
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    #iterator = port
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}


resource "aws_eip" "devops14_2021" {
 vpc = true
 tags = {
   Name  = "my_eip"
   Owner = "Sugdiyona"
 }
}

resource "aws_eip_association" "my_eip_to_ec2" {
 instance_id = aws_instance.devops14_2021.id
 allocation_id = aws_eip.devops14_2021.id
 
}
resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.devops14_2021.id
  network_interface_id = aws_instance.devops14_2021.primary_network_interface_id
}

output "eip" {
  value = aws_eip.devops14_2021.public_ip
}


