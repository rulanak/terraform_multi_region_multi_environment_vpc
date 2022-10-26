# terraform_multi_region_multi_environment_vpc
## This repository for creating VPC in multiple regions and environments using Terraform
How we can achieve this without creating multiple folders for different environments and for differents regions?

2 best practicies:
### Folder Structure
![image](https://user-images.githubusercontent.com/107318829/198096193-55c8fc28-b409-4ae8-b211-ab48fa473e93.png)

with Folder Structure in `v1.0` we create two folders `us-east-1` and `us-west-2` and both of them has a bash script for switching remote backend s3 bucket depending on what environment we want to work with 

with Folder Strucuture in `v1.1` I modified it with condition expression and locals

### File Structure

with File Structure in `v1.1` there is 2 files to create vpc in both regions. Now we can use alias! There is still bash script to switch between different environments backends.

---
What I like the most about `v1.1` is *conditions and locals*. With them code became more dynamic. Especially if u need to create VPC in the same region for different environment with different CIDR blocks for them:

```
  cidr_block = var.env == "dev" ? var.vpc_cidr_dev : var.vpc_cidr_qa
```


