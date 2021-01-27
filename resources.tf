# Разворачиваемые ресурсы

# Присвоение постоянного ip
resource "aws_eip" "test-ip" {
  instance = aws_instance.test-instance.id
}


# Получение через фильтр последнего ид имиджа
data "aws_ami" "latest_aws" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Пример инстанса
resource "aws_instance" "test-instance" {
  ami = data.aws_ami.latest_aws.id
  # Тариф инстанса
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.test-security-group.id]

  # Скрипт с параметрами, который выполнится при развертывании
  user_data = templatefile("test.sh.tpl", {
    f_name = "Danila",
    names = ["Dima", "Egor"]
  })

  # Развертывание нового инстанса до уничтожения старого
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "test-security-group" {
  name = "test-security-group"

  # Код, который генерируется в цикле с параметрами из списка
  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port = ingress.value
      to_port = ingress.value
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Входящий трафик
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Исходящий трафик
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}