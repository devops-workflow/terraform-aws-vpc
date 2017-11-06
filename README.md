VPC Terraform Module
=====================

Usage:
------

    module "vpc" {
      source      = "../tf_vpc"

      add variables
    }


## Inputs

| Name | Description | Default | Required |
|------|-------------|:-----:|:-----:|
| availability_zones | List of availability zones | - | yes |
| cidr | The CIDR block for the VPC. | - | yes |
| corp_customer_gateway_id | Corporate Customer Gateway ID | - | yes |
| corp_vpn_cidr | Corporate VPN CIDR | - | yes |
| environment | Environment (ex: dev, qa, stage, prod) | - | yes |
| external_subnets | List of external subnets | - | yes |
| internal_subnets | List of internal subnets | - | yes |
| name | Name | - | yes |
| namespaced | Namespace all resources (prefixed with the environment)? | `true` | no |
| tags | A map of tags to add to all resources | `<map>` | no |

## Outputs

| Name | Description |
|------|-------------|
| availability_zones | The list of availability zones of the VPC. |
| corp_gtwy_id | Corporate Gateway ID |
| corp_vpn_gtwy_id | Corporate VPN Gateway ID |
| corp_vpn_id | Corporate VPN Connection ID |
| db_subnet_group | Database Subnet Group name |
| db_subnet_ids | Database Subnet IDs |
| ec_subnet_group | ElasticCache Subnet Group name |
| ec_subnet_ids | ElasticCache Subnet IDs |
| external_route_table_ids | The external route table ID. |
| external_subnets | List of external subnet IDs. |
| id | The VPC ID |
| internal_nat_ips | The list of EIPs associated with the internal subnets. |
| internal_route_table_ids | The internal route table ID. |
| internal_subnets | List of internal subnet IDs. |
| internet_gateway | internet gateway |
| nat_gateway_ids | NAT gateway |
| security_group | The default VPC security group ID. |


### Resource Graph

![Terraform Graph](graph.png)
