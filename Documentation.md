## OpenVPN Documentation

Structure:
- Introduction
- System Requirements
- Server Provisioning (AWS Setup)
- OpenVPN Installation and Configuration
- Domain Configuration (Route 53 Setup)
- Security Hardening (basic UFW rules)
- Testing VPN Connection
- Coding/Scripting Component
- Conclusion

## Introduction
This project aims to use Infrastructure as a Service (IaaS) in order to deploy an OpenVPN server using AWS EC2 to provide secure VPN access. We will be using Route 53 to link a domain name to our server. The reasons for choosing OpenVPN are:
- Open-source and highly customisable.
- Strong community support.
- Licensed under GPLv2.

## System Requirements
- Cloud Provider: AWS EC2
- Operating Software: Ubuntu Server 24.04 (t2 micro)
- VPN Software: OpenVPN Community Edition
- Domain Provider: AWS Route 53

## Server Creation
Steps:
- Log into AWS Console
- Launch EC2 instance with:
  - Ubuntu 24.04
  - T2.micro
  - Assign Elastic IP
  - Attach Custom Security Group

Security Group Rules:
|Protocol|Port    |Source        |      Reason      |
|--------|--------|--------------|------------------|
|SSH     | 22     | My Ip Only   | Remote Management|
|OpenVPN |1194(UDP| Anywhere IPv4| VPN Connections  |
|ICMP    | All    | Anywhere IPv4| Test Connectivity|

## Server Configuration
In this section we configure the server by updating the server and installing the necessary packages, including the OpenVPN and EasyRSA packages.

# SSH into the EC2 server
Use the following command replacing the path, file name and IP address with the necessary values:
<pre> ```bash ssh -i your-key.pem ubuntu@[your-elastic-ip]``` </pre>
