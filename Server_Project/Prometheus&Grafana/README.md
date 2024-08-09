# Configuration Prometheus - Step by Step
## 1. Update System
```bash
sudo apt update
sudo apt upgrade
```
## 2. Install dependencies
```bash
sudo apt install -y curl wget vim
```
## 3. Preparing the Environment
```bash
sudo useradd --no-create-home --shell /bin/false prometheus
sudo useradd --no-create-home --shell /bin/false node_exporter
mkdir /etc/prometheus
mkdir /var/lib/prometheus
```
## 4. Download Prometheus
```bash
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.53.1/prometheus-2.53.1.linux-amd64.tar.gz 
# Take the latest version from https://prometheus.io/download/
tar -xvzf prometheus-2.53.1.linux-amd64.tar.gz
sudo cp -r prometheus-2.53.1.linux-amd64/prometheus /usr/local/bin/
sudo cp -r prometheus-2.53.1.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-2.53.1.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-2.53.1.linux-amd64/console_libraries /etc/prometheus
sudo rm -rf prometheus-2.53.1.linux-amd64 prometheus-2.53.1.linux-amd64.tar.gz
```
## 5. Configure Prometheus
```bash
sudo vim /etc/prometheus/prometheus.yml
```
```yaml
global:
  scrape_interval:     10s
  evaluation_interval: 20s
rule_files:
  - 'alert.rules'
scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 3s
    static_configs:
         - targets: ['localhost:9090']

  - job_name: 'node'
    scrape_interval: 3s
    static_configs:
         - targets: ['localhost:9100']
```
## 6. Configure the alert.rules
```bash
sudo vim /etc/prometheus/alert.rules
```
```yaml
groups:
- name: example
  rules:
  - alert: service_down
    expr: up == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Instance {{ $labels.instance }} down"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes. Check the server logs for more details."

  - alert: high_load
    expr: node_load1 > 0.7
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Instance {{ $labels.instance }} under high load"
      description: "{{ $labels.instance }} of job {{ $labels.job }} is under high load. Load average is {{ $value }}."

  - alert: high_cpu_usage
    expr: 100 * (1 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) by (instance))) > 80
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Instance {{ $labels.instance }} CPU usage high"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has high CPU usage. CPU usage is above 80%."

  - alert: memory_usage
    expr: node_memory_Active_bytes / node_memory_MemTotal_bytes > 0.8
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "Instance {{ $labels.instance }} high memory usage"
      description: "{{ $labels.instance }} of job {{ $labels.job }} has high memory usage. Memory usage is above 80%."
```
## 7. Create the Prometheus Service
```bash
sudo vim /etc/systemd/system/prometheus.service
```
```yaml
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
 
[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries
 
[Install]
WantedBy=multi-user.target
```
## 8. Change the permissions
```bash
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
sudo chown -R node_exporter:node_exporter /var/lib/node_exporter
sudo chown -R prometheus:prometheus /usr/local/bin/prometheus
sudo chown -R prometheus:prometheus /usr/local/bin/promtool
```
## 9. Enable and start the Prometheus service
```bash
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
```
## 10. Verify the Prometheus service
```bash
netstat -naptu | grep 9090
sudo systemctl status prometheus
```
## 11. Install Node Exporter
```bash
curl -LO https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz
# Take the latest version from https://prometheus.io/download/
tar -xvzf node_exporter-1.8.2.linux-amd64.tar.gz
sudo cp node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/
sudo rm -rf node_exporter-1.8.2.linux-amd64 node_exporter-1.8.2.linux-amd64.tar.gz
```
## 12. Create the Node Exporter Service
```bash
sudo vim /etc/systemd/system/node_exporter.service
```
```yaml
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
 
[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter
 
[Install]
WantedBy=multi-user.target
```
## 13. Enable/start the Node Exporter service and change the permissions
```bash
sudo chown -R node_exporter:node_exporter /usr/local/bin/node_exporter
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
```
## 14. Verify the Node Exporter service
```bash
netstat -naptu | grep 9100
sudo systemctl status node_exporter
```
## 15. Access the Prometheus Dashboard
```bash
http://<IP>:9090
```
## 16. Access the Node Exporter Metrics
```bash
http://<IP>:9100/metrics
```
## 17. Installing the Alert Manager
```bash
curl -LO https://github.com/prometheus/alertmanager/releases/download/v0.27.0/alertmanager-0.27.0.freebsd-amd64.tar.gz
# Take the latest version from https://prometheus.io/download/
tar -xvzf alertmanager-0.27.0.freebsd-amd64.tar.gz
sudo cp alertmanager-0.27.0.freebsd-amd64/alertmanager /usr/local/bin/
sudo chown -R prometheus:prometheus /usr/local/bin/alertmanager
sudo mkdir /etc/alertmanager
```
## 18. Install the Grafana
```bash
sudo mkdir -p /etc/apt/keyring
sudo wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
sudo echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
sudo apt update
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```
## 19. Access the Grafana Dashboard
```bash
http://<IP>:3000
```
## Notes 19:
- Default user: admin
- Default password: admin
- Change the password after the first login
- Add the Prometheus data source
- Import the dashboard from the Grafana [website](https://grafana.com/grafana/dashboards/)
- Recomented dashboards: 1860, 405, 8919, 139, 8588, 1860, 405, 8919, 139, 8588

## 20. Changing the Grafana port
```bash
sudo vim /etc/grafana/grafana.ini
```
```ini
http_port = 3001
```
## 21. Restart the Grafana service
```bash
sudo systemctl restart grafana-server
```
## References
- [Prometheus](https://prometheus.io/)
- [Node Exporter](https://github.com/prometheus/node_exporter)
- [Alert Manager](https://github.com/prometheus/alertmanager_)
- [Grafana](https://grafana.com/)
- [LinuxTips](https://github.com/badtuxx/giropops-monitoring)

## Author
- [Matheus Marins](https://www.linkedin.com/in/matheus-marins-bernardello-89b9491ab/)
- PS: This is a simple guide to install Prometheus, Node Exporter, Alert Manager, and Grafana. It is recommended to read the official documentation for more details.
- PS2: This guide was created based on the LinuxTips tutorial.
- PS3: This guide was created for use in homelab environments, to monitor servers and services.
- Fell free to contribute to this guide and use it as you wish.
- Don't forget to star this repository if you liked it.