# Introduction
Helm charts managed through Terraform to deploy an Azure SecretProviderClass on AKS.

For more details, you can consult the following [article](https://medium.com/@jamesdld23/helm-charts-managed-through-terraform-to-deploy-an-azure-secretproviderclass-on-aks-b5af45bc5c8e).

# Procedure
Authenticate to Azure using [az cli](https://learn.microsoft.com/cli/azure/install-azure-cli?WT.mc_id=DOP-MVP-5003548).

```bash
az login
```

1. Initialize the working directory.
```bash
terraform init
```

2. Create an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
```bash
terraform plan  -var 'subscription_id=<Your Azure subscription ID>'                             \
                -var 'aks_cluster={"name":"<Your Azure AKS cluster name>","resource_group_name":"<Your Azure AKS cluster resource group name>"}'    
```

3. Execute the actions proposed in a Terraform plan.
```bash
terraform apply -var 'subscription_id=<Your Azure subscription ID>'                             \
                -var 'aks_cluster={"name":"<Your Azure AKS cluster name>","resource_group_name":"<Your Azure AKS cluster resource group name>"}'  
```

4. Test
   1. Create a pod using the following YAML.
   ```yaml
   # This is a sample pod definition for using SecretProviderClass and the user-assigned identity to access your key vault
   kind: Pod
   apiVersion: v1
   metadata:
     namespace: test
     name: busybox-secrets-store-inline-user-msi
   spec:
     containers:
       - name: busybox
         image: mcr.microsoft.com/azure-cli
         command:
           - "/bin/sleep"
           - "10000"
         volumeMounts:
           - name: secrets-store01-inline
             mountPath: "/mnt/secrets-store"
             readOnly: true
     volumes:
       - name: secrets-store01-inline
         csi:
           driver: secrets-store.csi.k8s.io
           readOnly: true
           volumeAttributes:
             secretProviderClass: "demo"
   ```

   2. Apply the pod to your cluster using the kubectl apply command.
   ```bash
   kubectl apply -f pod.yaml
   ```
   3. Show secrets held in the secrets store using the following command.
   ```bash
   kubectl -n test exec busybox-secrets-store-inline-user-msi -- ls /mnt/secrets-store/
   ```
   4. Show secrets held in the secrets store using the following command.
   ```bash
   kubectl -n test exec busybox-secrets-store-inline-user-msi -- cat /mnt/secrets-store/ExampleSecret
   ```
