# Container Image Tag
CONTAINER_TAG=${TF_VAR_GCP_REGION}-docker.pkg.dev/${TF_VAR_GCP_PROJECT_ID}/${TF_VAR_ARTIFACT_REPO_NAME}/${TF_VAR_APP_CLOUD_RUN_NAME}:latest

# Deploy container to cloud run
gcloud run deploy ${TF_VAR_APP_CLOUD_RUN_NAME} \
    --project=${TF_VAR_GCP_PROJECT_ID} \
    --region ${TF_VAR_APP_CLOUD_RUN_REGION} \
    --image ${CONTAINER_TAG}
    --allow-unauthenticated \
    --concurrency 80 \
    --min-instances 0 \
    --max-instances 3 \
    --cpu 1 \
    --memory 256M \
    --platform managed \
    --timeout 30 \
  	--add-cloudsql-instances ${TF_VAR_GCP_PROJECT_ID}:${TF_VAR_GCP_REGION}:${TF_VAR_CLOUDSQL_INSTANCE_NAME} \
  	--set-env-vars INSTANCE_CONNECTION_NAME="${TF_VAR_GCP_PROJECT_ID}:${TF_VAR_GCP_REGION}:${TF_VAR_CLOUDSQL_INSTANCE_NAME}" \
  	--set-env-vars CLOUDSQL_INSTANCE_NAME=${TF_VAR_CLOUDSQL_INSTANCE_NAME} \
    --set-env-vars GCP_PROJECT_ID=${TF_VAR_GCP_PROJECT_ID} \
    --set-env-vars GCP_REGION=${TF_VAR_GCP_REGION} \
  	--set-env-vars CLOUDSQL_DB_NAME=${TF_VAR_CLOUDSQL_DB_NAME} \
  	--set-env-vars CLOUDSQL_USERNAME=${TF_VAR_CLOUDSQL_USERNAME} \
  	--set-env-vars CLOUDSQL_USERPASS=${TF_VAR_CLOUDSQL_USERPASS} \
    --set-env-vars REDIS_HOST=${REDIS_HOST} \
	--set-env-vars REDIS_PORT=${REDIS_PORT}# \
	#--vpc-connector us-central1-vpc-connector
