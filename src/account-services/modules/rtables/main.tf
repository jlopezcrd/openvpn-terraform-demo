variable "kaira_vpc_id" {}
variable "kaira_igw_main_id" {}
variable "kaira_subnet_public_ids" {}

resource "aws_route_table" "kaira_route_table_public" {
    tags = {
        Name = "kaira-route-table-public"
    }

    vpc_id = var.kaira_vpc_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = var.kaira_igw_main_id
    }
}

resource "aws_route_table_association" "kaira_route_table_association_public_a" {
    subnet_id      = var.kaira_subnet_public_ids.a
    route_table_id = aws_route_table.kaira_route_table_public.id
}

resource "aws_route_table_association" "kaira_route_table_association_public_b" {
    subnet_id      = var.kaira_subnet_public_ids.b
    route_table_id = aws_route_table.kaira_route_table_public.id
}

resource "aws_route_table_association" "kaira_route_table_association_public_c" {
    subnet_id      = var.kaira_subnet_public_ids.c
    route_table_id = aws_route_table.kaira_route_table_public.id
}
