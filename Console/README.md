# Cloud Console

Ubuntu as image the shell is configured in such a way that whenever user login into the pod, it would prompt for the username and password. These details are authenticated againt the keycloak configured in the base image. This image contains all the prerequired packages installed in it. 

Cloud Console can be used where you want to provide some console on the browser for users in an multi tenant environment. The data among the users is restricted and temparory. If the pod restarts then all the data which is stored will wiped out. It's better to store only temp data in the pod. Cloud Console also configures the kubeconfig of each user on login by populating the config with id-token and refresh token. A custom defined banner will be displayed on login.



## Configuration
Configure your keycloak details in the `setup.sh` file. Keep the root certificate in base64 encoded format in the variable for the kubectl commands to work appropriately. To know more about how to configure Keycloak, run it in HTTPS mode and use it for Kubernetes OIDC please refere to official documentation.
```
KEYCLOAK="Keycloak URL with port <cloudconsole.keycloak.com:8080>"
REALM="Keycloak REALM"
CLIENT="Keycloak Client"
CLIENT_SECRET="Keycloak Client Secret"
ROOTCA_PEM="Root Certificate for the Keycloak to authenticate with k8s"
K8S_APISERVER="Kubernets Api server URL"
```

## Build
```
git clone https://github.com/PradeepTammali/Cloud-Console.git
cd Cloud-Console/Console/
sudo docker build -t cloudconsole.registry.com:5000/cloud-console:v1 .
sudo docker push cloudconsole.registry.com:5000/cloud-console:v1
```

## Deploy
Deploy the Cloud Console as Deployment in kubernetes cluster with the following command and set the RBAC for the required Groups and Users in the `rbac.yaml`. You can use [minikube](https://minikube.sigs.k8s.io/docs/) or [Kind](https://kind.sigs.k8s.io/) if you do not have any kubernetes cluster available.
```
kubectl apply -f cloud-console.yaml
kubectl apply -f rbac.yaml
```
