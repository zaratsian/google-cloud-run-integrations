# Load Config
include ./config.default

enable-gcp-apis:
	gcloud services enable \
	run.googleapis.com \
	container.googleapis.com \
	containerregistry.googleapis.com \
	cloudbuild.googleapis.com \
	servicenetworking.googleapis.com \
	sqladmin.googleapis.com \
	compute.googleapis.com

cloud-run-build:
	@gcloud builds submit --tag gcr.io/zproject201807/run-sql
	@gcloud run deploy run-sql --image gcr.io/zproject201807/run-sql
	@gcloud run services update run-sql \
    --add-cloudsql-instances zproject201807:us-central1:private-instance-f6ad0b00 \
    --set-env-vars INSTANCE_CONNECTION_NAME=zproject201807:us-central1:private-instance-f6ad0b00,DB_USER=danz,DB_PASS=zpassword123,DB_NAME=zdb