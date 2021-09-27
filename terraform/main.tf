provider "aws" {
    region = "us-east-1"
}

#####
# VPC and subnets
#####
data "aws_vpc" "default" {
    default = true
}

resource "aws_security_group" "default" {
  name = "rds_postgresql_sg"

  description = "RDS postgres servers (terraform-managed)"
  vpc_id = data.aws_vpc.default.id

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["201.81.79.104/32"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_subnet_ids" "all" {
    vpc_id = data.aws_vpc.default.id
}

resource "aws_rds_cluster" "default" {
    cluster_identifier = "aurora-cluster-demo"
    engine = "aurora-postgresql"
    #engine_version = "5.7.mysql_aurora.2.03.2"
    #availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
    database_name = "livro"
    master_username = "livreiro"
    master_password = "L1vr31r0"
    backup_retention_period = 1
    preferred_backup_window = "07:00-09:00"
    apply_immediately = true
    skip_final_snapshot = true
    vpc_security_group_ids   = ["${aws_security_group.default.id}"]
}

resource "aws_rds_cluster_instance" "cluster_instances" {
    count = 1
    identifier = "aurora-cluster-demo-${count.index}"
    cluster_identifier = aws_rds_cluster.default.id
    instance_class = "db.t3.medium"
    engine = aws_rds_cluster.default.engine
    engine_version = aws_rds_cluster.default.engine_version
    publicly_accessible = true
}

# resource "aws_db_instance" "default" {
#     allocated_storage = 10
#     engine = "mysql"
#     engine_version = "5.7"
#     instance_class = "db.t3.micro"
#     name = "mydb"
#     username = "livreiro"
#     password = "L1vr31r0@"
#     parameter_group_name = "default.mysql5.7"
#     skip_final_snapshot = true
# }
