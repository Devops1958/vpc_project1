resource "tls_private_key" "app1" {
  algorithm = "RSA"

}
resource "aws_key_pair" "app1" {

  key_name   = "utc-key"
  public_key = tls_private_key.app1.public_key_openssh
}
# Save file
resource "local_file" "ssh_key" {
  filename = "utc-key.pem"
  content  = tls_private_key.app1.private_key_pem
}