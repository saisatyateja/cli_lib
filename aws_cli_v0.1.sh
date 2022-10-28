#!bin/bash
#==============================================================================================================================#
#--------------------------------------------# AWS EC2 INSTANCE CREATION #-----------------------------------------------------# 
#==============================================================================================================================#
#AUTHOR : SAI SATYA TEJA GUNISETTI
#BATCH  : JOIP2 
#INSTITUTION NAME : QUALITY THOUGHT
#--------------------------------------------------# CREATING VPC #------------------------------------------------------------# 
vpcId=$(aws ec2 create-vpc --cidr-block 10.0.0.0/23  \
                           --region us-east-2  \
                           --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value=ohio_vpc}]' \
                           --query Vpc.VpcId \
                           --output text)

echo "Vpc is created with ID : "$vpcId
#------------------------------------------------------------------------------------------------------------------------------# 

#------------------------------------------------# CREATING SUBNET1 #----------------------------------------------------------# 
subnet1=$(aws ec2 create-subnet --vpc-id $vpcId \
                                --cidr-block 10.0.0.0/24 \
                                --region us-east-2 \
                                --availability-zone us-east-2a \
                                --tag-specification 'ResourceType=subnet,Tags=[{Key=Name,Value=sub1}]' \
                                --query Subnet.SubnetId \
                                --output text)

echo "Subnet1 is created with ID : "$subnet1
#------------------------------------------------------------------------------------------------------------------------------# 

#------------------------------------------------# CREATING SUBNET2 #----------------------------------------------------------#
subnet2=$(aws ec2 create-subnet --vpc-id $vpcId \
                                --cidr-block 10.0.1.0/24 \
                                --region us-east-2 \
                                --availability-zone us-east-2a \
                                --tag-specification 'ResourceType=subnet,Tags=[{Key=Name,Value=sub2}]' \
                                --query Subnet.SubnetId \
                                --output text)

echo "Subnet2 is created with ID : "$subnet2
#------------------------------------------------------------------------------------------------------------------------------# 

#-------------------------------------------# CREATING INTERNET-GATEWAY #------------------------------------------------------#
ohio_igw=$(aws ec2 create-internet-gateway --tag-specification 'ResourceType=internet-gateway,Tags=[{Key=Name,Value=ohio_igw}]' \
                                           --query InternetGateway.InternetGatewayId \
                                           --output text )

echo "Internet-Gateway is created with ID : "$ohio_igw
#------------------------------------------------------------------------------------------------------------------------------# 

#--------------------------------------# ATTACHING INTERNETGATEWAY TO VPC #----------------------------------------------------#
aws ec2 attach-internet-gateway --vpc-id $vpcId \
                                --internet-gateway-id $ohio_igw
#------------------------------------------------------------------------------------------------------------------------------# 

#--------------------------------------------# CREATING ROUTE-TABLE #----------------------------------------------------------#
rt_id=$(aws ec2 create-route-table --tag-specification 'ResourceType=route-table,Tags=[{Key=Name,Value=rt}]' \
                                   --vpc-id $vpcId \
                                   --query RouteTable.RouteTableId \
                                   --output text)

echo "RouteTable is created with ID : "$rt_id
#------------------------------------------------------------------------------------------------------------------------------# 

#-------------------------------------# CREATING ROUTE FOR INTERNETGATEWAY #---------------------------------------------------#
igw_route=$(aws ec2 create-route --route-table-id $rt_id \
                                 --destination-cidr-block 0.0.0.0/0 \
                                 --gateway-id $ohio_igw \
                                 --query Return \
                                 --output text)

echo "route between igw-vpc is created : "$igw_route
#------------------------------------------------------------------------------------------------------------------------------#

#--------------------------------------------# CREATING SECURITY-GROUP1 #------------------------------------------------------#
sg_id=$(aws ec2 create-security-group --vpc-id $vpcId \
                                      --tag-specification 'ResourceType=security-group,Tags=[{Key=Name,Value=ohio-sg}]' \
                                      --description this-is-a-test-on-ohio-vpc \
                                      --group-name ohio-sg  \
                                      --query GroupId \
                                      --output text) 

echo "SecurityGroup is created with ID : "$sg_id
#------------------------------------------------------------------------------------------------------------------------------# 

#------------------------------------# AUTHORIZING SECURITY-GROUP-INGRESS RULES #----------------------------------------------#
port_all=$(aws ec2 authorize-security-group-ingress --group-id $sg_id \
                                                    --protocol icmp \
                                                    --cidr 0.0.0.0/0 \
                                                    --port -1 \
                                                    --query Return \
                                                    --output text)

echo "port ALL established : "$port_all
#______________________________________________________________________________________________________________________________#
port_22=$(aws ec2 authorize-security-group-ingress --group-id $sg_id \
                                                   --protocol tcp  \
                                                   --cidr 0.0.0.0/0 \
                                                   --port 22 \
                                                   --query Return \
                                                   --output text)

echo "port 22 established : "$port_22
#______________________________________________________________________________________________________________________________#
port_8080=$(aws ec2 authorize-security-group-ingress --group-id $sg_id \
                                                     --protocol tcp  \
                                                     --cidr 0.0.0.0/0 \
                                                     --port 8080 \
                                                     --query Return \
                                                     --output text)

echo "port 8080 established : "$port_8080
#------------------------------------------------------------------------------------------------------------------------------# 

#--------------------------------------# ASSOCIATING SUBNETS WITH ROUTE-TABLE #------------------------------------------------#
sub_asso=$(aws ec2 associate-route-table --subnet-id $subnet1 \
                                         --route-table-id $rt_id \
                                         --query AssociationState.State 
                                         --output text)

echo "subnet1 association with routetable is : "$sub_asso
#______________________________________________________________________________________________________________________________# 
sub_asso=$(aws ec2 associate-route-table --subnet-id $subnet2 \
                                         --route-table-id $rt_id \
                                         --query AssociationState.State 
                                         --output text)

echo "subnet2 association with routetable is : "$sub_asso
#------------------------------------------------------------------------------------------------------------------------------# 

#--------------------------------------------# CREATING AN EC2 INSTANCE #------------------------------------------------------#
instance_id=$(aws ec2 run-instances --image-id ami-097a2df4ac947655f \
                                    --count 1 \
                                    --instance-type t2.micro \
                                    --key-name local_ohio \
                                    --security-group-ids $sg_id \
                                    --subnet-id $subnet1 \
                                    --associate-public-ip-address \
                                    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=cli_ec2}]' \
                                    --query Instances[0].InstanceId \
                                    --output text)

echo "EC2 instance is created with id : "$instance_id
#------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------# 



