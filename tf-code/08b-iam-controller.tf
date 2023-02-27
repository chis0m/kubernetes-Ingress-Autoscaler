# Allows EKS Service Account(SA) "aws-load-balancer-controller" to assume the role
# The SA is part of K8 RBAC which is authenticated against IAM through oidc
# This is why the assume policy is using web identity type
data "aws_iam_policy_document" "aws_load_balancer_controller_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test = "StringEquals"
      # variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      variable = "${replace(module.eks.oidc_provider, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    principals {
      # identifiers = [aws_iam_openid_connect_provider.eks.arn]
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

# The role to be assumed by the service account through oidc
resource "aws_iam_role" "aws_load_balancer_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_load_balancer_controller_assume_role_policy.json
  name               = "aws-load-balancer-controller"
}

# The policy attached to the role to be assumed
resource "aws_iam_policy" "aws_load_balancer_controller" {
  policy = file("./AWSLoadBalancerController.json")
  name   = "AWSLoadBalancerController"
}

# Attaching the policy
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_attach" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}