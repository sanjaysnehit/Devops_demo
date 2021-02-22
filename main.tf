provider "aws" {
  access_key = "AKIAJWI2QLZ5RQSQHUTA"
  secret_key = "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"
  region = "us-east-2"
}

resource "aws_vpc" "New-vpc" {
  cidr_block       = "10.0.0.0/18"
  instance_tenancy = "default"
  tags = {
    Name = "New-vpc"  
  }
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.New-vpc.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "Public Subnet"
  }
}


resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.New-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Private Subnet"
  }
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.New-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "NAT Gateway EIP"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "Main NAT Gateway"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.New-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.New-vpc.id

  tags = {
    Name = "Main IGW"
  }
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.New-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.New-vpc.cidr_block]
  }

 ingress {
    description = "TLS from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.New-vpc.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}


