#!/bin/bash

# Default values
NAME=""
SIZE=1

# Function to show the help message
show_help() {
  echo "Usage: $0 -n <base_name> -s <size> [-h]"
  echo ""
  echo "Parameters:"
  echo "  -n  Base name for the resources (e.g., 'awesome')"
  echo "      This name will be used to generate the names of the Auto Scaling Group (ASG) and Launch Template."
  echo "  -s  Number of instances in the Auto Scaling Group."
  echo "      The number of EC2 instances that will be part of the Auto Scaling Group (default: 1)."
  echo "  -h  Show this help message"
  echo ""
  echo "Example:"
  echo "  $0 -n awesome -s 3"
  echo "    This will create an ASG named 'awesome-ASG' with 3 instances."
  exit 0
}

# Parse command line arguments
while getopts ":n:s:h" opt; do
  case ${opt} in
    n )
      NAME=$OPTARG
      ;;
    s )
      SIZE=$OPTARG
      ;;
    h )
      show_help
      ;;
    \? )
      echo "Invalid option: -$OPTARG" 1>&2
      show_help
      exit 1
      ;;
    : )
      echo "Option -$OPTARG requires an argument." 1>&2
      show_help
      exit 1
      ;;
  esac
done

# Check if the base name (-n) is provided
if [ -z "$NAME" ]; then
  echo "Error: -n (base name) is required."
  show_help
  exit 1
fi

# CloudFormation Template embedded as a string in the script
CLOUDFORMATION_TEMPLATE=$(cat <<-EOF
AWSTemplateFormatVersion: "2010-09-09"
Description: CloudFormation Template to create Launch Template and Auto Scaling Group

Parameters:
  BaseName:
    Type: String
    Description: Base name to use for ASG and resources (e.g., "awesome")

  InstanceCount:
    Type: Number
    Description: The desired number of instances in the Auto Scaling Group

Resources:
  # Launch Template
  MyLaunchTemplate:
    Type: "AWS::EC2::LaunchTemplate"
    Properties:
      LaunchTemplateName: !Sub "\${BaseName}-LaunchTemplate"
      VersionDescription: "v1"
      LaunchTemplateData:
        InstanceType: "t3.micro"
        ImageId: "ami-0c55b159cbfafe1f0"  # Replace with a valid AMI ID in your region
        SecurityGroupIds:
          - !Ref "DefaultSecurityGroup"  # Assuming default SG exists; change as needed
        KeyName: "your-key-pair"  # Replace with your key pair name

  # Auto Scaling Group
  MyAutoScalingGroup:
    Type: "AWS::AutoScaling::AutoScalingGroup"
    Properties:
      AutoScalingGroupName: !Sub "\${BaseName}-ASG"
      DesiredCapacity: !Ref InstanceCount
      MaxSize: !Ref InstanceCount
      MinSize: 1
      VPCZoneIdentifier:
        - "subnet-xxxxxx"  # Replace with your subnet ID
      LaunchTemplate:
        LaunchTemplateName: !Ref MyLaunchTemplate
        Version: !GetAtt MyLaunchTemplate.LatestVersion
      HealthCheckType: EC2
      HealthCheckGracePeriod: 300
      Tags:
        - Key: "Name"
          Value: !Sub "\${BaseName}-Instance"
          PropagateAtLaunch: true

Outputs:
  LaunchTemplateName:
    Value: !Ref MyLaunchTemplate
    Description: The name of the launch template

  AutoScalingGroupName:
    Value: !Ref MyAutoScalingGroup
    Description: The name of the Auto Scaling Group
EOF
)

# Create CloudFormation Stack
create_stack() {
  echo "Creating CloudFormation stack for base name: $NAME and $SIZE instances..."
  echo "This will create an Auto Scaling Group (ASG) named: ${NAME}-ASG"
  echo "Number of instances: $SIZE"
  echo ""

  # Create the stack using AWS CLI
  aws cloudformation create-stack \
    --stack-name "${NAME}-Stack" \
    --template-body "$CLOUDFORMATION_TEMPLATE" \
    --parameters \
      ParameterKey=BaseName,ParameterValue=$NAME \
      ParameterKey=InstanceCount,ParameterValue=$SIZE \
    --capabilities CAPABILITY_NAMED_IAM

  if [ $? -eq 0 ]; then
    echo "CloudFormation stack creation initiated successfully."
    echo "You can check the status of the stack in the AWS Management Console."
  else
    echo "Error: Failed to create the CloudFormation stack." 1>&2
    exit 1
  fi
}

# Run the function to create the stack
create_stack

