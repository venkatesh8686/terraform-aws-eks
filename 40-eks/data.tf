
data "aws_ssm_parameter" "eks_control_plane_sg_id" {
  name = "/${var.project_name}/${var.environmemt_name}/eks_control_plane_sg_id"

}

data "aws_ssm_parameter" "node_sg_id" {
  name = "/${var.project_name}/${var.environmemt_name}/node_sg_id"

}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${var.project_name}/${var.environmemt_name}/private_subnet_ids"

}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project_name}/${var.environmemt_name}/vpc_id"

}

data "aws_ami" "joindevops" {
	most_recent      = true
	owners           = ["973714476881"]
	
	filter {
		name   = "name"
		values = ["RHEL-9-DevOps-Practice"]
	}
	filter {
		name   = "root-device-type"
		values = ["ebs"]
	}
	filter {
		name   = "virtualization-type"
		values = ["hvm"]
	}
	

}