#!/bin/bash

# Update system
sudo yum update -y

# Install Python 3 and pip
sudo yum install -y python3 python3-pip

# Install nginx
sudo yum install -y nginx

# Create application directory
mkdir -p /home/ec2-user/veridis-quo
cd /home/ec2-user/veridis-quo

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Copy service file
sudo cp veridis-quo.service /etc/systemd/system/

# Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable veridis-quo
sudo systemctl start veridis-quo

# Configure nginx
sudo tee /etc/nginx/conf.d/veridis-quo.conf > /dev/null <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Start nginx
sudo systemctl enable nginx
sudo systemctl start nginx

# Configure firewall
sudo yum install -y firewalld
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload

echo "Deployment completed! Your Flask app should be running on port 80." 