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




🚀 Home Lab Journey – Week 5 Update

Week 5 focused on setting up Prometheus monitoring and Node Exporter in the home lab:

Proxmox VM Spin-Up: Created a new Linux VM for Prometheus, manually configuring network settings (IP, DNS) to integrate into the lab subnet.

Environment Setup: Enabled OpenSSH for VS Code remote editing. Configured UFW firewall rules to allow necessary ports while maintaining security.

Prometheus Installation:

Downloaded and extracted Prometheus binaries to /home/vireogod/prometheus_install/prometheus.

Configured prometheus.yml with scrape targets (Linux, Windows, bare metal, router) on ports 9100, 9182, etc.

Verified syntax and paths with promtool check config.

Systemd Service:

Created prometheus.service in /etc/systemd/system/.

Defined service parameters: user, executable path, config, storage, console templates, and restart policy.

Enabled and started service with systemctl, troubleshooting path, flag, and port issues.

Node Exporter Setup:

Downloaded and installed Linux node_exporter binaries to /usr/local/bin/.

Verified access via curl http://192.168.**.***:9100/metrics.

Configured UFW to restrict access to the network and VPN.

Validation & Troubleshooting:

Fixed Prometheus service startup errors.

Confirmed Prometheus is actively scraping the Linux VM.

Other targets show DOWN until exporters are installed, which is expected.

Verified TCP connectivity with nc/curl to ensure proper scraping.

✅ Outcome:
Prometheus is running as a systemd service and successfully scraping the Linux VM. All endpoints are visible in the dashboard, with Linux VM showing UP; other targets remain DOWN until exporters are deployed.

#DevOps #HomeLab #Monitoring #Prometheus #NodeExporter #Linux #Proxmox #LearningByDoing #UFW #SSH

🔧 Tools & Tech – Week 5

Linux VM (Proxmox) – Hosts Prometheus and Node Exporter

Prometheus – Monitoring service, systemd-managed

Node Exporter – Metrics collection for Linux VM

VS Code – Remote SSH for configuration

UFW – Firewall configuration for secure access

Proxmox VE – Hypervisor management

***** Home Lab Journey – Week 6 Update*******

Week 6 focused on building a full monitoring stack for Linux, Windows, and Proxmox nodes:

Windows Exporter Setup

Installed Windows Exporter on the Windows Server, listening on port 9182 with default collectors.

Verified via curl and Prometheus targets page.

Fixed connectivity issues caused by IP misconfigurations and firewall rules.

Node Exporter Setup on Proxmox

Accessed Proxmox shell for both hypervisors.

Installed Linux AMD64 Node Exporter in /usr/local/bin.

Verified with /usr/local/bin/node_exporter --version.

Opened port 9100 and confirmed Prometheus could scrape metrics.

Prometheus Scrape Configuration

Updated prometheus.yml with targets for Linux VM, Windows Server, Proxmox nodes, and bare-metal servers.

Fixed paths and syntax issues in Prometheus systemd service.

Restarted Prometheus and confirmed all targets were being scraped successfully.

Grafana Dashboard Setup

Installed Grafana on the monitoring VM (port 3000).

Logged in with default credentials, created dashboards, and imported Node Exporter dashboard for Proxmox metrics.

Began creating Windows Exporter dashboard and explored prebuilt vs. custom panels.

Verified Prometheus target health for Windows.

DNS Setup (Windows Server)

Added A records:

monitor.vireo.local → Prometheus VM

windows.vireo.local → Windows Server

Verified using nslookup for easy internal resolution.

Troubleshooting & Learnings

Fixed firewall and port issues across Linux/Proxmox nodes.

Learned Prometheus scraping mechanics and exporter differences.

Explored Grafana dashboard queries, panels, and syslog forwarding options for future expansion.

Achieved full monitoring stack: Linux/Proxmox/Windows metrics reporting to Prometheus; Grafana dashboards for Proxmox ready, Windows panels in progress.

✅ Outcome:

Prometheus scrapes Linux, Windows, and Proxmox nodes.

Grafana is visualizing Proxmox metrics and ready to expand Windows dashboards.

DNS simplified access via monitor.vireo.local and windows.vireo.local.

Windows Exporter functioning; monitoring stack operational.

#DevOps #HomeLab #Monitoring #Prometheus #Grafana #NodeExporter #WindowsExporter #Linux #Proxmox #DNS #LearningByDoing

🔧 Tools & Tech – Week 6

Windows Server – Windows Exporter, DNS configuration

Linux VM / Proxmox nodes – Node Exporter, Prometheus targets

Prometheus – Metrics scraping and systemd service

Grafana – Dashboard creation and visualization

VS Code – Remote SSH management

UFW / Firewalls – Secure access to Prometheus and exporters
