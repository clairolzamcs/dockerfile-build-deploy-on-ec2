# Create Dockerfile, build docker image and deploy docker container on Amazon Linux EC2


A.	Steps in doing the Assignment.
1.	In my GitHub account and repository, I have set up the master branch as protected to ensure that it’s not easily tampered with and that all commits will undergo the correct process through creating PRs (pull requests). 

 
 


As you can see here, I tried to make some changes and directly commit and push them to the master branch; however, I wasn’t allowed to do so.
 
 











2.	I have set up the GitHub Actions workflow to be able to build, tag, and push images to AWS ECR. To be able to make that work, I had to set up the AWS credentials as repository secrets in GitHub first.

 

	Only when things are pushed to master will this workflow be triggered. It is configured in our cicd.yml file.

 

	Below is an example successful run of our workflow that was able to build, tag, and push images to ECR.

 
 

 

3.	To login to EC2:
a.	Go to the directory where you have the keypair stored and execute below.
i.	ssh -i prod-key ec2-user@54.227.114.51
 

b.	To pull docker images from EC2:
i.	Login to docker - aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 009147451403.dkr.ecr.us-east-1.amazonaws.com
 
ii.	Pull
1.	docker pull 009147451403.dkr.ecr.us-east-1.amazonaws.com/prod-app:<ecr-image-tag>
2.	docker pull 009147451403.dkr.ecr.us-east-1.amazonaws.com/prod-db:<ecr-image-tag>

 

4.	I was able to run and connect to the mysql db using the below steps:
a.	Created a custom network of type bridge - docker network create new-network -d bridge
b.	Used the prod-db image to run a container in the custom network - docker run -d -e MYSQL_ROOT_PASSWORD=pw --name mysql-db --network new-network daa69374b503
c.	Connected to the mysql-db container using the below command. As an alternative to using the container id, I can also use the container name mysql-db.  - docker exec -it mysql-db mysql -p

 

Alternatively, you can also connect to the mysql DB without having the need to directly hop on to the docker container. We can install the mysql client in our EC2 instance and establish the connection to our DB by using the command:
mysql -u root  -p -h 172.20.0.2 employees

 

5.	Let us now run our app containers within the same custom network that we created where the DB currently runs. 
a.	Myapp-blue
i.	export DBHOST=172.20.0.2 && export DBPORT=3306 && export DBUSER=root && export DATABASE=employees && export DBPWD=pw && export APP_COLOR=blue
ii.	docker run -p 8081:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD  -e APP_COLOR=$APP_COLOR --name blue --network new-network --link mysql-db:mysql-db b1b608a23e1e
 













b.	Myapp-pink
i.	export DBHOST=172.20.0.2 && export DBPORT=3306 && export DBUSER=root && export DATABASE=employees && export DBPWD=pw && export APP_COLOR=pink
ii.	docker run -p 8082:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD  -e APP_COLOR=$APP_COLOR --name pink --network new-network --link mysql-db:mysql-db b1b608a23e1e
 














c.	Myapp-lime
i.	export DBHOST=172.20.0.2 && export DBPORT=3306 && export DBUSER=root && export DATABASE=employees && export DBPWD=pw && export APP_COLOR=lime
ii.	docker run -p 8083:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD  -e APP_COLOR=$APP_COLOR --name lime --network new-network --link mysql-db:mysql-db b1b608a23e1e

 

 

All of them are accessible through the internet simultaneously. 
-	Bue - through port 8081
-	Pink - through port 8082
-	Lime - through port 8083

 








6.	Let’s go inside each of the containers and try to ping the other app containers. 
a.	From blue container:
i.	Ping pink and lime
 

b.	From pink container:
i.	Ping blue and lime
 


c.	From lime container:
i.	Ping blue and pink
 

7.	Docker allows us to run multiple applications listening on the same port (8080) on a single EC2 instance by using port mapping. Each application runs in its own Docker container with its own network stack. Docker's port mapping feature routes incoming requests to the correct container based on the specified mappings. This ensures that the applications can coexist without conflicts and operate independently on the same EC2 instance.
	
8.	Using our website, I tried to input some data and I was able to verify that it was able to be written in our database. Those 2 blank rows are because I accidentally hit enter twice ✌️
 

9.	I have created an application load balancer and a target group through terraform. I copied the DNS of the ALB and hit that in the browser. Now, every time I refresh the page, it directs me to any of the running containers in a round robin manner. (Can be seen in video demo).







