# terraform-aws-eks

## Overview
This is just a simple EKS module for terraform which I am using for learning and testing purposes.

An optionable bastian host can be created if you intend to protect your cluster in a private network thus not accessible from internet. If that's the case, then set the variable `create_bastion_host` to `true`.

The work here is currently in progress.

## Prerequisites
Before getting your hands dirty, make sure you have the following tools installed in your developer machine:

- **Terraform**
- **Kubectl** (this is only needed if your cluster is exposed to public internet)
