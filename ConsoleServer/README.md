# Cloud Console 

Web based Cloud Console to connect to the server which is running on Kubernetes and exposed externally. This server connects to the Cloud Console running in the K8s and opens the shell in the browser.

Before proceeding on how deploy the the web based Cloud Console Server, make sure you have build and deployed the Cloud Console as explained in this [link](https://github.com/PradeepTammali/Cloud-Console/tree/main/Console)

Once you have build, deployed console and given permission for all the required groups and users then you can deploy this Cloud Console Server to access the Pod from browser. This Server will take some inputs such as Namespace, Pod, container and ID Token to connect to the console pod. 


#### Reference

https://github.com/wushirenfei/k8s-web-terminal
