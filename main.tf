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

resource "google_sql_database_instance" "instance" {
  name                 = "${var.CLOUDSQL_INSTANCE_NAME}"
  project              = "${var.GCP_PROJECT_ID}"
  region               = "${var.GCP_REGION}"
  database_version     = "${var.CLOUDSQL_DB_VERSION}"
  
  settings {
    tier            = "${var.CLOUDSQL_TIER}"
    disk_autoresize = "${var.CLOUDSQL_DISK_AUTORESIZE}"
    
    ip_configuration {
      ipv4_enabled    = true
      private_network = null
      require_ssl     = null
    }
    
    disk_size         = "${var.CLOUDSQL_DISK_SIZE}"
    disk_type         = "PD_SSD"
    availability_type = "ZONAL"
  }

}

resource "google_sql_database" "sqldatabase" {
  project  = "${var.GCP_PROJECT_ID}"
  name     = "${var.CLOUDSQL_DB_NAME}"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "sqluser" {
  project  = "${var.GCP_PROJECT_ID}"
  name     = "${var.CLOUDSQL_USERNAME}"
  host     = "${var.CLOUDSQL_HOST}"
  instance = google_sql_database_instance.instance.name
}

resource "google_redis_instance" "memorystore_redis_instance" {
  name           = "${var.REDIS_INSTANCE_NAME}"
  tier           = "BASIC"
  memory_size_gb = 2
  region         = "${var.GCP_REGION}"
  redis_version  = "REDIS_5_0"
}