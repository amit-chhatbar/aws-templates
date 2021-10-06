variable "web_whitelist" {
    type    = list(string)
    default = ["0.0.0.0/0"]
}
variable "web_image_id" {
   type     = string
   default  = "ami-012c7314a6f9b09d6"
}

variable "web_instance_type" {
    type    = string
    default = "t2.nano"
}

variable "web_desired_capacity" {  
    type    = string
    default = 2
}

variable "web_max_size" {
    type = string
    default = 3
}

variable "web_min_size" {
    type = string
    default = 2
}
