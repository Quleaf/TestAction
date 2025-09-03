# 🚀 Container Build and Deployment Summary

**Image:** `ex2:0.0.6`
**Build Status:** ✅ Completed
**Timestamp:** 2024-01-15 10:30:45 UTC

## 📦 Archive Storage

| Location | Address | Status |
|----------|---------|--------|
| S3 Docker Archive | `s3://pawsey0012:docker-bucket/ex2_0.0.6.tar` | ✅ Uploaded |
| S3 Singularity SIF | `s3://pawsey0012:sif-bucket/ex2_0.0.6.sif` | ✅ Uploaded |

## 🏗️ Container Registry Deployments

| Registry | Address | Status |
|----------|---------|--------|
| Setonix Private | `setonix-registry.pawsey.org.au/liu268/ex2:0.0.6` | ✅ Pushed |
| Setonix Public | `setonix-registry.pawsey.org.au/pawsey/ex2:0.0.6` | ✅ Pushed |
| Docker Hub | `docker.io/username/ex2:0.0.6` | ✅ Pushed |
| Quay.io | `quay.io/username/ex2:0.0.6` | ✅ Pushed |

## 🔧 Container Usage Commands

### Singularity Usage

Download and use the SIF file directly:
```bash
# Download SIF file from S3 (requires rclone configuration)
rclone copy pawsey0012:sif-bucket/ex2_0.0.6.sif ./

# Run with Singularity
singularity exec ex2_0.0.6.sif <command>
# or
singularity run ex2_0.0.6.sif
```

### Container Engine Pull Commands

Use the following commands to pull the container image:

### Setonix Private Registry
```bash
podman pull setonix-registry.pawsey.org.au/liu268/ex2:0.0.6
```

### Setonix Public Registry
```bash
podman pull setonix-registry.pawsey.org.au/pawsey/ex2:0.0.6
```

### Docker Hub
```bash
docker pull username/ex2:0.0.6
# or
podman pull docker.io/username/ex2:0.0.6
```

### Quay.io
```bash
podman pull quay.io/username/ex2:0.0.6
```

## 📊 Job Results

| Job | Status |
|-----|--------|
| PREPARE | ✅ Success |
| BUILD | ✅ Success |
| SCAN-AND-REPORT | ✅ Success |
| PUSH-PRIV | ✅ Success |
| PUSH-PUBLIC | ✅ Success |
