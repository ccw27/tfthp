//VPC Creation
resource "aws_vpc" "VPC" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "VPC"
  }
}

//Subnet Creation
//Public subnet
resource "aws_subnet" "publicSubnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = var.az1
  map_public_ip_on_launch = "true"
  depends_on = [aws_vpc.VPC]
  tags = {
    Name = "publicSubnet"
  }
}

//Private subnet
resource "aws_subnet" "privateSubnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.az2
  depends_on = [aws_vpc.VPC]
  tags = {
    Name = "PrivateSubnet"
  }
}

//Internet Gateway for VPC
resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  depends_on = [aws_vpc.VPC]

  tags = {
    Name = "InternetGateway"
  }
}

//Route Table
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }
   depends_on = [aws_vpc.VPC, aws_internet_gateway.InternetGateway]

  tags = {
    Name = "PublicRouteTable"
  }
}

//Associate Route Table with subnet
resource "aws_route_table_association" "PublicAssociation" {
  subnet_id      = aws_subnet.publicSubnet.id
  route_table_id = aws_route_table.PublicRouteTable.id


  depends_on = [
    aws_subnet.publicSubnet ,aws_route_table.PublicRouteTable
  ]
}
