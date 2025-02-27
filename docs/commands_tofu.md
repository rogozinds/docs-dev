# get yaml from TOFU
tofu show -json | jq -r '.values.root_module.resources[] | select(.type=="helm_release" and .name=="loki") | .values.values[0]' > loki-values.yaml

#Describe service on Kubernetes (change namespace)
kubectl get svc -n loki

#Check Persistent storage
kubectl get pvc -n loki

#Get all resources in a namespace
kubectl get all -n loki

# Get service accounts
kubectl get pods -n loki -o=custom-columns="POD:.metadata.name,SA:.spec.serviceAccountName"

#Notes:
PVCs are claims, not actual storage, the storage is PV. You can describe the PV and see where actual storage.
There you can see the "Source" section where you see the ID of the actual volume. Check the attribute
VolumeHandle

#Describe Storage
kubectl describe pv pvc-123131-1421-fd3

#Delete the actual AWS volum (Remember REGION!!!)
aws ec2 delete-volume --volume-id vol-0159c2f3fb3bd492f --region us-east-2

#Delete the PV. Actually you need to delete the PVC and PV will be either deleted or retain, base on policy.
kubectl delete pvc data-loki-write-1 -n loki

## Deleting of PVC may stuck, the acceptable solution is to force delete the pod


# Deployments to EKS
## Get the helm chart
helm get values loki -n loki

# SSH inside the pod
kubectl -n loki exec -it loki-write-0 --sh 




.labels.host = get_env_var("HOSTNAME") ?? "unknown"
