# Blue-Green Deployment with Docker & Nginx

This project demonstrates a **Blue-Green Deployment** setup using **Docker Compose**, **Nginx**, and two Node.js applications (`blue` and `green`).

---

## Features
- Zero-downtime deployment strategy (Blue/Green)
- Load balancing via Nginx
- Containerized using Docker Compose
- Easily switch traffic between environments

---

## Project Structure
├── Dockerfile
├── docker-compose.yaml
├── nginx
│ ├── nginx.conf.template
│ └── start.sh
└── verify_failover.sh
---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

2. Build and Push Docker Images
docker build -t your-username/node-test-image-blue:latest .
docker build -t your-username/node-test-image-green:latest .
docker push your-username/node-test-image-blue:latest
docker push your-username/node-test-image-green:latest

3. Start the Services
docker compose up -d

4. Check Running Containers
docker ps

Access the App

Open your browser and visit:

http://localhost

Cleanup

To stop and remove containers:

docker compose down
