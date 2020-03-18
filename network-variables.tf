##############################
## Core Network - Variables ##
##############################

variable "network-vnet-cidr" {
  type        = string
  description = "The CIDR of the network VNET"
}

variable "public-subnet-cidr" {
  type        = string
  description = "The CIDR for the public subnet"
}

variable "private-subnet-cidr" {
  type        = string
  description = "The CIDR for the private subnet"
}
