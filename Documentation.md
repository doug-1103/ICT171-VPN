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
This project aims to use Infrastructure as a Service (IaaS) in order to deploy an OpenVPN server using AWS EC2 to provide secure VPN access. We will be using Route 53 to link a domain name to our server. We will also be using EasyRSA in order to handle the creation of the necessary certificates. The reasons for choosing OpenVPN are:
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

### SSH into the EC2 server
Use the following command replacing the path, file name and IP address with the necessary values:
```bash 
ssh -i your-key.pem ubuntu@[your-elastic-ip]
```
### Update Server
We will use the following command to update and prepare the server.
```bash
sudo apt update && sudo apt upgrade -y
```

### Install OpenVPN and Easy-RSA
The following commands install the OpenVPN and EasyRSA packages on the server.
```bash
sudo apt install openvpn -y
sudo apt install easy-rsa -y
```

### Setup Certificate Authority
The following commands create the Certificate Authority (CA) on the server to securely manage and sign the certificates that OpenVPN needs for authenticating the server and clients.
```bash
make-cadir~/openvpn -ca
cd~/openvpn -ca
./easyrsa init-pki
./easyrsa build-ca nopass
```

## VPN Server Configuration
This next section focuses on creating the server keys and ensuring that the adequate server.conf file is correct.

### Generate Server Keys
The following commands create the server certificates.
```bash
./easyrsa gen-req server nopass
./easyrsa sign-req server server
```
The next commands create the client certificates.
```bash
./easyrsa gen-req client1 nopass
./easyrsa sign-req client client1
```

### Generate Diffie-Hellman key
The following command creates the Diffie-Hellman key for establishing a shared secret key
```bash
./easyrsa gen-dh
```

### Move Files
After the appropriate keys have been created, they need to be moved into the OpenVPN directory for OpenVPN to recognise them. The following command moves the necessary keys. The files we want to move are:
- ca.crt
- server.crt
- server.key
- dh.pem
```bash
sudo cp pki/ca.crt pki/issued/server.crt pki/private/server.key pki/dh.pem /etc/openvpn/
```

### Server Configuration File
A server.conf file needs to be allocated, a template of this is available in this GitHUB repository.
[Download server.conf](./server.conf)

Alternatively a sample copy is provided and can be copied into the OpenVPN directory.
```bash
sudo cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/server.conf
```
Next we need to ensure that the directives point to the correct files by opening the file with:
```bash
sudo nano etc/openvpn/server.conf
```
Ensure that the directives point to the following files:
```bash
ca ca.crt
cert server.crt
key server.key
dh dh.pem
```
Uncomment the following command to ensure that all internet traffic is redirected.
```bash
push "redirect-gateway def1 bypass-dhcp"
```

### IP Forwarding
Next IP forwarding needs to be enabled to allow the OpenVPN server to route traffic from the VPN clients to the internet.

### Enable IP Forwarding
In the terminal open the file with the following command
```bash
sudo nano /etc/sysctl.conf
```
Ensure that the following line is uncommented.
```bash
net.ipv4.ip_forward=1
```
Enter the following command into the terminal.
```bash
sudo sysctl -p
```

### Configure iptables
The following command allows for Network Address Translation (NAT) to allow traffic from connected VPN clients to be rewritten to appear to come from the VPN server.
```bash
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o
```
## Configure UFW firewall
Allow SSH and OpenVPN on the UFW firewall.
```bash
sudo ufw allow ssh
sudo ufw allow 1194/udp
```
### Enable IP forwarding through UFW
Open the UFW configuration file with
```bash
sudo nano /etc/ufw/before.rules
```
At the top before any *filter lines, add.
```bash
*nat
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
COMMIT
```
### Ensure UFW forwards packets
Edit:
```bash
sudo nano /etc/default/ufw
```
Ensure the following is set:
```bash
DEFAULT_FORWARD_POLICY="ACCEPT"
```

### Enable UFW
```bash
sudo ufw enable
```

## Start OpenVPN Server
Use the following commands to start the OpenVPN server.
```bash
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server
```
Check the status with.
```bash
sudo systemctl status openvpn@server
```

## Domain Name Configuration
Having a Domain Name allocated for our server will ensure that configuration files that require the servers public IP address won't change after a shutdown or restart of the server.
### Setup AWS Route 53:
- Register a domain via Route 53. The following is the registered domain name for the server.
  - ict-171-openvpnproject.com
- Create a Hosted Zone in Route 53.
- Add an A record that points to the EC2 IP address with the following values.
  - Record Name: (Blank)
  - Record Type: A record
  - Value: 16.176.9.234 (Servers Elastic IP address)
- Test connectivity by pinging the allocated domain name:
```bash
ping ict-171-openvpnproject.com
```

## Client Configuration
Now that the OpenVPN server is running and the domain name is associated we need to configure client device by copying the necessary certification files to the client device and creating a client .ovpn file. The files we need to copy are:
- ca.crt (This is the certificate authority)
- client1.crt (This is the devices unique certificate)
- client1.key (The devices private key)

### Client configuration .ovpn file
A .ovpn fiile used for client configuration is able to be downloaded from this repository. [Download .ovpn file](./client1.ovpn)

## Copying certificate files to local device
The certificate files need to be copied using Secure Copy Protocol (scp) to the local device. On the local devices terminal enter the following commands, changing the path, key.pem and IP address to the appropriate values.
```bash
scp -i path/to/key.pem 'ubuntu@<IPaddress>: /home/ubuntu/openvpn-ca/pki/ca.crt' ca.crt
scp -i path/to/key.pem 'ubuntu@<IPaddress>: /home/ubuntu/openvpn-ca/pki/issued/client1.crt' client1.crt
scp -i path/to/key.pem 'ubuntu@<IPaddress>: /home/ubuntu/openvpn-ca/pki/private/client1.key' client1.key
```

## Connecting to the OpenVPN server
To connect to the OpenVPN server we need to download the OpenVPN GUI and import the client1.ovpn file.
[Download the OpenVPN GUI](https://openvpn.net/community-downloads/)
To import the client1.ovpn file, right click on the icon and click import file, once the file is imported right click again and press connect.
![image](https://github.com/user-attachments/assets/646eeb15-0bea-41e2-aef4-a6f53a365e83)
After successfully connecting it should show the following.
![image](https://github.com/user-attachments/assets/6cd49002-4e28-443f-bcac-8cebfd1dbe7c)
We can further test connectivity by visiting "Whats My Ip Address" [here](https://whatsmyipaddress.com). We can see it shows the following.
![image](https://github.com/user-attachments/assets/caf4ea6d-9403-4f4a-a601-9dc0d9c5ada1)
From these screenshots we can see that we are tunnelling to our OpenVPN server with our local IP address, we are then connecting to the internet from the servers Elastic IP address of 52.65.222.69. This is further corroborated by the ISP being outlined as Amazon Technologies Inc.

## Coding/Scripting Component
For my scripting component, I have created a status checker for the VPN that parses through the VPN logs with awk commands and then creates a new log file with the information on current connected users. In the log file it echoes the current users connected, bandwidth and how long they have been connected for.
The bash file of this script is available in the GIThub repository [here](./vpn_status.sh)






