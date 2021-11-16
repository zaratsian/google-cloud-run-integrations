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

Google Cloud SQL Resources

*******************************************************/

resource "google_sql_database_instance" "instance" {
  name             = "private-instance-${random_id.db_name_suffix.hex}"
  region           = "${var.GCP_REGION}"
  database_version = "POSTGRES_13"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
  }

  deletion_protection  = "false"
}

resource "google_sql_database" "database" {
  name     = "zdb"
  instance = google_sql_database_instance.instance.name
}

resource "google_compute_network" "private_network" {
  provider = google-beta

  name = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

/******************************************************

Cloudrun VPC Access Connector

*******************************************************/

resource "google_project_service" "vpcaccess_api" {
  service  = "vpcaccess.googleapis.com"
  provider = google-beta
  disable_on_destroy = false
}

# VPC
resource "google_compute_network" "default" {
  name                    = "cloudrun-network"
  provider                = google-beta
  auto_create_subnetworks = false
}

# VPC access connector
resource "google_vpc_access_connector" "connector" {
  name          = "${var.GCP_REGION}-vpc-connector"
  provider      = google-beta
  region        = "${var.GCP_REGION}"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.default.name
  depends_on    = [google_project_service.vpcaccess_api]
}

# Cloud Router
resource "google_compute_router" "router" {
  name     = "router"
  provider = google-beta
  region   = "${var.GCP_REGION}"
  network  = google_compute_network.default.id
}

# NAT configuration
resource "google_compute_router_nat" "router_nat" {
  name                               = "nat"
  provider                           = google-beta
  region                             = "${var.GCP_REGION}"
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}

/******************************************************

App - Deployed on Cloud Run

*******************************************************/
/*
resource "google_cloud_run_service" "gcr_service" {
  name     = "mygcrservice"
  provider = google-beta
  location = "${var.GCP_REGION}"

  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"
        resources {
          limits = {
            cpu = "1000m"
            memory = "256M"
          }
        }
      }
      # the service uses this SA to call other Google Cloud APIs
      # service_account_name = myservice_runtime_sa
    }

    metadata {
      annotations = {
        # Limit scale up to prevent any cost blow outs!
        "autoscaling.knative.dev/maxScale" = "2"
        # Use the VPC Connector
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.name
        # all egress from the service should go through the VPC Connector
        "run.googleapis.com/vpc-access-egress" = "all"
      }
    }
  }
  autogenerate_revision_name = true
}
*/
