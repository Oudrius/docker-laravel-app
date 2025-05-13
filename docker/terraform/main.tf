terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }
}

provider "google-beta" {
  project = "example-app-459611"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_project_service" "run_api" {
  project = "example-app-459611"
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_sql_database_instance" "instance" {
  project = "example-app-459611"
  name             = "example-app-db-instance"
  region           = "us-central1"
  database_version = "POSTGRES_15"
  settings {
    tier = "db-f1-micro"
  }

  deletion_protection = false
}

resource "google_sql_database" "database" {
  project = "example-app-459611"
  name     = "example-app-db"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  project = "example-app-459611"
  name     = "example-app-admin"
  instance = google_sql_database_instance.instance.name
  password = "test"
}

resource "google_cloud_run_service" "example-app" {
  name     = "example-app"
  location = "us-central1"
  provider = google-beta

  template {
    metadata {
      annotations = {
        "run.googleapis.com/container-dependencies" = jsonencode({ "caddy" = ["laravel"] })
      }
    }
    spec {
      containers {
        name  = "laravel"
        image = "gcr.io/example-app-459611/example-app:latest"
        env {
          name = "PORT"
          value = "9000"
        }
        startup_probe {
          tcp_socket {
            port = 9000
          }
          initial_delay_seconds = 5
          period_seconds        = 3
          timeout_seconds       = 3
          failure_threshold     = 5
        }

        volume_mounts {
          name       = "app-volume"
          mount_path = "/app"
        }
      }
      containers {
        name  = "caddy"
        image = "gcr.io/example-app-459611/caddy-example-app:latest"
        ports {
          container_port = 8080
          name = "http1"
        }

        volume_mounts {
          name       = "caddy-data"
          mount_path = "/data"
        }

        volume_mounts {
          name       = "caddy-config"
          mount_path = "/config"
        }

        volume_mounts {
          name       = "app-volume"
          mount_path = "/app"
        }
      }
      volumes {
        name = "app-volume"
        empty_dir {
          medium = "Memory"
          size_limit = "2280Mi"
        }
      }

      volumes {
        name = "caddy-data"
        empty_dir {
          medium = "Memory"
          size_limit = "128Mi"
        }
      }

      volumes {
        name = "caddy-config"
        empty_dir {
          medium = "Memory"
          size_limit = "128Mi"
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["run.googleapis.com/launch-stage"],
    ]
  }
}