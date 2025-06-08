# ICT171-VPN
## Link To Website:
https://ict-171-openvpnproject.com/
- Username: ICT171VPN
- Password: 0p4nV9nICT-171

## Link To Video Explainer:
- https://youtu.be/ZayiCVoYp5Q

To Access VPN:
- Download client1.ovpn and ca.crt file from website.
- Download the OpenVPN Community Edition GUI through the link provided on the website.
- Import the client1.ovpn file as shown in the documentation.
- Click connect and it shall successfully initialise.

# Author
- Douglas Phillip
- Student Number: 35098249

# Description
- This project demonstrates the use of IaaS to deploy an OpenVPN server on AWS EC2. 

# Features
- OpenVPN server configured using EASY-RSA certificates.
- Route 53 domain: 'ict-171-openvpnproject.com'
- Client '.ovpn' file used for connectivity

# Repository Contents
- 'server.conf' - OpenVPN server configuration
- 'client1.ovpn' - OpenVPN client configuration
- 'documentation.md' - Project documentation markdown.
- 'vpn_status_script.sh' - VPN status logger
- 'index.html' - The HTML script for the webpage component

# How to Connect
Use the provided '.ovpn' file in on the OpenVPN client. Ensure UDP port 1194 is open.
