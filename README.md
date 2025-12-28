# Docker Setup

Follow the steps below to make the installation script executable and run the setup in a safe, professional way.

## 1) Make the script executable

This grants execute permissions so the script can run like a program:

```bash
chmod +x setup-docker.sh
```

## 2) Run the installation with administrator privileges

Docker installation requires root access to install packages and update system components, so run the script with `sudo`:

```bash
sudo ./setup-docker.sh
```

---

### Pro tips for a clean run

- **Review before running:** Read through `setup-docker.sh` first, especially in production environments.
- **Use an up-to-date system:** Ensures the best compatibility and fewer surprises.
- **Log the output:** If you want to keep the output for troubleshooting, run:

```bash
sudo ./setup-docker.sh | tee setup-docker.log
```
