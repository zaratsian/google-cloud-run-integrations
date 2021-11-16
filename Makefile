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
	compute.googleapis.com \
	redis.googleapis.com \
	vpcaccess.googleapis.com

configure-cloudsql:
	@terraform init
	@terraform apply

set-cloudsql-password:
	@gcloud sql users set-password ${TF_VAR_CLOUDSQL_USERNAME} --instance ${TF_VAR_CLOUDSQL_INSTANCE_NAME} --prompt-for-password

set-cloudsql-iam-policy:
	@gcloud projects add-iam-policy-binding ${TF_VAR_GCP_PROJECT_ID} \
  	--member="serviceAccount:${TF_VAR_GCP_PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  	--role="roles/cloudsql.client"

set-redis-iam-policy:
	@gcloud projects add-iam-policy-binding ${TF_VAR_GCP_PROJECT_ID} \
  	--member="serviceAccount:${TF_VAR_GCP_PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  	--role="roles/cloudsql.client"

cloud-run-build:
	@gcloud run deploy run-sql --source . \
	--region us-central1 \
	--platform managed \
    --allow-unauthenticated \
  	--add-cloudsql-instances zproject201807:us-central1:example-mysql-dcee \
  	--set-env-vars INSTANCE_CONNECTION_NAME="zproject201807:us-central1:example-mysql-dcee" \
  	--set-env-vars CLOUD_SQL_CONNECTION_NAME="zproject201807:us-central1:example-mysql-dcee" \
  	--set-env-vars DB_NAME="default" \
  	--set-env-vars DB_USER="default" \
  	--set-env-vars DB_PASS="zpassword123" \
    --set-env-vars REDIS_HOST=10.102.40.131 \
	--set-env-vars REDIS_PORT=6379 \
	--vpc-connector us-central1-vpc-connector