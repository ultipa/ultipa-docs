# Install Ultipa Manager

You can install **Ultipa Manager** on Linux machines. This guide outlines the steps to deploy Ultipa Manager.

## System Requirements

The following hardware and software requirements must be met for deploying Ultipa Manager:

#### Operating System

- CentOS 9+, Ubuntu 18.04+, or other compatible Linux distributions.

#### Hardware Requirements

- **CPU**: x86\_64 or ARM64 (aarch64) architecture; minimum 4-core processor.
- **Memory**: At least 2 GB RAM (8 GB or more recommended).
- **Disk**: SSD recommended; minimum 5 GB of available disk space.

#### Network Configuration

- Static IP address required.
- **External service ports**: `3050`

#### Prerequisite Software

- Docker Engine (latest stable version recommended)
- Shell (e.g., Bash)
- Firewall

#### Additional Requirements

* Firewall rules must allow traffic on all required ports.
* Deployment must be performed by the **root user** or a user with **sudo privileges**.

## Deployment Procedure

Ultipa Manager can be deployed on a dedicated server (recommended for production) or an existing Name Server.

### 1. Pull or Load the Docker Image

To retrieve the Ultipa Manager image from the registry, run:

```bash
docker pull <docker_image_identifier>
```

If access to the registry is unavailable, you can load the image from a local TAR file:

```bash
docker load -i <image_tar_file_path>
```

### 2. Start the Docker Container

Use the following command to run the Ultipa Manager container:

```bash
docker run -itd -p <local_host_port>:3002 \
  -v /absolute/path/to/data:/var/ultipa-manager/data \
  -v /absolute/path/to/logs:/var/ultipa-manager/logs \
  -e TZ=UTC \
  -e MANAGER_ROOT_PASSWORD="<root_password>" \
  --name ultipa-manager <image_ID> start
```

- Replace `<local_host_port>` with the local host port used to access the Ultipa Manager web UI.
- `3002` is the container's internal port that runs the web service.
- The `-v` options mount host directories into the container for persistent storage of data and logs. These are optional and can be omitted if persistence or custom storage paths are not needed.
- The `-e TZ` option sets the container's time zone.
- The `-e MANAGER_ROOT_PASSWORD` option sets the login password for the `root` user. Replace `<root_password>` with your password.
- Replace `<image_ID>` with the actual Docker image ID or tag of the Ultipa Manager image.

### 3. Verify Installation

Ultipa Manager is well installed if you could successfully access service in browser through `http://<host_ip>:<local_host_port>`.
