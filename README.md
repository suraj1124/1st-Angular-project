# MyAngularProject

This is a sample Angular application developed for the hands-on examples on the [AWS CodePipeline Step by Step](https://www.udemy.com/course/aws-codepipeline-step-by-step/?referralCode=483BFB904E136DB2D86B) course by Emre Yilmaz.

## Development server

Run `ng serve` for a dev server. Navigate to `http://localhost:4200/`. The app will automatically reload if you change any of the source files.

## Code scaffolding

Run `ng generate component component-name` to generate a new component. You can also use `ng generate directive|pipe|service|class|guard|interface|enum|module`.

## Build

Run `ng build` to build the project. The build artifacts will be stored in the `dist/` directory. Use the `--prod` flag for a production build.

## Running unit tests

Run `ng test` to execute the unit tests via [Karma](https://karma-runner.github.io).

## Running end-to-end tests

Run `ng e2e` to execute the end-to-end tests via [Protractor](http://www.protractortest.org/).

## Further help

To get more help on the Angular CLI use `ng help` or go check out the [Angular CLI README](https://github.com/angular/angular-cli/blob/master/README.md).


----------------------------------------------------------------------------------
Write by Suraj
# setup your Git Repository 
    

# Deploy build Artifact to ec2 instance 
1. Ec2 instance pull new deployment from AWS CodeDeploy
2. Ec2 instance communicate with codedeploy through a software package called CodeDeploy Agent
3. The code deploy agent download the revision containing the source code, the Appspec file, the deployment script from the S3
4. Ec2 Instance needs permission to access this s3 bucket via an IAM Role 
5. After downloading the recision, the Code Deploy Agent performs the deployment according the Appsepc File. 

# Steps
1. Create IAM role for Ec2 Instance and selete manage policy to provied permission to Ec2 inatances for codedeploy deployment. 
2. select policy as needed (Policy : AmazoneEc2RoleforWASCodeDeploy)
3. Create Ec2 Inatance with require details. 
4. Inastall CodeDeploy Agent to EC2 Instance  ec2-instance-commands.txt
   # Refereance to Installing CodeDeploy Agent
        sudo yum update -y
        sudo yum install -y ruby wget
        # Change the AWS regions according to your Ec2 instance created in the reagion
        wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install
        chmod +x ./install
        sudo ./install auto
        sudo service codedeploy-agent status

5. # Installing Nginx
        sudo amazon-linux-extras install -y nginx1
        #or
        sudo dnf install -y nginx

        # Checking Nginx status
        sudo service nginx status

        # Starting Nginx
        sudo service nginx start

        # Enabling Nginx to restart on system reboot
        sudo chkconfig nginx on

        # Creating folders for deployments
        sudo mkdir -p /var/www/my-angular-project

        # Changing Nginx configuration to chage the root path you craeted "/var/www/my-angular-project" to hosted website otherwise nginix surve default page 
        sudo vi /etc/nginx/nginx.conf

        # Only change root to /var/www/my-angular-project
        # save the change and exit 

        # Restart Nginx
        sudo service nginx restart




# Create AWS Code pipeline 
1. Create new pipeline
    # Step 1 : Create connection for your source repository
        1. go to the pipeline under setting click on connections
        2. click create connection 
        3. select your provider 
        4. give the connection name and click connect to github for example i using github
        5. it will redirict to github account to authorise github connector.
        6. install the github connector to use in codepipeline.
        7. again it will be redirict to guthub account to choose your github identy to use in aws codepipeline. 
        8. it will ask you to chosse github repository either specefic or all *Be Ensure it will only install github connector for the repository which you will be selecting. 
    # Setup 2 AWS CodePipeline configuration 
        # Chosse Pipeline Setting         
            1. go to AWS Code pipeline  and click AWS Code pipeline 
            2. in Category select build custome pipeline and click next 
            3. give Pipeline name
            4. keep the Execution mode Queued 
            5. create new Service role and keep the defauld role name or change as you Preferred.
            6. in the Advanced settings choose default location here aws will create s3 bucket to manage and store artifacts or you also can choose existing location if you have. and keep the aws manage key default. or you can define you own custome. then click next 
        # Add Source Stage 
            1. in the source provider select you source provider and click next, as i selected github 
            2. in the connection choose your connection you created.
            3. follow with your repository name and your branch *only those repository will be displayed which you installed the connectore.
            4. in Output artifact format keep CodePipeline defualt
            5. setup your Webhook events as you preferred. 
        # Add Build Stage
            # need to know some points about Buildspec
                > codebuild pull source artiface from guthub repository and build artifact then send to amazone S3 to store (Store artifact to s3 is aws managed service)
                > you can provied you commands under the build phases they will executed such as install, pre buid, build, post build.
                > you can define runtime in the phases.
                > output aryifacts are defined in your buildspec
                > you configure which file or folder will be included in your artifact and their base directory.
                > not every build project produse an artifact, such as building docker images and publishing to amazon ECR.
                > you can define environment variables for your build environment as key/value paiers in your buildspec
                > beside AWS codebuild has integrations with EC2 system manager paramiters store and aws secrets manager.
                > Also you can define environment varoables in the codebuild project setting outside your buildspec and use them in reuseable for multiple build project.
                > you can create different buildspec file for different codebuild project in your source repository. Exe. buildspec file for unit-test before build the source code. 
                > data-in-transit is encrypted via SSL certificates and signature v4 siniging process
                > data-at-rest is encrypted via your CMS for amazon S3 key are manages bydefault bu KMS 
                > pipeline use IAM service role to execute your codebuild project 
            1. in the build option select the build provider 
            2. select AWS codebuild and click next, you can also select jenkins and AWS ECR
            3. in Project name create new or  select you existing project
            4. click on create new it will open another page to configure project
            5. give Project name
            6. Project type keep default 
            7. Environment follow the Provisioning model as preferred recomended for follow aws documented page to check supported runtime codebuil images.
            8. Service role create new keep the default name and custome 
            9. Additional configuration keep defult or set as preferred 
            10. Buildspec select use buildspec file it will look for default name buildspec.yml or you can set as preferred based on your repository structures 
            11. Batch configuration keep default or you can defile as preferred.
            12. Logs recomended to select checkbox for cloudwatch log. 
            13 click to continue to codepileline 
            14. Environment variables - optional
            15. Build type select single build default or bach build as preferred.
            16. select the Region
            17. Input artifacts select the source artifact
            18 uncheck Enable automatic retry on stage failure if not needed.
            19. cleck next
        # Add test stage
            1. Test - optional or you can proceed as preferred.

        # Add deploy stage
            1. you need to create setup codedeploy 1st follow below steps.
                # go to the aws codedeply and create codedeploy Application 
                1.1 give name 
                1.2 select compute platform Ec2/On-primies 
            2. create role for CodeDeploy 
                2.1 got to IAM role and create role for CodeDeploy 
                2.2 bydefault policy: AWSCodeDeployRole selected and click next 
                # it need more permission to become a complete codedeploy servise role for ec2 instances 
                2.3 got to the role you just created 
                2.4 got to add permision and click inlile policy to policy editor 
                2.5 go to json editor do the below changes in {"Action and "Resource"} only provide resource "*" asterisk or specific ARN as needed 
                    "Action": ["ec2:RunInstances", "ec2:CreateTags", "iam:PassRole"],
                    "Resource": "*"
                2.6 Click next to continue 
                2.7 give policy name 
            3. create deployment group inside dodedeploy Application 
                3.1 give name 
                3.2 select role you create and follow steps as needed 
                3.3 in Deployment type keep in-place since we are not using bluegreen deployment 
                3.4 In the Environment configuration select Amazon EC2 Instance as we are not using load balancer and provide Tags to match Ec2 Instance. you can provied multipule tags if you want to deploy deployment on more then one ec2 instance 
                3.5 choose the Deployment settings as needed 
                3.5 uncheck the Enable load balancing as not using.
            4. Now in the codedeploy pipeline add in deploy stage by click + button  Add Action Group 
            5. give the action name 
            6. in Action provider select AWS codedeploy 
            7. give the Region name 
            8. in Input artifacts select build artifacts 
            9. in the Application name select the code deploy applicated you created 
            10. in the Deployment group select the Deployment group you created 
            11. Configure automatic rollback on stage failure follow as preferred
            12. save the change.
            
