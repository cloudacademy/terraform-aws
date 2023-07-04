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