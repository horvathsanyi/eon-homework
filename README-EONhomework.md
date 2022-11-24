# EON homework documentation

- First I pulled the project from the github repositor.

- Edit project realwolrd/config/settings/base.py to allow all hosts, because we want to deploy on Azure

- Created two Dockerfile for production and for local

- Ater that i used the Dockerfile.local everytime

- About the Dockerfiles, i know that i can make more secure and lightweight images with multistage builds, but this time i skipped this opportunity =(

- The port 8000 exposed in the image, but everytime i ran it i add "-p 8000:8000"

- I pushed the images to the public docker hub.

- I used the Azure CLI to authenticate myself and i used a Service Principal authentication too.

- I Choosed the Container App service to deploy the application, this can be accomplished with few clicks in the Azure portal.

- With terraform i had to use the AZAPI provider and AzureRM to create Container App

- If i initialize the working directory with terraform init and after i  use terraform apply, terraform automatically deploys de application into a Container APP service.
