# [DEMO] Installing OpenVPN Server on AWS using terraform

- [Infrastructure Diagram](docs/infrastructure-digagram.drawio.pdf)
- 

## Introduction



## Requirements

- make
- terraform
- python3

## How to launch my OpenVPN server using this repository

### First Step

### Second Step

### Third Step

//TODO


aws ecr get-login-password --region eu-south-2 | docker login --username AWS --password-stdin XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com

docker build -t kaira-ecr .

docker tag kaira-ecr:latest XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest

docker push XXXXXXXXXXXX.dkr.ecr.eu-south-2.amazonaws.com/kaira-ecr:latest