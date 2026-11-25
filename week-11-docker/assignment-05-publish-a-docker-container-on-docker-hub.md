# Assignment 5 — Publish a Docker Container on Docker Hub

Part of the DevOps Micro Internship (DMI) with Agentic AI

---

## Purpose

In this assignment, you will publish a Dockerized React application to Docker Hub, then pull and run it to verify it can be downloaded and executed from another system.

---

# Task 1 — Publish a Docker Image to Docker Hub

## Goal

Create a Docker Hub repository (`my-react-app`), log in from the CLI, tag and push your local image, verify it on Docker Hub, then pull and run it to confirm the application is accessible.

### Evidence

Docker Hub repository: https://hub.docker.com/r/javesonfrancoisliuu/my-react-app

Note: the first push was arm64 only (built on an Apple Silicon Mac), so the amd64 VM could not pull it. The image was rebuilt with `docker buildx build --platform linux/amd64,linux/arm64 --push`, and the pull in Screenshot 6 ran on the amd64 VM.

#### Screenshot 1 — Docker Hub repository (`my-react-app`)

![Screenshot 1](screenshots/a5-ss1.png)

---

#### Screenshot 2 — Successful `docker login`

![Screenshot 2](screenshots/a5-ss2.png)

---

#### Screenshot 3 — Successful `docker tag`

![Screenshot 3](screenshots/a5-ss3.png)

---

#### Screenshot 4 — Successful `docker push`

![Screenshot 4](screenshots/a5-ss4.png)

---

#### Screenshot 5 — Docker Hub repository showing the uploaded image

![Screenshot 5](screenshots/a5-ss5.png)

---

#### Screenshot 6 — Successful `docker pull`

![Screenshot 6](screenshots/a5-ss6.png)

---

#### Screenshot 7 — Output of `docker ps`

![Screenshot 7](screenshots/a5-ss7.png)

---

#### Screenshot 8 — Browser displaying the running React application

![Screenshot 8](screenshots/a5-ss8.png)

---

# LinkedIn Post (Optional)

## Goal

Create a LinkedIn post covering the assignment title, the Docker Hub repository created, steps performed, key learning outcomes, and a screenshot of the published image.

## Evidence

#### LinkedIn Post URL

No separate post was published for this assignment. The Week 11 LinkedIn post covers the Docker work and is linked here:

https://www.linkedin.com/posts/javeson-francois-liu-999135437_dmibypravinmishra-devops-docker-share-7531361148256956416-zOE3/

---

#### Screenshot — Published LinkedIn post

![Published Week 11 LinkedIn post, visibility Anyone](screenshots/a6-ss5-linkedin-post.png)

---

# Submission Instructions

- Add all required screenshots in your submission
- Include the Docker Hub repository URL
- Full name must be visible in required screenshots
- Do not expose passwords or sensitive credentials

---

# Completion Checklist

- [x] Docker Hub account and repository created
- [x] Docker image tagged and pushed successfully (Screenshots 1–5)
- [x] Docker image pulled and container run successfully (Screenshots 6–7)
- [x] React application accessible in the browser (Screenshot 8)
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
