# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Scenario
Your company's development team has created an application that they need deployed to Azure. The application is self-contained, but they need the infrastructure to deploy it in a customizable way based on specifications provided at build time, with an eye toward scaling the application for use in a CI/CD pipeline.

Although Azure App Service could be used, management has said that <u>the cost is too high for a PaaS like that</u> and wants it to be deployed as pure IaaS so we can control cost. Since they expect this to be a popular service, it should be deployed across <b>multiple virtual machines</b>.

To support this need and minimize future work, <b> Packer will be used to create a server image</b>, and <b>Terraform to create a template for deploying a scalable cluster of servers - with a load balancer to manage the incoming traffic</b>. Moreover, the infrastructure will be secured <b>by applying security best practices</b>.

#### Main Steps
The project will consist of the following main steps:

1. Creating a Packer template
2. Creating a Terraform template
3. Deploy a policy that denies the creation of resources that do not have tags
4. Deploying the infrastructure
5. Creating documentation in the form of a README

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install and configure [Packer](https://www.packer.io/downloads)
4. Install and configure [Terraform](https://www.terraform.io/downloads.html)

### Instructions
1. Login to your Azure Account via Azure CLI
2. Create a policy definition that denies the creation of resources without tag
    a. Deploy the policy with `az policy definition create --name tagging-policy --rules tagging-policy.rules.json` from within the directory where the Policy file is stored
    b. Assign the policy with `az policy assignment create --policy tagging-policy`. The output should be similar to the following screenshot

![Tagging-Policy](tagging-policy.png)

3. ...

### Output
**Your words here**

### License
MIT © [philbier]()