data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet" "default_vpc_subnets_ids" {
  for_each = toset(data.aws_subnets.default_vpc_subnets.ids)
  id       = each.value
}

