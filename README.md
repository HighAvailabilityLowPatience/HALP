# HALP
Enterprise-style home lab for building, testing, and showcasing skills.
HALP – Home Lab for Advanced Networking & DevOps

HALP is a personal home lab project designed to simulate enterprise-style network environments. This lab is a playground for testing, learning, and showcasing skills in DevOps, networking, virtualization, and cloud deployment.

🏗️ Project Goals

This lab aligns with my DevOps training plan and is designed to develop hands-on expertise in:

Network engineering

Virtualization and server management

Cloud infrastructure management and deployments

Monitoring and automation

Containerization and CI/CD

MLOps

Create a demonstrable portfolio of my skills.

✅ Week 1 Wins

Network Diagram: Initial visual plan of the lab infrastructure (Version 1) uploaded. This serves as the blueprint for all lab configurations.

Proxmox VE Installed: Both mini PCs are ready for virtual machines, forming the backbone of the lab environment.

Hypervisor Access: Full access to create, manage, and interconnect VMs directly on the network.

These achievements mark the first step in building practical skills in networking, virtualization, and lab management.


✅ **Week 2 Wins**
- Configured Cisco router and switch with VLANs for mini PCs.  
- Replaced old AP with TP-Link Bravo Echo 6500 to solve PoE and double NAT issues.  
- Troubleshot Cisco + TP-Link compatibility quirks, verified PCs stayed functional.  
- Backed up all configs and pushed encrypted version to GitHub.  
- Learned the importance of device compatibility, subnet stability, and simplifying SSIDs.  

---

✅ **Week 3 Wins**
- Isolated IoT devices from the internal network, verified segmentation with pings.  
- Hardened network by disabling unnecessary ping/discovery responses.  
- Configured VPN server + TunnelBlick client with cert-based auth (still testing external access).  
- Deployed first Windows Server VM, resolved driver/boot order issues, and set DNS/DHCP properly.  
- Reinforced lessons in persistence, troubleshooting, and the importance of details.  



📂 **Current Version**
- Network Diagram V2: `networking/NETWORK DIAGRAM V2.svg`

🔧 **Tools & Tech**
- Proxmox VE – Virtualization platform  
- Cisco networking gear  
- TP-Link Bravo Echo 6500  
- VPN + Windows Server (initial deployment)  

** Week 4 Update

Week 4 focused on network roles, IP management, and remote access configuration:

Windows Server DHCP cleanup: Removed the DHCP role to prevent the server from handing out IPs incorrectly. Rebooted the router and adjusted the IP address pool to ensure proper network isolation.

Windows Server IP configuration: Assigned the server to a specific IP lane to maintain consistent routing and network segmentation.

Ubuntu Server deployment: Created a new VM, assigned a static IP, and enabled SSH for remote management.

Remote development setup: Added a new VS Code Remote SSH connection to manage the Ubuntu server. Configured UFW to restrict access to the internal network and VPN only.

DNS setup: Configured Windows Server DNS alpha records to resolve Proxmox hypervisors (proxmox1.virio.local, proxmox2.virio.local) and the dev VM (dev.virio.local).

✅ Takeaways:

Proper DHCP management is critical for network segmentation.

Static IPs and reserved addresses simplify service connectivity.

SSH and firewall rules ensure secure remote access.

DNS configuration enables consistent, predictable network addressing for lab resources.

📂 **Current Version**
- Network Diagram V3: `networking/NETWORK DIAGRAM V3.svg`


🔧 Tools & Tech – Week 4

Windows Server – DHCP role removed, DNS alpha records configured

Ubuntu Server – VM deployment, static IP, SSH enabled

VS Code – Remote SSH connection for server management

UFW (Uncomplicated Firewall) – Restrict access to internal network and VPN

Proxmox VE – Hypervisor management, connected via DNS
