#create namesace playground
kubectl create namespace playground

#Create a collection of pods with labels assinged to each
more CreatePodsWithLabels.yaml
kubectl apply -f CreatePodsWithLabels.yaml

#Look at all the Pod labels in our cluster
kubectl get pods --show-labels -n playground

#Look at one Pod's labels in our cluster
kubectl describe pod nginx-pod-1 -n playground | head

#Query labels and selectors
kubectl get pods --selector tier=prod -n playground
kubectl get pods --selector tier=qa -n playground
kubectl get pods -l tier=prod -n playground
kubectl get pods -l tier=prod --show-labels -n playground

#Selector for multiple labels and adding on show-labels to see those labels in the output
kubectl get pods -l 'tier=prod,app=MyWebApp' --show-labels -n playground
kubectl get pods -l 'tier=prod,app!=MyWebApp' --show-labels -n playground
kubectl get pods -l 'tier in (prod,qa)' -n playground
kubectl get pods -l 'tier notin (prod,qa)' -n playground

#Output a particluar label in column format
kubectl get pods -L tier -n playground
kubectl get pods -L tier,app -n playground

#Edit an existing label
kubectl label pod nginx-pod-1 tier=non-prod --overwrite -n playground
kubectl get pod nginx-pod-1 --show-labels -n playground

#Adding a new label
kubectl label pod nginx-pod-1 another=Label -n playground
kubectl get pod nginx-pod-1 --show-labels -n playground

#Removing an existing label
kubectl label pod nginx-pod-1 another- -n playground
kubectl get pod nginx-pod-1 --show-labels -n playground

#Performing an operation on a collection of pods based on a label query
kubectl label pod --all tier=non-prod --overwrite -n playground
kubectl get pod --show-labels -n playground

#Delete all pods matching our non-prod label
kubectl delete pod -l tier=non-prod -n playground

#And we're left with nothing.
kubectl get pods --show-labels -n playground

#Kubernetes Resource Management
#Start a Deployment with 3 replicas, open deployment-label.yaml
kubectl apply -f deployment-label.yaml

#Expose our Deployment as  Service, open service.yaml
kubectl apply -f service.yaml

#Look at the Labels and Selectors on each resource, the Deployment, ReplicaSet and Pod
#The deployment has a selector for app=hello-world
kubectl describe deployment hello-world -n playground

#The ReplicaSet has labels and selectors for app and the current pod-template-hash
#Look at the Pod Template and the labels on the Pods created
kubectl describe replicaset hello-world -n playground

#The Pods have labels for app=hello-world and for the pod-temlpate-hash of the current ReplicaSet
kubectl get pods --show-labels -n playground

#Edit the label on one of the Pods in the ReplicaSet, change the pod-template-hash
kubectl label pod PASTE_POD_NAME_HERE pod-template-hash=DEBUG --overwrite -n playground

#The ReplicaSet will deploy a new Pod to satisfy the number of replicas. Our relabeled Pod still exists.
kubectl get pods --show-labels -n playground

#Let's look at how Services use labels and selectors, check out services.yaml
kubectl get service -n playground

#The selector for this serivce is app=hello-world, that pod is still being load balanced to!
kubectl describe service hello-world -n playground

#Get a list of all IPs in the service, there's 5...why?
kubectl describe endpoints hello-world -n playground

#Get a list of pods and their IPs
kubectl get pod -o wide -n playground

#To remove a pod from load balancing, change the label used by the service's selector.
#The ReplicaSet will respond by placing another pod in the ReplicaSet
kubectl get pods --show-labels -n playground
kubectl label pod PASTE_POD_NAME_HERE app=DEBUG --overwrite -n playground

#Check out all the labels in our pods
kubectl get pods --show-labels -n playground

#Look at the registered endpoint addresses. Now there's 4
kubectl describe endpoints hello-world -n playground

#To clean up, delete the deployment, service and the Pod removed from the replicaset
kubectl delete deployment hello-world -n playground
kubectl delete service hello-world -n playground
kubectl delete pod PASTE_POD_NAME_HERE -n playground

#Scheduling a pod to a node
#Scheduling is a much deeper topic, we're focusing on how labels can be used to influence it here.
kubectl get nodes --show-labels 

#Label our nodes with something descriptive
kubectl label node pk-node01 disk=local_ssd
kubectl label node pk-node01 hardware=local_gpu

#Query our labels to confirm.
kubectl get node -L disk,hardware

#Create three Pods, two using nodeSelector, one without.
more PodsToNodes.yaml
kubectl apply -f PodsToNodes.yaml

#View the scheduling of the pods in the cluster.
kubectl get node -L disk,hardware
kubectl get pods -o wide

#Clean up when we're finished, delete our labels and Pods
kubectl label node pk-node01 disk-
kubectl label node pk-node01 hardware-
kubectl delete pod nginx-pod
kubectl delete pod nginx-pod-gpu
kubectl delete pod nginx-pod-ssd
