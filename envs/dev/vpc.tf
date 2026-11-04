# Reseau dedie sur deux zones, via le module standard du registre public
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "novasphere-${var.environment}"
  cidr = "10.0.0.0/16"

  azs            = ["us-east-1a", "us-east-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]

  # Pas de NAT Gateway (facturee a l'heure) : les instances sortent par l'Internet Gateway
  enable_nat_gateway = false

  # IP publique au lancement : sans elle, pas d'acces Internet, donc pas d'installation de nginx
  map_public_ip_on_launch = true
}
