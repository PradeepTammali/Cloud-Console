# Cloud-Console
A web based console deployed on Kubernetes with prerequisites modules installed and configured. Multi tenant console with restriction of data among the users and  temporary storage.

![Cloud Console image](https://github.com/PradeepTammali/Cloud-Console/blob/main/CloudConsole.PNG)
## Build Console
Build the Cloud Console as explained in this [link](https://github.com/PradeepTammali/Cloud-Console/tree/main/Console) . Once the Console is build and deployed then you can test the pod or console by logging into the pod as following.
```
kubectl -n <namespace> exec -it <pod> bash
```
It will prompt for the Username and Password along the with the banner mentioned.

## How to use
If you already have a custom built web based shell then you can configure your server to reach the console deployed. You can deploy a simple web based cloud console with python as backend to connect to the console as explained in this [link](#).
