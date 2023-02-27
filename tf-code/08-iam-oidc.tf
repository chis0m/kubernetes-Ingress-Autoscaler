# Get TLS certificate from EKS
# data "tls_certificate" "eks" {
#   #url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   url = module.eks.cluster_oidc_issuer_url
# }

# Create provider
# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   #url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
#   url = module.eks.cluster_oidc_issuer_url
# }