# Create a iam policy (allow-eks-access)
module "allow_eks_access_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-eks-access"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:DescribeCluster",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


# Create iam role (eks-admin) that uses the policy - allow-eks-access
module "eks_admins_iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.3.1"

  role_name         = "eks-admin"
  create_role       = true
  role_requires_mfa = false

  custom_role_policy_arns = [module.allow_eks_access_iam_policy.arn]

  trusted_role_arns = [
    "arn:aws:iam::${module.vpc.vpc_owner_id}:root"
  ]
}

# Create a policy to assume the (eks_admin) role
module "allow_assume_eks_admins_iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "5.3.1"

  name          = "allow-assume-eks-admin-iam-role"
  create_policy = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Resource = module.eks_admins_iam_role.iam_role_arn
      },
    ]
  })
}

# Create an iam user (judah)
# module "judah_iam_user" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-user"
#   version = "5.3.1"

#   name                          = "judah"
#   create_iam_access_key         = false
#   create_iam_user_login_profile = false

#   force_destroy = true
# }

# get current user
data "aws_iam_user" "current_user" {
  user_name = "terraform"
}

# Create a group (eks-admin) that assumes the role (eks-admin) and add judah to it
module "eks_admins_iam_group" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-group-with-policies"
  version = "5.3.1"

  name                              = "eks-admin"
  attach_iam_self_management_policy = false
  create_group                      = true
  # group_users                       = [module.judah_iam_user.iam_user_name, data.aws_iam_user.current_user.user_name]
  group_users              = [data.aws_iam_user.current_user.user_name]
  custom_group_policy_arns = [module.allow_assume_eks_admins_iam_policy.arn]
}


output "eks_admins_iam_role" {
  description = "IAM role ARN of Judah Role"
  value       = module.eks_admins_iam_role.iam_role_arn
}
