terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

resource "azurerm_public_ip" "main" {
  name                = "${var.component}-${var.env}-pip"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  allocation_method   = "Static"

  tags = {
    component = "${var.component}-${var.env}"
  }
}

resource "azurerm_network_interface" "main" {
  name                = "${var.component}-${var.env}-interface"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}


resource "azurerm_network_security_group" "main" {
  name                = "${var.component}-${var.env}-nsg"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = var.component
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    component = "${var.component}-${var.env}"
  }
}
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}




resource "azurerm_dns_a_record" "main" {
  name                = "${var.component}-${var.env}"
  zone_name           = "devopsazurepractice.online"
  resource_group_name = data.azurerm_resource_group.main.name
  ttl                 = 10
  records             = [azurerm_network_interface.main.private_ip_address]
}

resource "azurerm_virtual_machine" "main" {
  depends_on = [azurerm_network_interface_security_group_association.example, azurerm_dns_a_record.main]
  name                  = "${var.component}-${var.env}"
  location              = data.azurerm_resource_group.main.location
  resource_group_name   = data.azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = var.vm_size




  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  # delete_data_disks_on_termination = true

  storage_image_reference {
    id = "/subscriptions/a92e07d8-3cdd-4fda-bb98-99b2dddb739c/resourceGroups/Project/providers/Microsoft.Compute/galleries/custom/images/custom/versions/1.0.0"
}


  storage_os_disk {
    name              = "${var.component}-${var.env}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.component}-${var.env}"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    component = "${var.component}-${var.env}"
  }
}

resource "null_resource" "ansible" {
  depends_on = [azurerm_virtual_machine.main]

  provisioner "remote-exec" {



  connection {
    type     = "ssh"
    user     = "harsha"
    password = "harsha@123456"
    host     = azurerm_public_ip.main.ip_address
  }

    inline = [
      "sudo dnf install python3.12-pip -y",
      "sudo pip3.12 install ansible",
      "ansible-pull -i localhost, -U https://github.com/sriharshakasireddy/ansible roboshop.yml -e app_name=${var.component} -e ENV=${var.env} "

    ]

  }

}