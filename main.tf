terraform {
  required_providers {
    google = {
      source = "google"
      version = "~> 3.84"
    }
    google-beta = {
      source = "google-beta"
      version = "~> 3.84"
    }
  }
}

/******************************************************

Enable Google Cloud Services

*******************************************************/

variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "storage.googleapis.com",
	"run.googleapis.com",
	"container.googleapis.com",
	"containerregistry.googleapis.com",
	"artifactregistry.googleapis.com",
	"cloudbuild.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = "${var.GCP_PROJECT_ID}"
  service = each.key
}

/******************************************************

Google Cloud Run

*******************************************************/
resource "google_cloud_run_service" "default" {
  name     = "cloudrun-srv"
  location = "us-central1"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
      }
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.instance.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }
  autogenerate_revision_name = true
}

resource "google_sql_database_instance" "instance" {
  name             = "cloudrun-sql"
  region           = "us-east1"
  database_version = "MYSQL_5_7"
  settings {
    tier = "db-f1-micro"
  }

  deletion_protection  = "true"
}