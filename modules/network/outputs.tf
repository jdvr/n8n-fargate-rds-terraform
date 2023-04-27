output "subnets_ids" {
  description = "Avaialble subnets_ids"
  value = [for s in data.aws_subnet.default_vpc_subnets_ids : s.id] 
}

output "vpc_id" {
  description = "Default VPC id"
  value = data.aws_vpc.default.id
}

output "vpc_cidr_block" {
  description = "cidr for default vpc"
  value = data.aws_vpc.default.cidr_block
}