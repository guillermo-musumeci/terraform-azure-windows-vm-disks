############################
## Windows VM - Variables ##
############################

# Windows VM Admin User
variable "windows-admin-username" {
  type        = string
  description = "Windows VM Admin User"
  default     = "tfadmin"
}

# Windows VM Admin Password
variable "windows-admin-password" {
  type        = string
  description = "Windows VM Admin Password"
  default     = "S3cr3ts24"
}

# Windows VM Hostname (limited to 15 characters long)
variable "windows-vm-hostname" {
  type        = string
  description = "Windows VM Hostname"
  default     = "bastionwwin1"
}

# Windows VM Virtual Machine Size
variable "windows-vm-size" {
  type        = string
  description = "Windows VM Size"
  default     = "Standard_B1s"
}

############
## Disk F ##
############

variable "disk-f-letter" {
  type        = string
  description = "Disk F Letter"
  default     = "F"
}

variable "disk-f-label" {
  type        = string
  description = "Disk F Label"
  default     = "Disk F"
}

variable "disk-f-size" {
  type        = string
  description = "Disk F size"
  default     = "10"
}

############
## Disk G ##
############

variable "disk-g-letter" {
  type        = string
  description = "Disk E Letter"
  default     = "G"
}

variable "disk-g-label" {
  type        = string
  description = "Disk G Label"
  default     = "Disk G"
}

variable "disk-g-size" {
  type        = string
  description = "Disk G size"
  default     = "10"
}

##############
## OS Image ##
##############

# Windows Server 2019 SKU used to build VMs
variable "windows-2019-sku" {
  type        = string
  description = "Windows Server 2019 SKU used to build VMs"
  default     = "2019-Datacenter"
}

# Windows Server 2016 SKU used to build VMs
variable "windows-2016-sku" {
  type        = string
  description = "Windows Server 2016 SKU used to build VMs"
  default     = "2016-Datacenter"
}

# Windows Server 2012 R2 SKU used to build VMs
variable "windows-2012-sku" {
  type        = string
  description = "Windows Server 2012 R2 SKU used to build VMs"
  default     = "2012-R2-Datacenter"
}