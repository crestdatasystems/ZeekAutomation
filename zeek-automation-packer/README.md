## Zeek-Fluentd Golden Image

---

### Pre-requisites:
- [Packer](https://learn.hashicorp.com/tutorials/packer/getting-started-install)
- [GCP service account with appropriate roles](#gcp-service-account-with-appropriate-roles)

---

### GCP service account with appropriate roles

- Authenticating with Google Cloud services requires either a User Application Default Credentials or a JSON Service Account Key. These are not required if you are running the 'googlecompute' Packer builder on Google Cloud with a properly-configured Google Service Account.
- To create a custom service account for Packer and assign to it Compute Instance Admin (v1) & Service Account User roles, follow the below instructions:
    - Log in to the Google Cloud Console and select a project.
    - Click Select a project, choose your project, and click Open.
    - Click Create Service Account.
    - Enter a service account name (friendly display name), an optional description, select the Compute Engine Instance Admin (v1) and Service Account User roles, and then click Save.
- Generate a JSON Key and save it in a secure location.

---

### Steps for executing Packer Script

#### **Input Parameters:**
- **gce_credentials:** (mandatory) - The JSON file containing GCP account credentials. Environment variable name - **GCE_CREDENTIALS**.
- **gce_project_id:** (mandatory) - The ID of the GCP project that will be used to launch instances and store images. Environment variable name - **GCE_PROJECT_ID**.
- **gce_zone:** (mandatory) - The zone to launch the instance used to create the image. Example: "us-central1-a". Environment variable name - **GCE_ZONE**.
- **gce_source_image_family:** (optional) - The source image family to use as a base image for the golden image. Example: "debian-10"
- **ssh_username:** (optional) - The username to SSH the instance. Required if using SSH.
- **custom_image_name:** (optional) - The unique name of the resulting image. Defaults to packer-{{timestamp}}
- **custom_image_family:** (optional) - The name of the image family to which the resulting image belongs.

**NOTE:**  
- All the mandatory parameters in the above list should be passed either with the environment variable or in the command line with the packer build command. Check - [How to Set Environment Variable](#How-to-Set-Environment-Variable).  
- If the environment variable is provided and the parameter is passed using the command line, the value provided in the command line is preferred.  
- The name of the environment variable is provided in the above list.  
- All the optional parameters in the above list could be passed in the command line with the packer build command.  

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

#### **Running the Packer Script**
- If all the mandatory parameters are passed using the environment variable and it's not required to pass the optional parameters, run the packer script:  
	```
	  packer build image.json
	```
- If it's required that the mandatory parameters or any of the optional parameters should be passed in the command line with the packer build command, run the packer script in the following way:  
	```
	   packer build -var 'gce_credentials=/file/path/to/credentials.json' -var 'gce_project_id=project_id_1234' -var 'gce_zone=us-central1-a' -var 'custom_image_name=image_name' image.json
	```
