resource "scaleway_k8s_cluster" "bad" {
  name                        = "k8s-bad"
  version                     = "1.32.3"
  cni                         = "calico"
  delete_additional_resources = false
}
