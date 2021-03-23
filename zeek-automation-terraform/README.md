# Google Zeek Automation Module

![Terraform Version](https://img.shields.io/badge/tf-%3E%3D0.14.5-blue.svg)

This module simplifies the deployment of Zeek so GCP customers can feed raw packets from VPC Packet Mirroring and produce rich security telemetry for threat detection and investigation in our Chronicle Security Platform.


## Architecture

![Architecture](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/architecture-diagram/architecture.png "Architecture")

## Features

- Creates regional managed instance groups having using same network peering between mirror-collector vpc for collecting logs from mirror vpc sources.
- Enables regional packet mirroring policies for mirroring mirror vpc sources like:
    - mirror-vpc subnets
    - mirror-vpc tags
    - mirror-vpc instances
  
  with optional parametes like: ip_protocols, direction, & cidr_ranges.
- Enables packaging of logs in order to send it to Chronicle Platform.  

## Learn

### Core concepts

- [VPC Network](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#vpc-network)
- [Network Subnets](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#network-subnets)
- [Network Firewall](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#network-firewall)
- [VPC Network Peering](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#vpc-network-peering)
- [Instance Template](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#instance-template)
- [Managed Instance Group](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#managed-instance-group)
- [Internal Load Balancer](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#internal-load-balancer)
- [Packet Mirroring](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/docs/core-concepts/core-concepts.md#packet-mirroring)

### Repo organisation

This repo has the following folder structure:

- [root](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/tree/master): The root folder contains an example of how to deploy Google Zeek Automation module.

- [modules](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/tree/master/modules): This folder contains the main implementation code for this Module.

- [examples](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/tree/master/examples): This folder contains examples of how to use the module.

- [test](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/tree/master/test): Automated tests for the module.

## Deploy

If you want to try this repo out for experimenting and learning, check out the following resources:

- [examples folder](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/tree/master/examples): The `examples` folder contains sample code optimized for learning, experimenting, and testing.

## Contributions

Contributions to this repo are very welcome and appreciated! If you find a bug or want to add a new feature or even contribute an entirely new module, we are very happy to accept pull requests, provide feedback, and run your changes through our automated test suite.

Please see [Contributing to the Google Zeek Automation Readme file](https://github.com/kirtanchavda-crest/terraform-google-zeek-automation/blob/master/CONTRIBUTING.md) for instructions.
