resource "null_resource" "vscode-config" {
  depends_on = [time_sleep.wait_for_instance]

   
      # the key we used for ssh conection is in the downloads folder of his macbook, bc ansible was downloaded in his macbk


  connection {
    type        = "ssh"
    host        = aws_instance.ubuntu.public_ip
    user        = "ubuntu"
    password    = ""
    private_key = file("~/Downloads/ansible-key.pem") #the key we used for ssh conection is in the downloads folder of his macbook, bc ansible was downloaded in his macbk
    #but the illustration we did in terfrm, we created a key file & we used a path module to refer to the key file we used for ssh bc trfrm was instaled in the cloud ie ec2
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo sed -i -e 's/\r$//' /tmp/script.sh", 
      "sudo /tmp/script.sh",
    ]
  }

  provisioner "local-exec" {
    command = templatefile("${var.os}-ssh-script.tpl", {
      hostname     = aws_instance.ubuntu.public_ip
      user         = "ansible",
      IdentityFile = "~/Downloads/ansible-key.pem"
    })
    interpreter = var.os == "windows" ? ["powershell", "-Command"] : ["bash", "-c"]
  }
}

resource "time_sleep" "wait_for_instance" {
  create_duration = "180s"

  depends_on = [aws_instance.ubuntu]
}
