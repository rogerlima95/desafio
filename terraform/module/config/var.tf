variable "region" {
    type = string
}

variable "environment" {
  type = string
}

variable "vpc" {
    type = set(any)
    default = []  
}

variable "eks" {
  type = set(any)
  default = []
}

variable "repository_name" {
type = string  
}