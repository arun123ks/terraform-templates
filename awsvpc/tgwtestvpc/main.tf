provider "aws" {
}

resource "aws_vpc" "testvpctgw" {
  cidr_block       = "10.10.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "publicSubnet1" {
  vpc_id     = "${aws_vpc.testvpctgw.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "publicsubnet1"
  }
}


resource "aws_subnet" "publicSubnet2" {
  vpc_id     = "${aws_vpc.testvpctgw.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "publicsubnet2"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id     = "${aws_vpc.testvpctgw.id}"
  cidr_block = "10.10.3.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "Privatesubnet1"
  }
}


resource "aws_subnet" "PrivateSubnet2" {
  vpc_id     = "${aws_vpc.testvpctgw.id}"
  cidr_block = "10.10.4.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "privatesubnet2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.testvpctgw.id}"

  tags = {
    Name = "igw"
  }
}


resource "aws_route_table" "publicroutetable" {
  vpc_id = "${aws_vpc.testvpctgw.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }


  tags = {
    Name = "publicroutetable"
  }
}

resource "aws_route_table_association" "publicsuba" {
  subnet_id      = "${aws_subnet.publicSubnet1.id}"
  route_table_id = "${aws_route_table.publicroutetable.id}"
}

resource "aws_route_table_association" "publicsubb" {
  subnet_id      = "${aws_subnet.publicSubnet2.id}"
  route_table_id = "${aws_route_table.publicroutetable.id}"
}

resource "aws_vpc" "testvpcsec" {
  cidr_block       = "172.31.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "secvpc"
  }
}


resource "aws_subnet" "SecPrivateSubnet1" {
  vpc_id     = "${aws_vpc.testvpcsec.id}"
  cidr_block = "172.31.1.0/24"
  availability_zone = "us-east-2a"
  tags = {
    Name = "SecPrivatesubnet1"
  }
}


resource "aws_subnet" "SecPrivateSubnet2" {
  vpc_id     = "${aws_vpc.testvpcsec.id}"
  cidr_block = "172.31.2.0/24"
  availability_zone = "us-east-2b"
  tags = {
    Name = "secprivatesubnet2"
  }
}

resource "aws_ec2_transit_gateway" "tgw" {
  description = "tgw"
}


resource "aws_ec2_transit_gateway_vpc_attachment" "mainvpc" {
  subnet_ids         = ["${aws_subnet.publicSubnet1.id}", "${aws_subnet.PrivateSubnet2.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${aws_vpc.testvpctgw.id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "secvpc" {
  subnet_ids         = ["${aws_subnet.SecPrivateSubnet1.id}","${aws_subnet.SecPrivateSubnet2.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  vpc_id             = "${aws_vpc.testvpcsec.id}"
}

resource "aws_route" "routetgwmainvpc" {
  route_table_id            = "${aws_route_table.publicroutetable.id}"
  destination_cidr_block    = "172.31.0.0/16"
  transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
}



resource "aws_route_table" "mainvpcprirt" {
  vpc_id = "${aws_vpc.testvpctgw.id}"

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  }


  tags = {
    Name = "mainvpcprirt"
  }
}

resource "aws_route_table_association" "mainvpcprisubrtasc1" {
  subnet_id      = "${aws_subnet.PrivateSubnet1.id}"
  route_table_id = "${aws_route_table.mainvpcprirt.id}"
  depends_on                = ["aws_route_table.mainvpcprirt"]
}


resource "aws_route_table_association" "mainvpcprisubrtasc2" {
  subnet_id      = "${aws_subnet.PrivateSubnet2.id}"
  route_table_id = "${aws_route_table.mainvpcprirt.id}"
  depends_on                = ["aws_route_table.mainvpcprirt"]
}


resource "aws_route_table" "secvpcprirt" {
  vpc_id = "${aws_vpc.testvpcsec.id}"

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = "${aws_ec2_transit_gateway.tgw.id}"
  }


  tags = {
    Name = "secvpcprirt"
  }
}

resource "aws_route_table_association" "secvpcprisubrtasc1" {
  subnet_id      = "${aws_subnet.SecPrivateSubnet1.id}"
  route_table_id = "${aws_route_table.secvpcprirt.id}"
  depends_on                = ["aws_route_table.secvpcprirt"]
}


resource "aws_route_table_association" "secvpcprisubrtasc2" {
  subnet_id      = "${aws_subnet.SecPrivateSubnet2.id}"
  route_table_id = "${aws_route_table.secvpcprirt.id}"
  depends_on                = ["aws_route_table.secvpcprirt"]
}


resource "aws_security_group" "mainvpcsg" {
  name        = "MainCrossVPCAccess"
  description = "MainCrossVPCAccess"
  vpc_id      = "${aws_vpc.testvpctgw.id}"

  ingress {
    description = "From Same VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.testvpctgw.cidr_block]
  }

 ingress {
    description = "From another VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.testvpcsec.cidr_block]
  }
 
 ingress {
    description = "For ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MainVPCSG"
  }
}


resource "aws_security_group" "secvpcsg" {
  name        = "MainCrossVPCAccess"
  description = "MainCrossVPCAccess"
  vpc_id      = "${aws_vpc.testvpcsec.id}"

  ingress {
    description = "From Same VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.testvpctgw.cidr_block]
  }

 ingress {
    description = "From another VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.testvpcsec.cidr_block]
  }
 
  ingress {
    description = "For ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecVPCSG"
  }
}







resource "aws_instance" "mainvpctestpub2" {
  ami           = "ami-0e01ce4ee18447327"
  instance_type = "t2.micro"
  key_name = "mytesttgw"
  subnet_id = "${aws_subnet.publicSubnet2.id}"
  vpc_security_group_ids = ["${aws_security_group.mainvpcsg.id}"]
  depends_on                = ["aws_security_group.mainvpcsg"]
  tags = {
    Name = "mainvpctestpub2"
  }
}

resource "aws_instance" "mainvpctestpri1" {
  ami           = "ami-0e01ce4ee18447327"
  instance_type = "t2.micro"
  key_name = "mytesttgw"
  subnet_id = "${aws_subnet.PrivateSubnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.mainvpcsg.id}"]
  depends_on                = ["aws_security_group.mainvpcsg"] 
  tags = {
    Name = "mainvpctestpri1"
  }
}

resource "aws_instance" "secvpctestpri1" {
  ami           = "ami-0e01ce4ee18447327"
  instance_type = "t2.micro"
  key_name = "mytesttgw"
  subnet_id = "${aws_subnet.SecPrivateSubnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.secvpcsg.id}"]
  depends_on                = ["aws_security_group.secvpcsg"] 
  tags = {
    Name = "secvpctestpri1"
  }
}


resource "aws_instance" "secvpctestpri2" {
  ami           = "ami-0e01ce4ee18447327"
  instance_type = "t2.micro"
  key_name = "mytesttgw"
  subnet_id = "${aws_subnet.SecPrivateSubnet2.id}"
  vpc_security_group_ids = ["${aws_security_group.secvpcsg.id}"]
  depends_on                = ["aws_security_group.secvpcsg"]
  tags = {
    Name = "secvpctestpri2"
  }
}

resource "aws_eip" "pubeip" {
  instance = "${aws_instance.mainvpctestpub2.id}"
  vpc      = true
}


