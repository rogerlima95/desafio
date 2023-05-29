# desafio
Neste repositório foi criado uma aplicação simples com Python e Flask e automações para executa-la localmente ou dentro de um ambiente da aws.
Localmente o docker compose irá buildar uma imagem docker com a aplicação e rodar expondo ela na porta 80 do seu localhost.
Já para o ambiente da aws o terraform ira provisionar uma vpc, três subnets (public,private e intra), um eks com um node group de 3 máquinas um ecr, irá publicar a imagem docker no ecr e utilizar essa imagem com a aplicação dentro do deployment do kubernetes.

#### Rodar Localmente

## Pré requisitos

- Docker >= 23.0.25

## Execução 

Dentro do diretório app execute o comando abaixo: 

```bash
docker compose up
```

#### Rodar em um ambiente na aws

Para configurar o ambiente da aws será necessário dois passos. 
O primeiro irá provisionar a vpc e o eks, o ecr e publicar a imagem docker.
O segundo irá criar os manifestos dentro do eks.

## Pré requisitos

- Terraform >= 1.2.7
- AWS CLI >= 2.4.16 (configurado)

## Execução 

### Passo 1 
Acesse o diretório terraform/environment/config e execute os comandos do terraform:

```bash
cd terraform/environment/config
terraform init
terraform plan
terraform apply
```

### Passo 2 
cd terraform/environment/deploy 
terraform init
terraform plan
terraform apply