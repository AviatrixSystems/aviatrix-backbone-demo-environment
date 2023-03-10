output "controller_public_ip" {
  value = module.aviatrix_controller_aws.public_ip
}

output "controller_private_ip" {
  value = module.aviatrix_controller_aws.private_ip
}

output "controller_vpc_id" {
  value = module.aviatrix_controller_aws.vpc_id
}

output "controller_subnet_id" {
  value = module.aviatrix_controller_aws.subnet_id
}

output "controller_security_group_id" {
  value = module.aviatrix_controller_aws.security_group_id
}

output "copilot_security_group_id" {
  value = tolist(module.aviatrix_copilot_aws.ec2-info[0].vpc_security_group_ids)[0]
}

output "copilot_public_ip" {
  value = module.aviatrix_copilot_aws.public_ip
}

output "copilot_private_ip" {
  value = module.aviatrix_copilot_aws.private_ip
}

output "aws_account" {
  value = data.aws_caller_identity.aws_account.account_id
}
