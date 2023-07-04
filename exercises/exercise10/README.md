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

#### Codify Infrastructure Requirements

To provision infrastructure using the Terraform CDK, update the newly generated **main.ts** Typescript file with your own infrastructure code.

The following TypeScript example demonstrates how to create a new VPC, Subnet, Security Group, and EC2 Instance:

```
import { Construct } from 'constructs';
import { App, TerraformStack, TerraformOutput } from 'cdktf';
import { AwsProvider, AwsProviderDefaultTags } from '@cdktf/provider-aws/lib/provider';
import { Vpc } from '@cdktf/provider-aws/lib/vpc';
import { Subnet } from '@cdktf/provider-aws/lib/subnet';
import { SecurityGroup } from '@cdktf/provider-aws/lib/security-group';
import { Instance } from '@cdktf/provider-aws/lib/instance';

class CloudAcademyDevOpsStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // Global tags
    const tags: AwsProviderDefaultTags[] = [
      {
        tags: {
          'environment': 'cloudacademydevops',
        },
      },
    ];

    // AWS Provider
    new AwsProvider(this, 'aws-provider', {
      region: 'us-east-2',
      defaultTags: tags
    });

    // Create a VPC
    const vpc = new Vpc(this, 'cloudacademy', {
      cidrBlock: '10.0.0.0/16',
    });

    // Create a subnet
    const subnet = new Subnet(this, 'private', {
      vpcId: vpc.id,
      cidrBlock: '10.0.0.0/24',
    });

    // Example Security Group
    const securityGroup = new SecurityGroup(this, 'allow-all', {
      name: 'cloudacademy-allow-all',
      vpcId: vpc.id,
      description: 'Allow all security group',
      ingress: [
        {
          fromPort: 0,
          toPort: 0,
          protocol: '-1',
          selfAttribute: true,
        },
      ],
      egress: [
        {
          fromPort: 0,
          toPort: 0,
          protocol: '-1',
          cidrBlocks: ['0.0.0.0/0'],
        },
      ],
      tags: {
        Name: 'cloudacademy-allow-all',
      },
    });

    const ami = 'ami-08e6b682a466887dd';
    const instanceType = 't4g.micro';

    // EC2 Instance
    var instance1 = new Instance(this, 'cloudacademy-01', {
      ami: ami,
      instanceType: instanceType,
      subnetId: subnet.id,
      securityGroups: [securityGroup.id],
    });

    new TerraformOutput(this, "cloudacademy-01-ip", {
      value: instance1.privateIp,
    });
  }
}

const app = new App();
new CloudAcademyDevOpsStack(app, 'cdktf-example');
app.synth();
```

#### Codify Infrastructure Deployment

To provision the codifed infrastructure run the following command:

```
cdktf deploy
```

#### Infrastructure Destroy

Remember to teardown/destroy any environments created when no longed needed. To perform a teardown, run the following command

```
cdktf destroy
```