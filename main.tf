provider "aws"{
  region  = var.region
}

resource "aws_key_pair" "sshkey" {
  key_name   = "sshkey"
  public_key = "${file("sshkey.pub")}"
}
