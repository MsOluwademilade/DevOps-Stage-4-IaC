
## Microservices TODO Application Infrastructure

This repository contains Infrastructure-as-Code (IaC) and Configuration Management tools to automatically provision and configure the infrastructure required for deploying the Microservices TODO Application.

## Step-by-Step Tutorial

### Prerequisites

Before you begin, ensure you have the following installed on your local machine:
- Terraform (>= 0.13.0)
- Ansible (>= 2.9.0)
- AWS CLI
- Git

### 1. AWS Configuration

1. **Configure AWS CLI credentials**:
   ```bash
   aws configure
   ```
   Enter your AWS Access Key ID, Secret Access Key, default region, and output format.

2. **Generate an SSH key pair locally**:
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/your-ssh-key
   ```
   This will create two files:
   - `~/.ssh/your-ssh-key` (private key)
   - `~/.ssh/your-ssh-key.pub` (public key)

3. **Set proper permissions for your private key**:
   ```bash
   chmod 400 ~/.ssh/your-ssh-key
   ```

4. **Import the key pair to AWS**:
   ```bash
   aws ec2 import-key-pair --key-name your-ssh-key --public-key-material fileb://~/.ssh/your-ssh-key.pub
   ```
   
   Alternatively, you can import the key through the AWS Console:
   - Go to the AWS Console > EC2 > Key Pairs
   - Click "Import key pair"
   - Name it `your-ssh-key`
   - Upload the public key file (`~/.ssh/your-ssh-key.pub`)

### 2. Clone the Repository

```bash
git clone https://github.com/MsOluwademilade/DevOps-Stage-4-IaC.git
cd DevOps-Stage-4-IaC
```

### 3. Update Configuration Files

1. **Update domain name and email**:
   Edit `ansible/roles/deployment/tasks/main.yml` and update the domain and email in the `.env` file creation task:
   ```yaml
   - name: Create .env file for environment variables
     copy:
       dest: /opt/todo-app/.env
       content: |
         DOMAIN=yourdomain.com
         EMAIL=your-email@example.com
   ```

2. **Verify SSH key path in inventory template**:
   Make sure the path in `terraform/inventory.tpl` matches your SSH key location:
   ```
   [app_server]
   ${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/your-ssh-key ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
   ```

### 4. Deploy Infrastructure and Application

1. **Initialize Terraform**:
   ```bash
   cd terraform
   terraform init
   ```

2. **Review the Terraform plan (optional)**:
   ```bash
   terraform plan
   ```

3. **Apply the Terraform configuration**:
   ```bash
   terraform apply -auto-approve
   ```

   This single command will:
   - Provision an EC2 instance with required security groups
   - Wait for the instance to be ready
   - Generate an Ansible inventory file
   - Run Ansible to install dependencies and deploy the application

4. **Note the output**:
   Terraform will output the public IP address of your EC2 instance. Save this for future reference.

### 5. Access Your Application

1. **Configure DNS (if using a custom domain)**:
   - Go to your domain registrar
   - Create an A record pointing to the EC2 instance IP address

2. **Wait for DNS propagation** (may take up to 24-48 hours)

3. **Access your application**:
   - Frontend: `https://yourdomain.com`
   - Auth API: `https://yourdomain.com/api/auth`
   - Todos API: `https://yourdomain.com/api/todos`
   - Users API: `https://yourdomain.com/api/users`

### 6. Cleanup Resources (when finished)

To avoid incurring costs, remember to **destroy resources** when done:

```bash
cd terraform
terraform destroy -auto-approve
```

## Troubleshooting

If you encounter issues during deployment:

1. **SSH connection problems**:
   - Verify security group allows traffic on port 22
   - Ensure private key permissions are set to 400
   - Confirm key pair name in Terraform matches the imported key in AWS

2. **Application issues**:
   - SSH into the EC2 instance:
     ```bash
     ssh -i ~/.ssh/your-ssh-key ubuntu@<instance-ip>
     ```
   - Check Docker Compose logs:
     ```bash
     cd /opt/todo-app
     docker-compose logs
     ```

3. **Terraform errors**:
   - Check error messages and fix related configuration files
   - Run `terraform init` again if you've modified providers
   - Review AWS credentials and ensure they have proper permissions

## Project Structure

```
├── README.md                           # This documentation
├── ansible/                            # Ansible configuration
│   ├── playbook.yml                    # Main playbook
│   └── roles/                          # Roles for organizing tasks
│       ├── dependencies/               # Role for installing dependencies
│       │   └── tasks/
│       │       └── main.yml            # Docker and required packages installation
│       └── deployment/                 # Role for deploying the application
│           └── tasks/
│               └── main.yml            # Repository cloning and application deployment
└── terraform/                          # Terraform configuration
    ├── inventory.tpl                   # Template for Ansible inventory
    ├── main.tf                         # Main infrastructure configuration
    ├── outputs.tf                      # Output definitions
    └── variables.tf                    # Variable definitions
```
