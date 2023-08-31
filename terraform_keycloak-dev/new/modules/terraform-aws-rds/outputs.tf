/*
output "database_hostname" {
  value = aws_db_instance.keycloakdb.address
}

output "database_port" {
  value = aws_db_instance.keycloakdb.port
}

output "database_name" {
  value = aws_db_instance.keycloakdb.name
}
*/
output "database_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "rds_group" {
  value = aws_security_group.main.id
}