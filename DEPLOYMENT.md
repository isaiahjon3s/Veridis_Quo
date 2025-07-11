# Veridis Quo - Deployment Guide

## Prerequisites

1. **AWS Account** - You'll need an AWS account
2. **EC2 Instance** - Amazon Linux 2 instance
3. **Domain Name** - Free domain from Freenom or similar

## Step 1: Launch EC2 Instance

1. Go to AWS Console → EC2
2. Click "Launch Instance"
3. Choose "Amazon Linux 2" (free tier eligible)
4. Select t2.micro (free tier)
5. Configure Security Group:
   - HTTP (80) - Anywhere
   - HTTPS (443) - Anywhere
   - SSH (22) - Your IP
6. Launch and download your key pair (.pem file)

## Step 2: Connect to Your Server

```bash
# Make key file executable
chmod 400 your-key.pem

# Connect to server
ssh -i your-key.pem ec2-user@your-server-ip
```

## Step 3: Upload Your Application

### Option A: Using SCP
```bash
# From your local machine
scp -i your-key.pem -r . ec2-user@your-server-ip:/home/ec2-user/veridis-quo
```

### Option B: Using Git
```bash
# On your server
cd /home/ec2-user
git clone your-repository-url veridis-quo
```

## Step 4: Deploy the Application

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

## Step 5: Get a Free Domain

### Option A: Freenom (Recommended)
1. Go to [freenom.com](https://www.freenom.com)
2. Search for available domains (.tk, .ml, .ga, .cf, .gq)
3. Register your free domain
4. Point DNS to your EC2 public IP

### Option B: Cloudflare
1. Go to [cloudflare.com](https://www.cloudflare.com)
2. Add your site
3. Use Cloudflare's free DNS service

### Option C: AWS Route 53 (Paid)
1. Go to Route 53 in AWS Console
2. Register a domain (paid)
3. Create hosted zone
4. Point to your EC2 instance

## Step 6: Configure DNS

### For Freenom:
1. Go to your domain management
2. Set A record to your EC2 public IP
3. Wait 24-48 hours for propagation

### For Cloudflare:
1. Add A record: `@` → your EC2 IP
2. Enable Cloudflare proxy (orange cloud)
3. Propagation takes 5-10 minutes

## Step 7: SSL Certificate (Optional but Recommended)

### Using Let's Encrypt:
```bash
# Install certbot
sudo yum install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d yourdomain.com

# Auto-renewal
sudo crontab -e
# Add: 0 12 * * * /usr/bin/certbot renew --quiet
```

## Step 8: Verify Deployment

1. Check if services are running:
```bash
sudo systemctl status veridis-quo
sudo systemctl status nginx
```

2. Test your website:
```bash
curl http://localhost
curl http://your-domain.com
```

## Troubleshooting

### Check logs:
```bash
# Flask app logs
sudo journalctl -u veridis-quo -f

# Nginx logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Common issues:
1. **Port 5000 not accessible**: Check firewall settings
2. **Domain not resolving**: Wait for DNS propagation
3. **SSL issues**: Check certbot logs

## Maintenance

### Update application:
```bash
cd /home/ec2-user/veridis-quo
git pull
source venv/bin/activate
pip install -r requirements.txt
sudo systemctl restart veridis-quo
```

### Update system:
```bash
sudo yum update -y
```

## Security Notes

1. **Keep your EC2 instance updated**
2. **Use strong SSH keys**
3. **Consider using AWS Security Groups**
4. **Regular backups of your application**
5. **Monitor logs for suspicious activity**

## Cost Estimation

- **EC2 t2.micro**: Free tier (750 hours/month)
- **Domain**: Free (Freenom) or $10-15/year
- **SSL**: Free (Let's Encrypt)
- **Total**: $0-15/year depending on domain choice

Your website should now be live at `http://your-domain.com`! 