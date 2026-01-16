#resource block
resource "aws_instance" "ubuntu" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.my_instance_type
  #user_data     = file("${path.module}/ansible-install-ubuntu.sh")     #meee, this is for the controller & thats where we are installing ansible bt i bliv his was his macbk
  user_data = data.template_cloudinit_config.user-data.rendered     #this is in reference to the data block below

  key_name = var.my_key

  tags = {
    "Name" = "Ansible-Ubuntu"
  }
}

resource "aws_instance" "ubuntu-hosts" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.my_instance_type
  user_data     = file("${path.module}/create_ansible_user.sh")
  key_name      = var.my_key
  count         = 2                    #meee,  this means the meta argument count will create 2 ubuntu host servers
  tags = {
    "Name" = "My-Ubuntu-${count.index}"
    "Type" = "My-Ubuntu-${count.index}"
  }
}

resource "aws_instance" "rhel-hosts" {
  ami           = data.aws_ami.rhel.id
  instance_type = var.my_instance_type
  user_data     = file("${path.module}/create_ansible_user.sh")
  key_name      = var.my_key
  count         = 1                                         #meee,  this means the meta argument count will create 1 redhat host server
  tags = {
    "Name" = "My-rhel-${count.index}"
  }
}


data "template_cloudinit_config" "user-data" {       # we used this to be able to pass the 2 scripts
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/ansible-install-ubuntu.sh")        #script to install ubuntu
  }
  part {
    content_type = "text/x-shellscript"
    content      = file("${path.module}/vscode-install.sh")       #script to install vscode
  }
}
