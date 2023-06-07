# Provider details and region settings, along with creds to access api.
provider "aws" {
  region = "ap-southeast-2"
  profile = "change-me" # yanked from ~/.aws/creds file
}

# settings for ec2 build.
resource "aws_instance" "teamspeak" {
  ami = "ami-04ec2a3550d263fe1"
  instance_type = "t2.nano"
  key_name = "user@MacBook-Pro.local"
  vpc_security_group_ids = ["sg-7XXXXX1b"]
  tags = {
    Name = "Teamspeak" # or hostname can be used here.
  }

  # what to build after the instance ec2 is running.
  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip
    agent    = "true" # ssh-agent to store/handle the passwd required for the id_rsa private

  }
  # push db file
  provisioner "file" {
    source      = "extra/ts3server.sqlitedb"
    destination = "/home/ubuntu/ts3server.sqlitedb"
  }
  # bash script to do the needful
  provisioner "file" {
    source      = "build.sh"
    destination = "/home/ubuntu/build.sh"
  }
  # remove commands to get it done.
  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/ubuntu/build.sh >/tmp/build.log",
      "echo 'Script executed successfully!'"
    ]
  }
}
