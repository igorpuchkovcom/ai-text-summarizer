# AI-Text-Summarizer

AI-Text-Summarizer is a service for automatic text summarization using machine learning. The project is deployed on **Google Kubernetes Engine (GKE)** and supports **CI/CD via GitHub Actions**.

## 🚀 Key Features
- 📖 **Text Summarization** – Generate concise summaries of long texts using AI models.
- 🏗 **Runs on Kubernetes** – Deployed via Google Cloud GKE with Terraform.
- 🔄 **Automated CI/CD** – Uses GitHub Actions for seamless deployment.
- 🐳 **Docker Image** – Hosted on **Docker Hub**.
- ☁ **Google Cloud Infrastructure** – Uses GCP services for scalability.

## 📦 Tech Stack
- **Python** (FastAPI, Transformers)
- **Docker** (Containerization)
- **Kubernetes (GKE)** (Orchestration)
- **Terraform** (Infrastructure as Code)
- **GitHub Actions** (CI/CD)
- **Google Cloud Platform (GCP)** (Hosting)

## 📂 Installation & Local Setup

**Run using Docker Compose:**
```bash
docker-compose up --build
```
The application will be available at `http://localhost:8000`.

## 🚀 Deploying to Kubernetes (GKE)

### 1️⃣ Set up Google Cloud Authentication
```bash
gcloud auth activate-service-account --key-file=your-key.json
gcloud config set project YOUR_GCP_PROJECT_ID
```

### 2️⃣ Connect to GKE
```bash
gcloud container clusters get-credentials text-summarizer-cluster --region us-central1
```

### 3️⃣ Deploy the application in GKE
```bash
kubectl apply -f k8s/
```

### 4️⃣ Get external IP for API
```bash
kubectl get services
```

### 5️⃣ Test the API
```bash
curl -X POST "http://EXTERNAL-IP/summarize" -H "Content-Type: application/json" -d '{"text": "Test text"}'
```

## 🔄 Automated Deployment (CI/CD)
With each `git push` to `main`, **GitHub Actions**:
1. Builds a new Docker image and pushes it to **Docker Hub**.
2. Deploys the application to **Google Kubernetes Engine (GKE)** using Terraform.

## 📜 Terraform Infrastructure

The infrastructure is defined using **Terraform** and includes:
- **Google Kubernetes Engine (GKE) Cluster**
- **Node Pool Configuration**
- **Kubernetes Services (LoadBalancer, Deployment, Ingress)**
- **Terraform State stored in Google Cloud Storage (GCS)**

### Setting up Terraform Backend
```bash
terraform init -backend-config="bucket=YOUR_TF_STATE_BUCKET" -backend-config="prefix=terraform/state"
```

### Running Terraform
```bash
terraform plan -var="project_id=YOUR_GCP_PROJECT_ID" -var="region=us-central1"
terraform apply -auto-approve
```

## 📜 Project Structure
```
├── app/                   # FastAPI application
│   ├── main.py            # API routes
│   ├── model.py           # Summarization model
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml    # Deployment spec
│   ├── service.yaml       # LoadBalancer service
│   ├── ingress.yaml       # Ingress config
├── .github/workflows/      # CI/CD GitHub Actions
│   ├── ci-cd.yml          # Build & Deployment Workflow
├── Dockerfile             # Docker build file
├── docker-compose.yml     # Local development setup
├── main.tf                # Terraform configuration
└── wait-for-terraform-unlock.sh # Terraform state unlock script
```

## 🛠 Future Enhancements
- ✅ Add authentication to API
- ✅ Support for multiple summarization models
- ✅ Implement caching for API responses

