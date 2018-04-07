## VPC

This module borrowed heavily from terraform builds a VPC with a bastion host.
There is a public and private subnet created per availability zone in addition to single NAT Gateway shared between all 3 availability zones.

Usage
=====

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources which can cost money (AWS Elastic IP, for example). Run `terraform destroy` when you don't need these resources.
