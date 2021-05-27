variable "web_image_id" {
   type     = string
}

variable "web_instance_type" {
    type    = string
}

variable "web_desired_capacity" {  
    type    = string
}

variable "web_max_size" {
    type = number
}

variable "web_min_size" {
    type = string
}

variable "subnets" {
    type = list(string)
}

variable "security_groups" {
    type = list(string)
}

variable "app" {
    type = string
}