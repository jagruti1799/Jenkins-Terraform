resource "tls_private_key" "webkey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

//Creating local file for storing ssh_key
resource "local_file" "webkey" {
  filename= "webkey.pem"  
  content= tls_private_key.webkey.private_key_pem 
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "my-vm"
  location              = var.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B2s"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "Linux"
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
     path     = "/home/adminuser/.ssh/authorized_keys"
     key_data = tls_private_key.webkey.public_key_openssh
    }
}
      connection {
      type = "ssh"
      user = "adminuser"
      host = azurerm_public_ip.publicip.ip_address
      private_key = tls_private_key.webkey.private_key_pem
       } 

   provisioner "local-exec" {
    command = "chmod 600 webkey.pem"
  }
   
  provisioner "file" {
    source      = "/home/einfochips/Desktop/Jenkins/Terraform/tomcat.sh"
    destination = "/home/adminuser/tomcat.sh"
  }
 
  provisioner "remote-exec" {
    inline = [
      "ls -a",
      "sudo chmod +x tomcat.sh",
      "sudo sh tomcat.sh",
    ]
  }
}
