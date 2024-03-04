# KRC Implementation

## Step 1: Certification

To tackle this challenge effectively, challenger needs to have a solid understanding of Kubernetes concepts and
practical experience - equivalent to passed a Certified Kubernetes Application Developer (CKAD).

Before this challenge,

- I've used K8s at work to develope Go web application & deploy containerized app to AWS EKS.
- I've read (& followed) 2 famous books about Kubernetes
  - Kubernetes: Up and Running: Dive into the Future of Infrastructure (3rd Edition)
  - Kubernetes in Action, Second Edition

But it's almost one year ago, so I'll

- follow KodeKloud Kubernetes Crash Course to regain my knowledge about K8s for this challenge
- take the CKDA certification later (in this year)

## Step 2: Containerize Your E-Commerce Website and Database

### A. Web Application Containerization

1. **Create a Dockerfile**: Navigate to the root of the e-commerce application and create a Dockerfile. This file should
   instruct Docker to:

    - Use `php:7.4-apache` as the base image.
    - Install `mysqli` extension for PHP.
    - Copy the application source code to `/var/www/html/`.
    - Update database connection strings to point to a Kubernetes service named `mysql-service`.
    - Expose port `80` to allow traffic to the web server.

2. **Build and Push the Docker Image**:

    - Execute `docker build -t yourdockerhubusername/ecom-web:v1 .` to build your image.
    - Push it to Docker Hub with `docker push yourdockerhubusername/ecom-web:v1`.
    - **Outcome**: Your web application Docker image is now available on Docker Hub.

### B. Database Containerization

- **Database Preparation**: Instead of containerizing the database yourself, you'll use the official MariaDB image.
  Prepare the database initialization script (`db-load-script.sql`) to be used with Kubernetes ConfigMaps or as an
  entrypoint script.

## Step 3: Set Up Kubernetes on a Public Cloud Provider

## Step 4: Deploy Your Website to Kubernetes

## Step 5: Expose Your Website

## Step 6: Implement Configuration Management

## Step 7: Scale Your Application

## Step 8: Perform a Rolling Update

## Step 9: Roll Back a Deployment

## Step 10: Auto-scale Your Application

## Step 11: Implement Liveness and Readiness Probes

## Step 12: Utilize ConfigMaps and Secrets

## Step 13: Document Your Process
