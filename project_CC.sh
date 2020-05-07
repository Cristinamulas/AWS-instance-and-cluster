#/bin/bash
# install AWS CLI in my computer
brew install awscli
#chekout the installation
aws
# configure CLI
aws configure
#Creating users and groups
aws iam create-user --user-name cristina
aws iam get-user --user-name cristina
aws iam list-access-keys --user-name cristina
aws iam create-access-key --user-name cristina

aws iam create-group --group-name admins
# see polices
aws iam list-policies | grep AmazonEC2 | grep Access

aws iam attach-group-policy \
--policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess \
	--group-name admins

aws iam add-user-to-group \
	--group-name admins \
	--user-name cristina

# creating firewall rules for my instace
aws ec2 create-security-group --group-name my_EC2 --description "Security Group for EC2 instances to allow ports 22, 80 and 443"
aws ec2 authorize-security-group-ingress --group-name my_EC2 --protocol tcp --port 22 --cidr 67.244.115.227/32
aws ec2 authorize-security-group-ingress --group-name my_EC2 --protocol tcp --port 80 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name my_EC2 --protocol tcp --port 443 --cidr 0.0.0.0/0
# check if everything was enter correcly
aws ec2 describe-security-groups --group-names my_EC2


# create EC2 instance
aws ec2 run-instances --image-id ami-0915e09cc7ceee3ab --count 1 --instance-type t2.micro --key-name mynewpair --security-group-ids my_EC2
# Permision to access the private key
chmod 400 key_test.pem
#looging to my instace
ssh -i "key_test.pem" ec2-user@ec2-52-70-97-129.compute-1.amazonaws.com
# intalling packeges into the instace
sudo yum install python3
sudo pip3 install flask

#copy file into my instace(type this comand in another terminal)
sudo scp -i key_test.pem todolist.db ec2-user@<id>.compute-1.amazonaws.com:~/
#copy the directory
sudo scp -i key_test.pem -r todolist ec2-user@<id>.compute-1.amazonaws.com:~/
python3 todolist.py

# create a Dockerfile
touch Dockerfile # create a dockerfile inside todolist dir
vim Dockerfile # edit Dockerfile
# create a image
docker build -t cristinamulas55/test-1:2 .
# see all my images
docker images
# from image to container
docker run -it -p5000:5000 cristinamulas55/test-1:2
# login into my hub.docker account
docker login
# push the image to a public repository
docker push cristinamulas55/test-1:2
# when to https://hub.docker.com/repositories to check
#create a cluster

# intall pakages
brew update && brew install kops kubectl
# Create a S3 bucket for kops to use to store the state of the Kubernetes cluster and its configuration.
aws s3api create-bucket --bucket cristinamulas-kops-state-store --region us-east-1
# set two environment variables
export KOPS_CLUSTER_NAME=cristinamulas.k8s.local
export KOPS_STATE_STORE=s3://cristinamulas-kops-state-store

kops create cluster --help
#generate cluster configuration, does not create instance. It simply creates the configuration and writes to the s3://cristinamulas-kops-state-store
kops create cluster  --node-count=2 --node-size=t2.micro --zones=us-east-1a
# edit the cluster
kops edit cluster
# add a name
kops create cluster --node-count=2 --node-size=t2.medium --zones=us-east-1a --name my-clustter
#built the clustter
kops update cluster --name ${KOPS_CLUSTER_NAME} --yes
# see the nodes of the cluster
kubectl get nodes
#run the app in the cluster
kubectl create deployment test --image=cristinamulas55/test-1:2
# expose the app to internet
kubectl expose deployment test --type=LoadBalancer --port 5000
# scale up
kubectl scale deployment test --replicas=3



#Cretaing a cluster with ESK
# install eksclt
brew install eksclt
#build Kubernetes cluster
eksctl create cluster --name my-second-cluster  --version 1.12  --nodegroup-name standard-workers --node-type t3.medium --nodes 3
# see characteristics of the cluster
eksctl get cluster
# get services
kubectl get svc
# see the nodes of the cluster
kubectl get nodes
