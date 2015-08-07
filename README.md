# Wordpeppers
XPeppers Wordpress box infrastructure http://www.xpeppers.com

# Create an AMI

Create packer-variables.json file and configure user variables

Create AMI
```
./create-ami {path to packer-variables.json file}
```

# Create AWS stack

Create terraform.tfvars file and configure user variables

Create stack
```
./create-stack {path to terraform-variables.tfvars file}
```
