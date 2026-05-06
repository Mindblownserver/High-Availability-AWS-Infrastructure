# Provider block configures options that apply to all resources managed by D. provider
provider "aws" {
  region = "us-east-1" # Configuring region!!
}
# Can have mulitple provider blocks of different providers or of mulitple instances of the same provider
# number of required providers = number of provider blocks.
/* ============================= */

#!! aws_instance, aws_ami are values determined by the provider developers.

# Data block queries your cloud provider for resources. 
# In our case, we'll query the AWS AMI becasue we don't hardocode values that can become stale!
# Just as the previous block, the resource block has an address.
/* For our EC2, its address is resource.aws_instance.app_server
aws_instance is called resource type, whereas app_server is called resource name
*/


# PS: use `terraform fmt` to format files consistently!
/*
terraform init => initializes terraform workspace. It downloads providers binaries defined in your configuration (terraform.tf)

terraform validate => Makes sure your configuration is syntactically correct and internally consistent.
For example, if you **mistype** a resource name or refer to an argument your resource **does not** support, Terraform will report an error when you validate your configuration.

When you applied your configuration, terraform wrote data about your configuration in a file called terraform.tfstate
Terraform stores data about your infra in its state file, used to manage resources over their own lifecycle

You can list resources and data sources using terraform state list:
ata.aws_ami.amazon_linux
data.aws_availability_zones.available_subnets
...

Even though data source isn't an actual resource, it's still tracked nonetheless.
terraform show: shows details of each (re)source
# data.aws_availability_zones.available_subnets:
data "aws_availability_zones" "available_subnets" {
    group_names = [
        "us-east-1-zg-1",
    ]
    id          = "us-east-1"
    names       = [
        "us-east-1a",
        "us-east-1b",
        "us-east-1c",
        "us-east-1d",
        "us-east-1e",
        "us-east-1f",
    ]
    state       = "available"
    zone_ids    = [
        "use1-az6",
        "use1-az1",
        "use1-az2",
        "use1-az4",
        "use1-az3",
        "use1-az5",
    ]
}
*/