output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.comfyui.id
}

output "public_ip" {
  description = "Public IP address of the ComfyUI instance"
  value       = aws_instance.comfyui.public_ip
}

output "comfyui_url" {
  description = "ComfyUI web interface URL"
  value       = "http://${aws_instance.comfyui.public_ip}:8188"
}

output "ssh_command" {
  description = "SSH connection command"
  value       = var.key_name != null ? "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.comfyui.public_ip}" : "No SSH key configured - set key_name variable to enable SSH"
}

output "status_check_command" {
  description = "Command to check ComfyUI service status (run after SSH)"
  value       = "sudo systemctl status comfyui"
}
