variable "region" {
  type        = string
  description = "The Region were resources are to be hosted"
}

variable "infra_name" {
  type        = string
  description = "The base name of this infrastructure"
}

variable "cluster_name" {
  type        = string
  description = "The base name of the eks cluster"
}

