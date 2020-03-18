#######################
## Windows VM - Main ##
#######################

# Local variables
locals {
  # Init Log
  log_start = "Start-Transcript -Path 'C:/SetupLog/terraform.txt' -NoClobber"

  # Initialize Hard Drives
  disk_01 = "Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false"

  # Configure Disk Volumen Labels
  disk_02 = "Set-Volume -DriveLetter ${var.disk-f-letter} -NewFileSystemLabel '${var.disk-f-label}'"
  disk_03 = "Set-Volume -DriveLetter ${var.disk-g-letter} -NewFileSystemLabel '${var.disk-g-label}'"
  
  # stop log  
  log_end = "Stop-Transcript"

  # exit code  
  exit_code = "exit 0"

  # Create PowerShell Command 
  disk_config = "${local.log_start}; ${local.disk_01}; ${local.disk_02}; ${local.disk_03}; ${local.log_end}; ${local.exit_code};"
}

# Create Network Security Group to Access VM from Internet
resource "azurerm_network_security_group" "windows-vm-nsg" {
  name                = "${var.app_name}-${var.environment}-windows-vm-nsg"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name

  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*" 
  }

  tags = {
    application = var.app_name
    environment = var.environment 
  }
}

# Associate the NSG with the Public Subnet
resource "azurerm_subnet_network_security_group_association" "windows-vm-nsg-association" {
  subnet_id                 = azurerm_subnet.network-public-subnet.id
  network_security_group_id = azurerm_network_security_group.windows-vm-nsg.id
}

# Get a Static Public IP
resource "azurerm_public_ip" "windows-vm-ip" {
  name                = "${var.windows-vm-hostname}-ip"
  location            = azurerm_resource_group.network-rg.location
  resource_group_name = azurerm_resource_group.network-rg.name
  allocation_method   = "Dynamic" # Dynamic or Static
  
  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

# Create Network Card for VM
resource "azurerm_network_interface" "windows-vm-nic" {
  name                      = "${var.windows-vm-hostname}-nic"
  location                  = azurerm_resource_group.network-rg.location
  resource_group_name       = azurerm_resource_group.network-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.network-public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.windows-vm-ip.id
  }

  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

# Create Windows Virtual Machine
resource "azurerm_windows_virtual_machine" "windows-vm" {
  name                  = var.windows-vm-hostname
  location              = azurerm_resource_group.network-rg.location
  resource_group_name   = azurerm_resource_group.network-rg.name
  size                  = var.windows-vm-size
  network_interface_ids = [azurerm_network_interface.windows-vm-nic.id]
  
  computer_name         = var.windows-vm-hostname
  admin_username        = var.windows-admin-username
  admin_password        = var.windows-admin-password

  os_disk {
    name                 = "${var.windows-vm-hostname}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.windows-2016-sku
    version   = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true

  tags = {
    application = var.app_name
    environment = var.environment 
  }
}

# Create Data Disk F for Windows VM
resource "azurerm_managed_disk" "disk-f" {
  name                 = "${var.windows-vm-hostname}-disk-f"
  location              = azurerm_resource_group.network-rg.location
  resource_group_name   = azurerm_resource_group.network-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk-f-size

  tags = {
    environment = var.environment
  }
}

# Attach Data Disk F to Windows VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk-f-attachment" {
  depends_on=[azurerm_managed_disk.disk-f]
  managed_disk_id    = azurerm_managed_disk.disk-f.id
  virtual_machine_id = azurerm_windows_virtual_machine.windows-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

# Create Data Disk G for Windows VM
resource "azurerm_managed_disk" "disk-g" {
  name                 = "${var.windows-vm-hostname}-disk-g"
  location              = azurerm_resource_group.network-rg.location
  resource_group_name   = azurerm_resource_group.network-rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.disk-g-size

  tags = {
    environment = var.environment
  }
}

# Attach Data Disk G to Windows VM
resource "azurerm_virtual_machine_data_disk_attachment" "disk-g-attachment" {
  depends_on=[azurerm_managed_disk.disk-g]
  managed_disk_id    = azurerm_managed_disk.disk-g.id
  virtual_machine_id = azurerm_windows_virtual_machine.windows-vm.id
  lun                = "11"
  caching            = "ReadWrite"
}

# Windows VM virtual machine extenstion - Configure Disks
resource "azurerm_virtual_machine_extension" "windows-vm-extension" {
  depends_on=[
    azurerm_windows_virtual_machine.windows-vm,
    azurerm_managed_disk.disk-f,
    azurerm_virtual_machine_data_disk_attachment.disk-f-attachment,
    azurerm_managed_disk.disk-g,
    azurerm_virtual_machine_data_disk_attachment.disk-g-attachment
  ]

  name                 = "${var.windows-vm-hostname}-vm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"  
  settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.disk_config}\""
  }
  SETTINGS

  tags = { 
    environment = var.environment
  }
}