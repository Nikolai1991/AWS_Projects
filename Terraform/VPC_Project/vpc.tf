# first step: Accesses to instance
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-east-1"
}

# create VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"

  tags {
    Name = "Davidov"
  }
}

# create db subnet
resource "aws_subnet" "db_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags {
    Name = "DB"
  }
}

# create webserver_subnet
resource "aws_subnet" "webserver_subnet" {
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags {
    Name = "webserver"
  }
}

# ceate IGW
resource "aws_internet_gateway" "gw" {
  vpc_id		 = "${aws_vpc.main.id}"

  tags {
      Name = "internet-gateway"
  }
}

# create routing table
resource "aws_route_table" "web" {
  vpc_id		 = "${aws_vpc.main.id}"
route {
  cidr_block		 = "0.0.0.0/0"
  gateway_id		 = "${aws_internet_gateway.gw.id}"
    }

tags {
	Name = "web"
  }
}

# association subnet
resource "aws_main_route_table_association" "association-subnet" {
  vpc_id		 = "${aws_vpc.main.id}"
  route_table_id		 = "${aws_route_table.web.id}"
  }

resource "aws_route_table_association" "association-subnet" {
  subnet_id		 = "${aws_subnet.webserver_subnet.id}"
  route_table_id		 = "${aws_route_table.web.id}"
  }

# create security group (WEB)  
resource "aws_security_group" "web" {
  name = "security_group_for_web_server"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}   

# create security group (db)
resource "aws_security_group" "db" {
  name = "security_group_for_db_server"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}   

# create instance (WEB) 
resource "aws_instance" "webserver" {
  ami			 = "ami-aa2ea6d0"
  instance_type		 = "t2.micro"
  subnet_id		 = "${aws_subnet.webserver_subnet.id}" 
  key_name		= "TerraKey"
  vpc_security_group_ids = ["${aws_security_group.web.id}"]
  tags {
    Name = "web"
  }
}
  
# create instance (db)  
resource "aws_instance" "db" {
  ami			 = "ami-aa2ea6d0"
  instance_type		 = "t2.micro"
  subnet_id		 = "${aws_subnet.db_subnet.id}" 
  key_name		= "TerraKey"
  vpc_security_group_ids = ["${aws_security_group.db.id}"]
  tags {
    Name = "db"
  }
}
