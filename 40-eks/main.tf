
resource "aws_key_pair" "eks" {
  key_name   = "eks"
  # you can paste the public key directly like this
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDZsbYK4SbS7FY7RRfTi1cgi4W6LERuuBxdfYJnYbUbIlgeNkoF55Qfl3DtBo8bwd+Ea+fx1zWUZSBjfoIg+310sLj3zOU8I8zt/oiZTeFYuXSpbIZ4Nz5eX3V6d19WtdiAXL/gXfpj3dIQMoYyUTC9AqHbkUyPZhiFRrVvjI9KupEtagZD0XsNY8nYNLBsCo82XEeFl3uBqyT4qON7ntDRgKWTObTySek73zzO1FhS3OjAGh5+PnL/ZGtu3XAYjnsXHGk6yUetgDjuFccpPCUV/b9pTTz1BUVFdS0JrSpfkLkcEuEHcTQwlr6wGs/2d8auZqMd3gyFESyLtdVtf6IzYNXpX1X3uHo4CRdSbOEcQ1+1VG2fVzy/G3jgOm2N+vtA0FODO9osnsxG9rJh+9cXwGR0MujZWT97Q983zh3+f2fhCma53crOAoNfVHinmYrVr3Bh3uU7wm2vXdgRevXHE5i3DUKyuI2Q6TvGuwwZFglOXWAuna2Fk77m9JKDwq0= HP@DESKTOP-2QK9VNM"
  #public_key = file("~/.ssh/eks.pub")
  # ~ means windows home directory
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"


  cluster_name    = "${var.project_name}-${var.environmemt_name}"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id                   = data.aws_ssm_parameter.vpc_id.value
  subnet_ids               = local.private_subnet_ids
  control_plane_subnet_ids = local.private_subnet_ids

  create_cluster_security_group = false
  cluster_security_group_id     = local.eks_control_plane_sg_id

  create_node_security_group = false
  node_security_group_id     = local.node_sg_id

  # the user which you used to create cluster will get admin access

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  }

  eks_managed_node_groups = {
    blue = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      #capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
    #   # EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }
    green = {
      min_size      = 2
      max_size      = 10
      desired_size  = 2
      #capacity_type = "SPOT"
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy          = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
        AmazonElasticFileSystemFullAccess = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
        ElasticLoadBalancingFullAccess = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
      }
      #EKS takes AWS Linux 2 as it's OS to the nodes
      key_name = aws_key_pair.eks.key_name
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  tags = var.comman_tags
}
