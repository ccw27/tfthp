
# Description
This Terraform script will launch AWS VPC and EC2 instance with Nginx server running in Docker container,
you need an AWS account to run it.

# Discussion
Any comment please add a Pull Request or email ccwu27(at)gmail.com

# Require
1. AWS account with Access Key ID, and Secret Access Key
2. AWS ssh public and private key file
3. Terraform 1.0.0, Python 3.x

# Usage

1. Export aws key to environment variable

    ```
    export AWS_ACCESS_KEY_ID=[your access key ID]
    export AWS_SECRET_ACCESS_KEY=[your secret access key]


2. Copy your ssh public key to file 'sshkey.pub'


3. Init terraform environment

    ```
    terraform init


4. Run terraform script, when finish, ec2 instance public IP will be output

    ```
    terraform apply -auto-approve


**Note:**

        1. nginx container will run insider Docker
        2. container will self check healthiness (curl --fail -s http://localhost:80/ || exit 1), will restart if fail
        3. container resource usage is logged in instance's file '/var/log/syslog' every 10 minutes


5. Browse web page, display word frequency

    ```
    python html-to-freq.py [put in ec2 public IP from step 4]
