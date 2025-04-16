## 🚀 What It Does

1. **Terraform**:
   - Provisions VPC, public/private subnets, NAT, IGW
   - Creates IAM roles (including IRSA for EBS CSI)
   - Deploys EKS cluster and PostgreSQL RDS database
   - Configures Security Groups and required networking

2. **Helm (Airflow)**:
   - Deploys Apache Airflow into a dedicated namespace
   - Uses internal PostgreSQL for metadata DB
   - Exposes the web UI via LoadBalancer

3. **DAG (ETL Pipeline)**:
   - Calls a dummy JSON API
   - Transforms the data (name, email, address normalization)
   - Inserts the results into the RDS PostgreSQL DB

---

## ⚙️ Usage

```bash
# Initialize Terraform
terraform init

# Apply infrastructure (with vars)
terraform apply -var-file="prod.tfvars"

# Install Helm chart
helm install airflow apache-airflow/airflow -n airflow -f airflow/values.yaml --create-namespace