B.	Challenges and Solutions in doing the Assignment.
1.	I wanted to create a role that can be used as my EC2’s instance profile in order to pull ECR images however, I was getting this error. As I would interpret it, my AWS user lacks the ability to create an IAM role as it says the security token is invalid.
 

Solution:
Instead of creating a new set of assume policy and inline policy that will be attached to the new role I am trying to create in order to create a new instance profile that my EC2 was initially planned to use, I decided to try if using LabInstanceProfile can be used. 

2.	During creation of my github workflow, I had my cicd.yml inside the directory ./github/workflow. When I pushed to the master branch, no workflow was triggered. 

Solution:
I later on realized that it was just a silly mistake of naming the folder. Instead of workflow, it should be “workflows”. I figured this out when I manually tried to create a workflow through github UI wherein I saw the breadcrumbs. 
 

As soon as I realized this, I renamed the folder > pushed to dev branch > created and merged my PR. Finally, a workflow was triggered. 

3.	First run of my workflow, I encountered an error about my AWS credentials.
 

Solution:
I also encountered this in the last laboratory and it just slipped my mind. It errored out because the credentials I am using are generated through a role and not an IAM user hence, aside from access and secret keys, session token is needed. I added that variable in the secrets and also in the cicd.yml. Afterwards, the workflow pushed through.
 

4.	When I was about to login to ECR in order to pull the image from my repository, I encountered the error “docker: command not found”

Command: aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 009147451403.dkr.ecr.us-east-1.amazonaws.com
 
	
Solution:
I then installed docker through yum. I referenced to some of these steps: https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html
-	sudo amazon-linux-extras install docker
-	sudo service docker start
-	sudo usermod -a -G docker ec2-user
-	Exit then relogin
-	docker info




After doing so, I logged out of the instance and logged back in. Tried to execute docker
 
and it was good. Then I added those lines in my terraform as EC2 userdata so I don’t need to do the installation every single time.


I tried the ecr login command again and I was able to get in.
Command: aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 009147451403.dkr.ecr.us-east-1.amazonaws.com
 








Successful start of a DB container
 

5.	In the instructions where we should test locally in our Cloud9 environment, the apt-get command is not working for me. Therefore, I used yum. 
a.	Sudo yum update
b.	Sudo yum install mysql	

Then I thought of just adding this in my terraform’s EC2 userdata so I wouldn’t need to install it everytime.
 
 
 

6.	Upon trying to connect to the DB from my EC2 host, I got an error saying “Authentication plugin 'caching_sha2_password'”. I then researched about it and found out that it's because MySQL as of version 8.04 and onwards uses caching_sha2_password as default authentication plugin where previously mysql_native_password has been used. 

 
Solution:
I hopped inside the mysql container then and altered the root user to use mysql_native_password using below command:
ALTER USER root IDENTIFIED WITH mysql_native_password BY 'pw';
 
After that, I was able to connect using mysql -u root  -p -h 172.20.0.2. Note that the IP address came from the output I got from executing the command docker inspect <container id>.
 
 

7.	Upon trying to run an app container using the app image, I ran into this error saying connection refused to the DB.

 

Solution:
I have exported the wrong IP address (127.0.0.1) and port (3307). After knowing the correct IP address using below command, I exported it again and also changed the port to 3306.
docker inspect \
>   -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' be03bdda6e67

This is where I noticed I exported the wrong port:
	 
 

8.	Even though I have already set the APP_COLOR, it keeps on defaulting to lime. I then inspected the variables inside the container and I did not see APP_COLOR. Hence, I added the environment variable in the docker run command.
Command:
docker run -p 8081:8080  -e DBHOST=$DBHOST -e DBPORT=$DBPORT -e  DBUSER=$DBUSER -e DBPWD=$DBPWD  -e APP_COLOR=$APP_COLOR --name blue --network new-network --link mysql-db:mysql-db b1b608a23e1e

 

9.	After all 3 app containers are up, I was about to check if I can access them through the internet. But then I was not able to do so. I thought it might be something with networking. Initially I thought perhaps I need to create a load balancer but I remember that the EC2 is in a public subnet and it has a public IPv4 address. 

Solution:
I then went to check the security group and added a new rule to allow all traffic instead of only those coming using TCP protocol through port 80. Doing that resolved the issue.
 


10.	I cannot ping the other containers due to the error
 

Solution:
Install ping using:
-	apt-get update -y
-	apt-get install -y iputils-ping
I also added this in the Dockerfile so we dont need to manually do this step for new image builds.


Was able to ping after that.
 

