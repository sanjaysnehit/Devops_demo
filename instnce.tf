resource "aws_instance" "ec2_exmple" {
  ami = "ami-01aab85a5e4a5a0fe"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  instance_type = "t2.micro"
  associate_public_ip_address = "true"
  key_name = "mykey"
  
tags = {
  Name = "ec2_exmple"
}
}
