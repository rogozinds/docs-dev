## Service Accounts
Service account is a type of 'non-human' account, it's mainly used to provide permissions for k8s entities like
pods, services, etc.

Service accounts are used in case an external service need to communicate to Kubernetes API.

### How it works
- Create a service account, either via kubectl or helm.
- Grant permission for the account, for example by using RBAC.
- Assign service account to a Pod. 

### Granting permissions for Service Account
- Create a role that grants access and then BIND it to SericeAccount.


### Assign a ServcieAccount to a Pod
- use spec.servcieAccountName field in the pod specificication.


## Roles (Kubernetes roles & AWS Roles)
There are 2 type of roles, Kubernetes RBAC role that grant permissions within the Kubernetes cluster.
AWS IAM Role grants AWS permissions.
- A service account in kubernetes is used to grant access within the cluster using RBAC
- You can also link service account to an IAM role using IRSA(IAM roles for SErvice Accounts)

### Amazon Roles
Amazon role is assigned to a service account via annotation

   eks.amazonaws.com/role-arn

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: s3-access-service-account
  namespace: my-namespace
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/s3-access-role
```

## Debuging EKS

### Describe the pod.
kubectl describe pods  $POD -n gitlab > pod-def.txt

### A pod can have multiple containers, get it from the POD description and see logs of it:
kubectl -n gitlab logs $POD -c docker > pod-gitlab.txt


### Working autoscaling config
#### Editing inline the deployment

kubectl edit deployment cluster-autoscaler-aws-cluster-autoscaler -n kube-system

    Command:
      ./cluster-autoscaler
      --cloud-provider=aws
      --namespace=kube-system
      --nodes=1:4:eks-gitlab-runner-7ccaca0b-6366-6e06-4276-6e13554c953f
      --logtostderr=true
      --stderrthreshold=info
      --v=5

### Command from helm

    Command:
      ./cluster-autoscaler
      --cloud-provider=aws
      --namespace=kube-system
      --node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/monitoring-cluster
      --expander=least-waste
      --logtostderr=true
      --node-group-auto-discovery=asg:tag=eks:nodegroup-name=gitlab-runner
      --scale-down-delay-after-add=2m
      --scale-down-enabled=true
      --scale-down-unneeded-time=2m
      --scan-interval=10s
      --skip-nodes-with-local-storage=false
      --stderrthreshold=info
      --v=6



