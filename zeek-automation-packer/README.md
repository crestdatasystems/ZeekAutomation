# Zeek-Fluentd Golden Image

## Pre-requisites:
- [GCP service account with appropriate roles](#gcp-service-account-with-appropriate-roles)
- [Default VPC should exists](#default-vpc-should-exists)
- [Packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install)


## GCP service account with appropriate roles

- Authenticating with Google Cloud services requires a JSON Service Account Key.
- To create a custom service account for Packer and assign to it `Compute Instance Admin (v1)` & `Service Account User` roles, follow the below instructions:
    - Log in to the Google Cloud Console and select a project.
    - Click Select a project, choose your project, and click Open.
    - Click Create Service Account.
    - Enter a service account name (friendly display name), an optional description, select the `Compute Engine Instance Admin (v1)` and `Service Account User` roles, and then click Save.
- Generate a JSON Key and save it in a secure location.


## Steps for executing Packer Script

#### **Input Parameters:**
- **gce_credentials:** (mandatory) - The JSON file containing GCP account credentials. Environment variable name - **GCE_CREDENTIALS**.
- **gce_project_id:** (mandatory) - The ID of the GCP project that will be used to launch instances and store images. Environment variable name - **GCE_PROJECT_ID**.
- **gce_zone:** (mandatory) - The zone to launch the instance used to create the image. Example: "us-central1-a". Environment variable name - **GCE_ZONE**.
- **gce_source_image_family:** (optional) - The source image family to use as a base image for the golden image. Example: "debian-10"
- **ssh_username:** (optional) - The username to SSH the instance. Required if using SSH.
- **custom_image_name:** (optional) - The unique name of the resulting image. Defaults to packer-{{timestamp}}
- **custom_image_family:** (optional) - The name of the image family to which the resulting image belongs.

**NOTE:**  
- All the mandatory parameters in the above list should be passed either with the environment variable or in the command line with the packer build command. Check - [How to Set Environment Variable](#how-to-set-environment-variable).  
- If the environment variable is provided and the parameter is passed using the command line, the value provided in the command line is preferred.  
- The name of the environment variable is provided in the above list.  
- All the optional parameters in the above list could be passed in the command line with the packer build command.  

---
#### **How to Set Environment Variable**
- Windows:
	- Open command prompt.
	- Set the Environment Variable:  
		```
		set GCE_CREDENTIALS=/file/path/to/credentials.json
		```
	- Verifying the set Environment Variable:  
		```
		echo %GCE_CREDENTIALS%
		```
- Linux/Unix or Mac:
	- Open Terminal.
	- Set the Environment Variable:  
		```
		export GCE_CREDENTIALS=/file/path/to/credentials.json
		```
	- Verifying the set Environment Variable:  
		```
		echo $GCE_CREDENTIALS
		```

## **Running the Packer Script**
- If all the mandatory parameters are passed using the environment variable and it's not required to pass the optional parameters, run the packer script:  
	```
	  packer build image.json
	```
- If it's required that the mandatory parameters or any of the optional parameters should be passed in the command line with the packer build command, run the packer script in the following way:  
	```
	   packer build -var 'gce_credentials=/file/path/to/credentials.json' -var 'gce_project_id=project_id_1234' -var 'gce_zone=us-central1-a' -var 'custom_image_name=image_name' image.json
	```

## Default VPC should exists

### Case A: If default VPC does not exists

- #### Create a default vpc network.
	- Go to the VPC networks page in the [Google Cloud Console](https://console.cloud.google.com/networking/networks/list?_ga=2.156291571.995814475.1616565568-2118158114.1615797696).
	- Click Create VPC network.
	- Enter a Name for the network. (Here, name should be `default`)
	- Choose Automatic for the Subnet creation mode.
	- In the Firewall rules section, select one or more predefined firewall rules that address common use cases for connectivity to VMs. If you don't want to use them, select no rules. You can create your own firewall rules after you create the network.
	- Choose the Dynamic routing mode for the VPC network. For more information, see [dynamic routing mode](https://cloud.google.com/vpc/docs/vpc#routing_for_hybrid_networks). You can change the dynamic routing mode later.
	- Maximum transmission unit (MTU): Choose whether the network has an MTU of 1460 (default) or 1500. Review the [MTU information in the concepts guide](https://cloud.google.com/vpc/docs/vpc#mtu) before setting the MTU to 1500.
	- Click Create.

- #### Create a firewall rule for default vpc network.
	- Go to the Firewall page in the [Google Cloud Console](https://console.cloud.google.com/networking/firewalls/list?_ga=2.227055829.995814475.1616565568-2118158114.1615797696).
	- Click Create firewall rule.
	- Enter a Name for the firewall rule. (This name must be unique for the project.)
	- Specify the Network for the firewall rule. (Here, select `default` network which is created from above steps)
	- For the Direction of traffic, choose `ingress`.
	- For the Action on match, choose `allow`.
	- For the Targets of the rule, choose `All instances in the network`.
	- For an ingress rule, specify the Source filter:
		- Choose IP ranges and type the CIDR blocks into the Source IP ranges field to define the source for incoming traffic by IP address ranges. 
			- Use `0.0.0.0/0` in our case.
		- Define the Protocols and ports to which the rule applies: Define specific protocols and destination ports:
			- Select `tcp` to include the TCP protocol and in destination ports enter `22`.
	- Click Create.

---
### Case B: If default VPC exists

- If the default vpc exists then check for `SSH firewall rule` exists or not. If not follow [above steps](#create-a-firewall-rule-for-default-vpc-network) to create one.



## Troubleshooting

- If you get error like: `command not found` then run below commands to install and update required packages.
	```
	sudo apt-get install software-properties-common git -y
	sudo apt-get update -y
	```