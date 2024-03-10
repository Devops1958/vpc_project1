resource "aws_vpc" "utc-app1" {
  cidr_block           = "172.120.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {

    Name       = "utc-app1"
    Env        = "dev"
    Team       = "wdp"
    created_by = "Stephane"
  }
}
resource "aws_internet_gateway" "dev-wdp-IGW" {

  vpc_id = aws_vpc.utc-app1.id
  tags = {
    Name = "dev-Wdp-IGW"
  }
}
resource "aws_security_group" "webserver-sg" {
  description = "ssh allow just from your ip"
  vpc_id      = aws_vpc.utc-app1.id
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
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {

    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "utc-app1" {
  ami                    = "ami-06a0cd9728546d178"
  instance_type          = "t2.micro"
  key_name               = "utc-key"
  vpc_security_group_ids = [aws_security_group.webserver-sg.id]
  subnet_id              = aws_subnet.public_subnet1a.id
  user_data              = file("install.sh")
  tags = {

    Name       = "utc-app1-inst"
    Team       = "cloud transformation"
    Env        = "dev"
    created_by = "stephane"
  }
}
resource "aws_subnet" "public_subnet1a" {
  vpc_id                  = aws_vpc.utc-app1.id
  cidr_block              = "172.120.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "public_subnet2a" {
  vpc_id                  = aws_vpc.utc-app1.id
  cidr_block              = "172.120.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}
resource "aws_subnet" "private_subnet1a" {
  vpc_id            = aws_vpc.utc-app1.id
  cidr_block        = "172.120.3.0/24"
  availability_zone = "us-east-1a"
}
resource "aws_subnet" "private_subnet2a" {
  vpc_id            = aws_vpc.utc-app1.id
  cidr_block        = "172.120.4.0/24"
  availability_zone = "us-east-1b"
}
#resource "aws_internet_gateway_attachment" "web" {

# internet_gateway_id = aws_internet_gateway.dev-wdp-IGW.id
# vpc_id              = aws_vpc.utc-app1.id
#}
resource "aws_route_table_association" "rta1" {
  subnet_id      = aws_subnet.public_subnet1a.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id      = aws_subnet.public_subnet1a.id
  route_table_id = aws_route_table.rt.id
}
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.utc-app1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev-wdp-IGW.id
  }
}
resource "aws_ebs_volume" "utc-ebs" {
  availability_zone = "us-east-1a"
  size              = 20

  tags = {
    Name = "utc-ebs"
  }
}
resource "aws_volume_attachment" "utc-vol" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.utc-ebs.id
  instance_id = aws_instance.utc-app1.id
}
resource "aws_s3_bucket" "utc_bucket" {
  bucket = "my-stephe-bucket1"
  lifecycle {
    prevent_destroy = false
  }
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform_locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "UserId"
  attribute {
    name = "UserId"
    type = "S"
  }
  tags = {
    Name = "terraform State Lock"
  }
}
