# Clean up old credentials
Remove-Item -Path "$env:APPDATA\gcloud" -Recurse -Force -ErrorAction SilentlyContinue

# Create fresh directory
New-Item -Path "$env:APPDATA\gcloud\legacy_credentials" -ItemType Directory -Force

# Set permissions
$acl = Get-Acl "$env:APPDATA\gcloud"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("$env:USERNAME","FullControl","Allow")
$acl.SetAccessRule($accessRule)
Set-Acl "$env:APPDATA\gcloud" $acl

# Initialize gcloud
Write-Host "Initializing gcloud..."
gcloud init --console-only

# Set up service account
$PROJECT_ID = "plucky-sector-458407-j1"
$SA_EMAIL = "github-actions@$PROJECT_ID.iam.gserviceaccount.com"

Write-Host "Creating service account..."
gcloud iam service-accounts create github-actions --display-name="GitHub Actions"

Write-Host "Granting permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/containerregistry.ServiceAgent"

Write-Host "Granting additional permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/artifactregistry.admin"

# Add Service Usage Admin role
gcloud projects add-iam-policy-binding $PROJECT_ID `
    --member="serviceAccount:$SA_EMAIL" `
    --role="roles/serviceusage.serviceUsageAdmin"

# Enable APIs (run as owner)
Write-Host "Enabling required APIs..."
gcloud auth login
gcloud config set project $PROJECT_ID
gcloud services enable containerregistry.googleapis.com
gcloud services enable artifactregistry.googleapis.com

Write-Host "Creating service account key..."
gcloud iam service-accounts keys create .\key.json --iam-account=$SA_EMAIL

Write-Host "Setup complete! Key file saved as key.json"
