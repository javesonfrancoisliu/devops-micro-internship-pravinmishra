# Assignment 4 — Docker Volumes

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Purpose

In this assignment, you will learn how Docker Volumes and Bind Mounts provide persistent storage for containers, deploying applications that retain logs and data even after containers are stopped or removed.

---

# Task 1 — Deploy a Standalone Application with Persistent Logs Using Bind Mounts

## Goal

Run an Nginx container (`myweb`) with a Bind Mount from `~/nginx-logs` to `/var/log/nginx`, verify the site loads, confirm logs are written, remove the container, and confirm the logs persist on the host.

### Evidence

#### Screenshot 1 — Output of `docker images`

![Screenshot 1](screenshots/a4-ss1.png)

---

#### Screenshot 2 — Output of `docker search nginx`

![Screenshot 2](screenshots/a4-ss2.png)

---

#### Screenshot 3 — Successful `docker pull nginx` (if applicable)

![Screenshot 3](screenshots/a4-ss3.png)

---

#### Screenshot 4 — Creation of the `~/nginx-logs` directory

![Screenshot 4](screenshots/a4-ss4.png)

---

#### Screenshot 5 — Output of `docker run` with the Bind Mount

![Screenshot 5](screenshots/a4-ss5.png)

---

#### Screenshot 6 — Output of `docker ps` showing the running `myweb` container

![Screenshot 6](screenshots/a4-ss6.png)

---

#### Screenshot 7 — Browser displaying the Nginx Welcome Page

![Screenshot 7](screenshots/a4-ss7.png)

---

#### Screenshot 8 — Output of `ls ~/nginx-logs` showing `access.log` and `error.log`

![Screenshot 8](screenshots/a4-ss8.png)

---

#### Screenshot 9 — Successful removal of the container

![Screenshot 9](screenshots/a4-ss9.png)

---

#### Screenshot 10 — Output of `ls ~/nginx-logs` confirming the log files remain after the container has been removed

![Screenshot 10](screenshots/a4-ss10.png)

---

# Task 2 — Deploy Two Containers with Persistent Data Using Docker Volumes

## Goal

Create a custom network `mynetwork` and a Docker volume `shared-data`, build and run a `backend` container that writes to the shared volume and a `frontend` container that reads from it, and confirm updates are reflected immediately.

### Evidence

#### Screenshot 1 — Project folder structure

![Screenshot 11](screenshots/a4-ss11.png)

---

#### Screenshot 2 — Output of `docker network create mynetwork`

![Screenshot 12](screenshots/a4-ss12.png)

---

#### Screenshot 3 — Output of `docker volume create shared-data`

![Screenshot 13](screenshots/a4-ss13.png)

---

#### Screenshot 4 — Backend Dockerfile

![Screenshot 14](screenshots/a4-ss14.png)

---

#### Screenshot 5 — Successful backend image build

![Screenshot 15](screenshots/a4-ss15.png)

---

#### Screenshot 6 — Frontend Dockerfile

![Screenshot 16](screenshots/a4-ss16.png)

---

#### Screenshot 7 — Successful frontend image build

![Screenshot 17](screenshots/a4-ss17.png)

---

#### Screenshot 8 — Output of `docker ps` showing both containers

![Screenshot 18](screenshots/a4-ss18.png)

---

#### Screenshot 9 — Successful execution of `docker exec backend curl http://localhost/write`

![Screenshot 19](screenshots/a4-ss19.png)

---

#### Screenshot 10 — Browser displaying "Hello from Backend!"

![Screenshot 20](screenshots/a4-ss20.png)

---

#### Screenshot 11 — Browser displaying "Test Data 1" after the first update

![Screenshot 21](screenshots/a4-ss21.png)

---

#### Screenshot 12 — Browser displaying "Test Data 2 - New Update" after the second update

![Screenshot 22](screenshots/a4-ss22.png)

---

# LinkedIn Post (Optional)

## Goal

Create a LinkedIn post covering the assignment, Docker Hub repository, steps performed, and key learning outcomes.

## Evidence

#### LinkedIn Post URL

Paste your LinkedIn post URL here:

`Add your URL here`

---

#### Screenshot — Published LinkedIn post

Add your screenshot here.

---

# Submission Instructions

- Add all required screenshots in your submission
- Full name must be visible in required screenshots
- Do not expose sensitive information

---

# Completion Checklist

- [x] Task 1: Bind-mounted persistent logs verified before and after container removal (Screenshots 1–10)
- [x] Task 2: Docker volume shared between frontend and backend verified (Screenshots 1–12)
- [x] No sensitive information exposed

---

## 📌 About DMI & CloudAdvisory

DevOps Micro Internship (DMI) is a project-based DevOps program run by Pravin Mishra (The CloudAdvisory) focused on real-world execution, systems thinking, and career readiness.

It helps learners build strong DevOps foundations with hands-on experience.

---

## 📌 Resources

- 🌐 DMI Official Website: https://dmi.pravinmishra.com?utm_source=github&utm_medium=readme  
- 🎓 University: https://university.pravinmishra.com?utm_source=github&utm_medium=readme  
- 💬 Discord Community: https://discord.pravinmishra.com?utm_source=github&utm_medium=readme  
- 📝 Blog: https://dmi.pravinmishra.com/blog?utm_source=github&utm_medium=readme  
- ▶️ YouTube Playlist: https://www.youtube.com/playlist?list=PLFeSNDtI4Cho  
- 🔗 Pravin Mishra (LinkedIn): https://www.linkedin.com/in/pravin-mishra-aws-trainer/  
- 🏢 CloudAdvisory (LinkedIn): https://www.linkedin.com/company/thecloudadvisory/

---

*This submission is part of DevOps Micro Internship (DMI) — Agentic AI Track.*
