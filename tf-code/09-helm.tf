provider "helm" {
  kubernetes {
    #host                   = aws_eks_cluster.cluster.endpoint
    host = module.eks.cluster_endpoint
    # cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
      command     = "aws"
    }
  }
}

resource "helm_release" "aws-load-balancer-controller" {
  name = "aws-load-balancer-controller"

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.4.8"

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "image.tag"
    value = "v2.4.7"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller.arn
  }

  depends_on = [
    #aws_eks_node_group.private-nodes,
    aws_iam_role_policy_attachment.aws_load_balancer_controller_attach
  ]
}