####################
# Common Variables #
####################
company     = "kopicloud"
app_name    = "iaas"
environment = "development"
location    = "westeurope"

###########
# Network #
###########
network-vnet-cidr   = "10.128.0.0/16"
public-subnet-cidr  = "10.128.1.0/24"
private-subnet-cidr = "10.128.2.0/24"

######################
# Bastion Windows VM #
######################
windows-vm-hostname    = "tfwinsrv"
windows-vm-size        = "Standard_B2s"
windows-admin-username = "tfadmin"
windows-admin-password = "S3cr3ts24"
