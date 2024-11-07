# cf-asg-template
## Prerequisites:
- [AWS CLI](https://aws.amazon.com/cli/) installed and configured with appropriate IAM permissions (`cloudformation:CreateStack`, `ec2:RunInstances`, `autoscaling:CreateAutoScalingGroup`).
- Select IAM -> Policies from the left-hand menu and click Create policy
```sh
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "ec2:RunInstances",
        "autoscaling:CreateAutoScalingGroup"
      ],
      "Resource": "*"
    }
  ]
}
```
- Attach policy to user and create security_credentials --> Access keys 

## Setup:
1. Clone the repository:
   ```bash
   aws configure
   git clone https://github.com/yourusername/cf-asg-template.git
   cd cf-asg-template
   ```
2. Modify the CloudFormation template values such as AMI ID, key pair, and subnet ID as needed in deploy_asg.sh
3. Run the Bash script to create your resources:
   a. Example: ./deploy_asg.sh -n awesome -s 3
   ```sh
   ./deploy_asg.sh -n <base_name> -s <number_of_instances>
   ```
   b. Output will show:
   ```sh
	Creating CloudFormation stack for base name: awesome and 3 instances...
	This will create an Auto Scaling Group (ASG) named: awesome-ASG
	Number of instances: 3

	CloudFormation stack creation initiated successfully.
	You can check the status of the stack in the AWS Management Console.
   ```
4. Show Help:
   ```sh
   ./deploy_asg.sh -h
   ```
5. #### Optional: For Github Actions Automated pipeline check for .github/workflows/deploy.yml
   ```sh
   mv deploy.yaml .github/workflows/deploy.yml
   ```
- store below values in secret variables 
  a. secrets.AWS_ACCESS_KEY_ID 
  b. secrets.AWS_SECRET_ACCESS_KEY
  c. secrets.AWS_REGION
