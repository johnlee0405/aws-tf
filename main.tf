provider "aws" {
  region = "ap-northeast-2"
}

### vpc start ###

resource "aws_vpc" "test_vpc" {
  cidr_block  = "192.168.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"

  tags = {
    Name = "test-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "test-pub_2a" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.0.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "test-pub-2a"
  }
}

resource "aws_subnet" "test-pub_2b" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.16.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "test-pub-2b"
  }
}

resource "aws_subnet" "test-pub_2c" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.32.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "test-pub-2c"
  }
}

resource "aws_subnet" "test-pub_2d" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.48.0/20"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "test-pub-2d"
  }
}

resource "aws_subnet" "test-pvt_2a" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.64.0/20"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "test-pvt-2a"
  }
}

resource "aws_subnet" "test-pvt_2b" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.80.0/20"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "test-pvt-2b"
  }
}

resource "aws_subnet" "test-pvt_2c" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.96.0/20"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "test-pvt-2c"
  }
}

resource "aws_subnet" "test-pvt_2d" {
  vpc_id = aws_vpc.test_vpc.id
  cidr_block = "192.168.112.0/20"
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "test-pvt-2d"
  }
}

resource "aws_internet_gateway" "test_igw" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test-igw"
  }
}

resource "aws_route_table" "test_pub_rtb" {
  vpc_id = aws_vpc.test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_igw.id
  }
  tags = {
    Name = "test-pub-rtb"
  }
}

resource "aws_route_table" "test_pvt_rtb" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test-pvt-rtb"
  }
}

resource "aws_route_table_association" "test-pub_2a_association" {
  subnet_id = aws_subnet.test-pub_2a.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pub_2b_association" {
  subnet_id = aws_subnet.test-pub_2b.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pub_2c_association" {
  subnet_id = aws_subnet.test-pub_2c.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pub_2d_association" {
  subnet_id = aws_subnet.test-pub_2d.id
  route_table_id = aws_route_table.test_pub_rtb.id
}

resource "aws_route_table_association" "test-pvt_2a_association" {
  subnet_id = aws_subnet.test-pvt_2a.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test-pvt_2b_association" {
  subnet_id = aws_subnet.test-pvt_2b.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test-pvt_2c_association" {
  subnet_id = aws_subnet.test-pvt_2c.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

resource "aws_route_table_association" "test-pvt_2d_association" {
  subnet_id = aws_subnet.test-pvt_2d.id
  route_table_id = aws_route_table.test_pvt_rtb.id
}

### vpc end ###

### ec2 start ###

resource "aws_instance" "example" {
  ami                    = "ami-035da6a0773842f64"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.test-pub_2a.id
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = "my-key"
  user_data              = file("user-data.sh")

  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  vpc_id = aws_vpc.test_vpc.id
  name = var.security_group_name

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-sg"
  }
}

### ec2 end ###
