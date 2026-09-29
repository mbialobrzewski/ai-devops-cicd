variable "uczestnik" {
  description = "Twój identyfikator — wchodzi w nazwy zasobów"
  type        = string
}

variable "vpc_id" {
  description = "ID VPC, w której działa kolektor"
  type        = string
}

variable "cidr_siec_wewnetrzna" {
  description = "Zakres adresów sieci wewnętrznej, z której kolektor przyjmuje syslog (port 514)"
  type        = string
  default     = "10.20.0.0/16"
}
