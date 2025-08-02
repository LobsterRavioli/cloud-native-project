provider "kubernetes" {
  config_path = "${path.module}/kubeconfig.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "${path.module}/kubeconfig.yaml"
  }
}



resource "kubernetes_namespace" "kiratech_test" {
  metadata {
    name = "kiratech-test"
  }
}


resource "kubernetes_job" "kube_bench" {
  metadata {
    name      = "kube-bench"
    namespace = kubernetes_namespace.kiratech_test.metadata[0].name
  }

  spec {
    template {
      metadata {}
      spec {
        restart_policy = "Never"
        host_pid       = true

        container {
          name  = "kube-bench"
          image = "aquasec/kube-bench:latest"

          args = ["--benchmark", "k3s-cis-1.7"]

          security_context {
            privileged = true
          }
        }
      }
    }
  }
}


resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  chart   = "${path.module}/../helm/kube-prometheus-stack"
  atomic  = true
  timeout = 600

  values = [
    file("${path.module}/../helm/kube-prometheus-stack/values.yaml") # se presente
  ]
}
