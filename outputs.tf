/**
 * Outputs
**/

// The VPC ID
output "id" {
  value = "${aws_vpc.vpc.id}"
}

// List of external subnet IDs.
output "external_subnets" {
  value = "${module.subnet_external.subnet_ids}"
}
// The external route table ID.
output "external_route_table_ids" {
  value = "${module.subnet_external.subnet_route_table_ids}"
}

// List of internal subnet IDs.
output "internal_subnets" {
  value = "${module.subnet_internal.subnet_ids}"
}
// The internal route table ID.
output "internal_route_table_ids" {
  value = "${module.subnet_internal.subnet_route_table_ids}"
}

// The default VPC security group ID.
output "security_group" {
  value = "${aws_vpc.vpc.default_security_group_id}"
}

// The list of availability zones of the VPC.
output "availability_zones" {
  value = "${module.subnet_external.availability_zones}"
}

// The list of EIPs associated with the internal subnets.
output "internal_nat_ips" {
  value = "${module.gateways.nat_ips}"
}

// internet gateway
output "internet_gateway" {
  value = "${module.gateways.internet_gateway}"
}
// NAT gateway
output "nat_gateway_ids" {
  value = "${module.gateways.nat_gateway_ids}"
}

// Corporate Gateway ID
output "corp_gtwy_id" {
  value = "${module.vpn_corp.corp_gtwy_id}"
}
// Corporate VPN Connection ID
output "corp_vpn_id" {
  value = "${module.vpn_corp.corp_vpn_id}"
}
// Corporate VPN Gateway ID
output "corp_vpn_gtwy_id" {
  value = "${module.vpn_corp.corp_vpn_gtwy_id}"
}

/*
**  Database
**/

// Database Subnet IDs
output "db_subnet_ids" {
  value = ["${aws_subnet.subnet_internal_db.*.id}"]
}
// Database Subnet Group name
output "db_subnet_group" {
  value = "${aws_db_subnet_group.internal_db.name}"
}

/*
**  ElasticCache
**/

// ElasticCache Subnet IDs
output "ec_subnet_ids" {
  value = ["${aws_subnet.subnet_internal_ec.*.id}"]
}
// ElasticCache Subnet Group name
output "ec_subnet_group" {
  value = "${aws_elasticache_subnet_group.internal_ec.name}"
}
