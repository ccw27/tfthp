output "EC2-Public-IP" {
  value = aws_instance.PublicInstance.public_ip
}
