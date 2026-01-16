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
 
  provisioner "file" {           #mee,   REMOTE DEVELOPMENT
    source      = "script.sh"  #mmee,this script configures the vscode eg it needs to mk a dir in the home of ansible and so on,  so with this configuration & the configuration
    destination = "/tmp/script.sh"     #we did in the vscode in configuration file which is inside vscode, we can directly use your vscode code to do remote host, to login to 
  }                 #the ec2instance and write your code, create your files , write your play book and run them on your termiinal, & thats what we call remote development

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
