resource "aws_iam_instance_profile" "ec2-ssm-role-profile" {
  name = "${var.iam_prefix}-role-profile"
  role = aws_iam_role.ec2-ssm-role.name
}


resource "aws_iam_role" "ec2-ssm-role" {
  name               = "${var.iam_prefix}-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
}
EOF
}

# This is the same as the Amazon suppiled policy but could be tightened up a bit
resource "aws_iam_policy" "ec2-ssm-policy" {
  name        = "${var.iam_prefix}-policy"
  path        = "/"
  description = "Policy required by ssm to join domain"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Effect": "Allow",
            "Action": [
        	      "ssm:GetDeployablePatchSnapshotForInstance",
        	      "ssm:GetParameters",
        	      "ssm:ListInstanceAssociations",
        	      "ssm:PutInventory",
        	      "ssm:UpdateInstanceAssociationStatus",
        	      "ssm:DescribeAssociation",
		            "ssm:GetDocument",
		            "ssm:ListAssociations",
		            "ssm:UpdateAssociationStatus",
		            "ssm:UpdateInstanceInformation",
		            "ssm:CreateAssociation",
		            "ssm:DeleteAssociation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },        
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ds:CreateComputer",
                "ds:DescribeDirectories"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetEncryptionConfiguration",
                "s3:AbortMultipartUpload",
                "s3:ListMultipartUploadParts",
                "s3:ListBucketMultipartUploads"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::amazon-ssm-packages-*"
        }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2-ssm-role-policy" {
  role       = aws_iam_role.ec2-ssm-role.id
  policy_arn = aws_iam_policy.ec2-ssm-policy.arn # was "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
