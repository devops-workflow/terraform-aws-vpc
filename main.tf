/**
 * VPC Terraform Module
 * =====================
 *
 * Usage:
 * ------
 *
 *     module "vpc" {
 *       source      = "../tf_vpc"
 *
 *       add variables
 *     }
**/

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  #instance_tenancy = "default"
  lifecycle {
    create_before_destroy = true
  #   #prevent_destroy = true
  }
  tags = "${ merge(
    var.tags,
    map(
      "Name", var.namespaced ?
        format("%s-%s", var.environment, var.name) :
        format("%s", var.name),
      "Environment", var.environment,
      "Terraform", "true"
    )
  )}"
}

/**
 * Network ACLs
 */

resource "aws_default_network_acl" "default" {
  default_network_acl_id = "${aws_vpc.vpc.default_network_acl_id}"
  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = "${ merge(
    var.tags,
    map("Name", var.namespaced ?
     format("%s-%s-network-acl-001", var.environment, var.name) :
     format("%s-network-acl-001", var.name) ),
    map("Environment", var.environment),
    map("Terraform", "true") )}"
}

module "dhcp-internal" {
  source      = "../tf_dhcp"
  domain_name = "ec2.internal"
  environment = "${var.environment}"
  name        = "internal"
  vpc_id      = "${aws_vpc.vpc.id}"
}

module "gateways" {
  source            = "../tf_gateways"
  environment       = "${var.environment}"
  name              = ""
  public_subnet_ids = "${module.subnet_external.subnet_ids}"
  vpc_id            = "${aws_vpc.vpc.id}"
}

module "vpn_corp" {
  source                    = "../tf_vpn_corp"
  name                      = "corp"
  environment               = "${var.environment}"
  vpc_id                    = "${aws_vpc.vpc.id}"
  dest_cidrs                = ["${var.corp_vpn_cidr}"]
  corp_customer_gateway_id  = "${var.corp_customer_gateway_id}"
}


/**
 * Subnets - Internal
**/
module "subnet_internal" {
  source      = "../tf_subnet"
  name        = "internal"
  environment = "${var.environment}"
  cidrs       = "${var.internal_subnets}"
  cidr_block  = "${aws_vpc.vpc.cidr_block}"
  azs         = "${var.availability_zones}"
  vpc_id      = "${aws_vpc.vpc.id}"
  igw_id      = "${module.gateways.internet_gateway}"
  # TODO: test for any issues. Might need to add local route
  propagate_vgws  = ["${module.vpn_corp.corp_vpn_gtwy_id}"]
  #propagate_vgws  = []
  cidr_add_bits   = 4
  tags = "${ merge(
    var.tags,
    map("Description", "Internal / Private Subnet") )}"
}
resource "aws_route" "route_internal_nat" {
  count                   = "${length(var.availability_zones)}"
  route_table_id          = "${element(module.subnet_internal.subnet_route_table_ids, count.index)}"
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = "${element(module.gateways.nat_gateway_ids, count.index)}"
}
// Database Network
resource "aws_subnet" "subnet_internal_db" {
  count                   = "${length(var.availability_zones)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 12 + count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false
  tags = "${ merge(
    var.tags,
    map("Name", var.namespaced ?
     format("%s-%s-internal_db-%03d", var.environment, var.name, count.index) :
     format("%s-internal_db-%03d", var.name, count.index) ),
    map("Environment", var.environment),
    map("Description", "Private Database Subnet"),
    map("Terraform", "true") )}"
}
resource "aws_route_table_association" "internal_db" {
  count           = "${length(var.availability_zones)}"
  subnet_id       = "${element(aws_subnet.subnet_internal_db.*.id, count.index)}"
  route_table_id  = "${element(module.subnet_internal.subnet_route_table_ids, count.index)}"
}
resource "aws_db_subnet_group" "internal_db" {
  name        = "${format("%s-%s-internal_db", var.environment, var.name)}"
  description = "Internal Database subnet"
  subnet_ids  = ["${module.subnet_internal.subnet_ids}"]
  tags = "${ merge(
    var.tags,
    map("Name", var.namespaced ?
     format("%s-%s-internal_db", var.environment, var.name) :
     format("%s-internal_db", var.name) ),
    map("Environment", var.environment),
    map("Description", "Private Database Subnet Group"),
    map("Terraform", "true") )}"
}

// Elasticache Network
resource "aws_subnet" "subnet_internal_ec" {
  count             = "${length(var.availability_zones)}"
  vpc_id            = "${aws_vpc.vpc.id}"
  cidr_block        = "${cidrsubnet(aws_vpc.vpc.cidr_block, 4, 8+count.index)}"
  availability_zone = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false
  tags = "${ merge(
    var.tags,
    map("Name", var.namespaced ?
     format("%s-%s-internal_ec-%02d", var.environment, var.name, count.index) :
     format("%s-internal_ec-%02d", var.name, count.index) ),
    map("Environment", var.environment),
    map("Description", "Private ElasticCache Subnet"),
    map("Terraform", "true") )}"
}
resource "aws_route_table_association" "internal_ec" {
  count           = "${length(var.availability_zones)}"
  subnet_id       = "${element(aws_subnet.subnet_internal_ec.*.id, count.index)}"
  #?? which route table ? module.subnet_internal.subnet_route_table_ids
  route_table_id  = "${element(module.subnet_internal.subnet_route_table_ids, count.index)}"
}
resource "aws_elasticache_subnet_group" "internal_ec" {
  name        = "${var.namespaced ?
    format("%s-%s-internal-ec", var.environment, var.name) :
    format("%s-internal-ec", var.name)}"
  description = "Internal ElasticCache subnet group"
  subnet_ids  = ["${aws_subnet.subnet_internal_ec.*.id}"]
}

# Internal (private) routes: nat, corp vpn
# External (public) routes :

/**
 *  Subnets - External
**/
module "subnet_external" {
  source      = "../tf_subnet"
  name        = "external"
  environment = "${var.environment}"
  cidrs       = "${var.external_subnets}"
  cidr_block  = "${aws_vpc.vpc.cidr_block}"
  azs         = "${var.availability_zones}"
  vpc_id      = "${aws_vpc.vpc.id}"
  igw_id      = "${module.gateways.internet_gateway}"
  propagate_vgws  = ["${module.vpn_corp.corp_vpn_gtwy_id}"]
  #propagate_vgws  = []
  cidr_add_bits   = 4
  subnet_offset   = 4
  tags = "${ merge(
    var.tags,
    map("Description", "External / Public Subnet") )}"
}
resource "aws_route" "igw" {
  count                  = "${length(var.availability_zones)}"
  route_table_id         = "${element(module.subnet_external.subnet_route_table_ids, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${module.gateways.internet_gateway}"
  depends_on             = ["module.subnet_external"]
  lifecycle {
    create_before_destroy = true
  }
}

/*
resource "aws_route" "external" {
  route_table_id         = "${element(module.subnet_external.subnet_route_table_ids, 1)}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${module.gateways.internet_gateway}"
}
*/
