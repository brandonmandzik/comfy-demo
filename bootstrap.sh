#!/bin/bash
set -e

# Log everything to user-data log file
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting ComfyUI installation at $(date) ==="

# Update system and install dependencies
echo "Updating system packages..."
apt-get update
# Wait for dpkg lock to be released (handles unattended-upgrades)
echo "Waiting for dpkg lock to be available..."
while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Waiting for other package managers to finish..."
  sleep 5
done
apt-get install -y git python3 python3-venv python3-pip

# Install as ubuntu user
cd /home/ubuntu

# Clone ComfyUI
echo "Cloning ComfyUI repository..."
sudo -u ubuntu git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI

# Create virtual environment
echo "Creating Python virtual environment..."
sudo -u ubuntu python3 -m venv venv

# Install PyTorch and ComfyUI dependencies
echo "Installing PyTorch with CUDA support..."
sudo -u ubuntu bash -c "source venv/bin/activate && \
  pip install --upgrade pip && \
  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 && \
  pip install -r requirements.txt"

# Create systemd service for ComfyUI
echo "Creating systemd service..."
cat > /etc/systemd/system/comfyui.service <<'EOF'
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/ComfyUI
Environment="PATH=/home/ubuntu/ComfyUI/venv/bin"
ExecStart=/home/ubuntu/ComfyUI/venv/bin/python main.py --listen 0.0.0.0 --port 8188
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start ComfyUI service
echo "Enabling and starting ComfyUI service..."
systemctl daemon-reload
systemctl enable comfyui.service
systemctl start comfyui.service

# Wait a moment and check status
sleep 5
systemctl status comfyui.service || true

echo "=== ComfyUI installation complete at $(date) ==="
echo "ComfyUI should be accessible at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8188"
echo "Check service status with: sudo systemctl status comfyui"
echo "View logs with: sudo journalctl -u comfyui -f"
