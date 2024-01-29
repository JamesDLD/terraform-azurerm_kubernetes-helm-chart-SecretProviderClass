# test rendering chart templates locally
```
helm install --dry-run  --debug                                 \
                        --values values.yaml                    \
                        --values values-demo.yaml               \
                        --set tenantId=xxxxxxxx                 \
                        --set userAssignedIdentityID=xxxxxxxx   \
                        --set keyvaultName=xxxxxxxx             \
                         demo .
```

# deploy via helm
```
helm install    --values values.yaml                    \
                --values values-demo.yaml               \
                --set tenantId=xxxxxxxx                 \
                --set userAssignedIdentityID=xxxxxxxx   \
                --set keyvaultName=xxxxxxxx             \
                 demo .
```

# remove deployed helm resource
```
helm delete demo
```

# print the definition of Kube object
```
kubectl explain SecretProviderClass --recursive
```

# print the SecretProviderClass Kube object
```
kubectl -n test get SecretProviderClass demo -o yaml
```
