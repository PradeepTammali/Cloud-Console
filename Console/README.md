# Cloud Console

Ubuntu as image the shell is configured in such a way that whenever user login into the pod, it would prompt for the username and password. These details are authenticated againt the keycloak configured in the base image. This image contains all the prerequired packages installed in it. 

Cloud Console can be used where you want to provide some console on the browser for users in an multi tenant environment. The data among the users is restricted and temparory. If the pod restarts then all the data which is stored will wiped out. It's better to store only temp data in the pod. Cloud Console also configures the kubeconfig of each user on login by populating the config with id-token and refresh token. A custom defined banner will be displayed on login.


## Build

`sudo docker build -t cloudconsole.registry.com:5000/cloud-console:v1 .`

`sudo docker push cloudconsole.registry.com:5000/cloud-console:v1`

## Deploy

`kubectl create -f cloud-console.yaml`
