SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Deploy to Cloud Run
gcloud run deploy $TF_VAR_APP_CLOUD_RUN_NAME \
    --project=$TF_VAR_GCP_PROJECT_ID \
    --source "$SCRIPT_DIR" \
    --allow-unauthenticated \
    --region $TF_VAR_APP_CLOUD_RUN_REGION \
    --concurrency 80 \
    --cpu 1 \
    --memory 256M \
    --max-instances 3 \
    --min-instances 0 \
    --platform managed \
    --timeout 30 \
    --vpc-connector="$TF_VAR_GCP_PROJECT_ID-vpc-connector" \
    --vpc-egress=all-traffic
