#!bin/bash
#==============================================================================================================================#
#--------------------------------------------# AWS EC2 INSTANCE CREATION #-----------------------------------------------------# 
#==============================================================================================================================#
#AUTHOR : SAI SATYA TEJA GUNISETTI
#-------------------------------------------------# VARIABLES #----------------------------------------------------------------# 
region=$1
vpc_cidr=$2
vpc_name=$3
#---------------
az=$4
sub1_cidr=$5
sub2_cidr=$6
subnet1_name=$7
subnet2_name=$8
#---------------
igw_name=$9
#---------------
route_table_name=${10}
#----------------
sg_name=${11}
#----------------
instance_name=${12}
instance_type=${13}
#------------------------------------------------------------------------------------------------------------------------------# 

#--------------------------------------------------# CREATING VPC #------------------------------------------------------------# 
vpcId=$(aws ec2 create-vpc --cidr-block $vpc_cidr  \
                           --region $region  \
                           --tag-specification 'ResourceType=vpc,Tags=[{Key=Name,Value='$vpc_name'}]' \
                           --query Vpc.VpcId \
                           --output text)

echo "Vpc is created with ID : "$vpcId
#------------------------------------------------------------------------------------------------------------------------------# 

#------------------------------------------------# CREATING SUBNET1 #----------------------------------------------------------# 
subnet1=$(aws ec2 create-subnet --vpc-id $vpcId \
                                --cidr-block $sub1_cidr \
                                --region $region  \
                                --availability-zone $az \
                                --tag-specification 'ResourceType=subnet,Tags=[{Key=Name,Value='$subnet1_name'}]' \
                                --query Subnet.SubnetId \
                                --output text)

echo "Subnet1 is created with ID : "$subnet1
#------------------------------------------------------------------------------------------------------------------------------# 

#------------------------------------------------# CREATING SUBNET2 #----------------------------------------------------------#
subnet2=$(aws ec2 create-subnet --vpc-id $vpcId \
                                --cidr-block $sub2_cidr \
                                --region $region  \
                                --availability-zone $az \
                                --tag-specification 'ResourceType=subnet,Tags=[{Key=Name,Value='$subnet2_name'}]' \
                                --query Subnet.SubnetId \
                                --output text)

echo "Subnet2 is created with ID : "$subnet2
#------------------------------------------------------------------------------------------------------------------------------# 

#-------------------------------------------# CREATING INTERNET-GATEWAY #------------------------------------------------------ 
igw=$(aws ec2 create-internet-gateway --tag-specification 'ResourceType=internet-gateway,Tags=[{Key=Name,Value='$igw_name'}]' \
                                           --query InternetGateway.InternetGatewayId \
                                           --output text )

echo "Internet-Gateway is created with ID : " $igw

#------------------------------------------------------------------------------------------------------------------------------# 

#--------------------------------------# ATTACHING INTERNETGATEWAY TO VPC #----------------------------------------------------#
aws ec2 attach-internet-gateway --vpc-id $vpcId \
                                --internet-gateway-id $igw

#------------------------------------------------------------------------------------------------------------------------------# 

#--------------------------------------------# CREATING ROUTE-TABLE #----------------------------------------------------------#
rt_id=$(aws ec2 create-route-table --tag-specification 'ResourceType=route-table,Tags=[{Key=Name,Value='$route_table_name'}]' \
                                   --vpc-id $vpcId \
                                   --query RouteTable.RouteTableId \
                                   --output text)

echo "RouteTable is created with ID : "$rt_id
#------------------------------------------------------------------------------------------------------------------------------# 

#-------------------------------------# CREATING ROUTE FOR INTERNETGATEWAY #---------------------------------------------------#
igw_route=$(aws ec2 create-route --route-table-id $rt_id \
                                 --destination-cidr-block 0.0.0.0/0 \
                                 --gateway-id $igw
                                  \
                                 --query Return \
                                 --output text)

echo "route between igw-vpc is created : "$igw_route
#------------------------------------------------------------------------------------------------------------------------------#

#--------------------------------------------# CREATING SECURITY-GROUP1 #------------------------------------------------------#
sg_id=$(aws ec2 create-security-group --vpc-id $vpcId \
                                      --tag-specification 'ResourceType=security-group,Tags=[{Key=Name,Value='$sg_name'}]' \
                                      --description this-is-a-test-$sg_name-sg \
                                      --group-name $sg_name  \
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
                                    --instance-type $instance_type \
                                    --key-name local_ohio \
                                    --security-group-ids $sg_id \
                                    --subnet-id $subnet1 \
                                    --associate-public-ip-address \
                                    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='$instance_name'}]' \
                                    --query Instances[0].InstanceId \
                                    --output text)

echo "EC2 instance is created with id : "$instance_id
#------------------------------------------------------------------------------------------------------------------------------#
#------------------------------------------------------------------------------------------------------------------------------# 



