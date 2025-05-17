# Cloud Media Server
Universal Media Server hosted on Google Cloud, using Filestore as remote file system storage and File Browser for uploading and interacting with media files.

# Prerequisites
- `Terraform`
- `gcloud CLI`
- `Ansible`

# Setup example

Authenticate to Google Cloud with gcloud CLI:
```
gcloud auth application-default login
```

Create `terraform.tfvars` file with `project_id`:
```
echo 'project_id = "{google_project_id}"' > terraform.tfvars
```

Create ssh keys for Ansible to use. Default path is `~/.ssh/id_rsa`, can be changed in `variables.tf`:
```
ssh-keygen -t rsa -b 4096
```

Download Ansible collections:
```
ansible-galaxy collection install cloud.terraform
ansible-galaxy collection install community.docker
```

Provision instances:
```
terraform init
terraform apply
```


Configure instances:
```
ansible-playbook -i inventory.yml playbook.yml
```

# 

After instances are running and configured, you can access File Browser and Universal Media Server web interfaces at their respective adresses, found by running `terraform output`.

- File Browser: `{filebrowser_ip}:8080`
    - Default credentials: `user=admin`, `pass=admin`
- Universal Media Server: `{universalmediaserver_ip}:9001`
    - Create a user at first launch

#

![image](https://github.com/user-attachments/assets/e9758487-2010-402c-8836-538bfc953f89)

![image](https://github.com/user-attachments/assets/3b361f66-9c36-4c2e-9fbf-c7669f63db78)

