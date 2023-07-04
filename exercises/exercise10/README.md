### Exercise 10
An example of using the [Terraform CDK](https://developer.hashicorp.com/terraform/cdktf) and [TypeScript](https://www.typescriptlang.org/) to codify and provision new AWS infrastructure (VPC, Subnet, SecurityGroup, EC2 Instance).

#### Installation

The Terraform CDK must first be installed.

```
npm install --global cdktf-cli@latest
```

Further details regarding the installation are located here:
https://developer.hashicorp.com/terraform/tutorials/cdktf/cdktf-install#install-cdktf

#### Project Setup

Initialising a new project (empty) can be accomplised by running the following commands:

```
{
mkdir new-project && cd new-project
cdktf init --template="typescript" --providers="aws@>=5.0" --local
npm install
}
```

#### Infrastructure Deployment

To provision infrastructure using the Terraform CDK, update the newly generated **main.ts** Typescript file with your infrastructure code and then run the following command:

```
cdktf deploy
```

#### Infrastructure Destroy

Remember to teardown/destroy any environments created when no longed needed. To perform a teardown, run the following command

```
cdktf destroy
```