provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-east-1"
}

resource "aws_instance" "WebApp" {
  ami           = "ami-97785bed"
  instance_type = "t2.micro"
  key_name		  = "TerraKey"
  tags {
    Name = "WebApp"
  }
}

