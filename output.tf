output "public_ip" {
  value = aws_instance.utc-app1.public_ip
}
output "ssh-command" {
  value = "ssh -i utc-key.pem ec2-user@${aws_instance.utc-app1.public_ip}"
}