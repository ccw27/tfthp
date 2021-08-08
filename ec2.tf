//Public Instance
resource "aws_instance" "PublicInstance" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = "${aws_key_pair.sshkey.key_name}"
  subnet_id     = "${aws_subnet.publicSubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.PublicSecurityGroup.id}"]
  tags = {
    Name = "PublicInstance"
  }
  user_data = "${file("user_data.sh")}"
}


//Security Group
// For Public
resource "aws_security_group" "PublicSecurityGroup" {
  name        = "PublicSecurityGroup"
  description = "allows ssh and http"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on = [ aws_vpc.VPC ]

  tags = {
    Name = "PublicSecurityGroup"
  }
}

// For Private
resource "aws_security_group" "PrivateSecurityGroup" {
  name        = "PrivateSecurityGroup"
  description = "Allow only Mysql"
  vpc_id      = aws_vpc.VPC.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.privateSubnet.cidr_block}"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_subnet.privateSubnet.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }  

  depends_on = [
    aws_vpc.VPC,
    aws_security_group.PublicSecurityGroup,
  ]

  tags = {
    Name = "PrivateSecurityGroup"
  }
}
