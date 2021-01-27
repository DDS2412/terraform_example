# Отображение присвоенного публичного ip в консоли после выполнения terraform apply
output "server_ip" {
  value = aws_eip.test-ip.public_ip
}