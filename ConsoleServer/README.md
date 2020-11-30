# Cloud Console 

Web based Cloud Console to connect to the server which is running on Kubernetes and exposed externally. This server connects to the Cloud Console running in the K8s and opens the shell in the browser.

Before proceeding on how deploy the the web based Cloud Console Server, make sure you have build and deployed the Cloud Console as explained in this [link](https://github.com/PradeepTammali/Cloud-Console/tree/main/Console)

Once you have build, deployed console and given permission for all the required groups and users then you can deploy this Cloud Console Server to access the Pod from browser. This Server will take some inputs such as Namespace, Pod, container and ID Token to connect to the console pod. 

## Configuration
Please make sure you are passing environment variable `API_SERVER` while running the Cloud Console Server. This Kubernetes api server is used to connect to Cloud Console pod using python-kubernetes client. If you are running the server locally export the environment variables. If you are deploying on Kubernetes please make sure you pass the api server URL in the YAML.
```
env:
- name: API_SERVER
  value: ""
```

## Build
You can build the Cloud Console Server docker image as following.
```
git clone https://github.com/PradeepTammali/Cloud-Console.git
cd Cloud-Console/ConsoleServer/
sudo docker build -t cloud-console-server.registry.com:5000/cloud-console-server:v1 .
sudo docker push cloud-console-server.registry.com:5000/cloud-console-server:v1
```

## Deploy
Deploy the Cloud Console Server in kubernetes.
```
kubectl apply -f cloud-console-server.yaml
```

## Customize
```
git clone https://github.com/PradeepTammali/Cloud-Console.git
cd Cloud-Console/ConsoleServer/
code .
```

#### Reference

https://github.com/wushirenfei/k8s-web-terminal
