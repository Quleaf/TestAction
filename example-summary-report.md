# 🚀 Container Build and Deployment Summary

**Image:** `ex2:0.0.6`
**Build Status:** ✅ Completed
**Timestamp:** 2024-01-15 10:30:45 UTC

## 📦 Archive Storage

| Location | Address | Status |
|----------|---------|--------|
| S3 Object Storage | `s3://your-bucket/ex2_0.0.6.tar` | ✅ Uploaded |

## 🏗️ Container Registry Deployments

| Registry | Address | Status |
|----------|---------|--------|
| Setonix Private | `setonix-registry.pawsey.org.au/liu268/ex2:0.0.6` | ✅ Pushed |
| Setonix Public | `setonix-registry.pawsey.org.au/pawsey/ex2:0.0.6` | ✅ Pushed |
| Docker Hub | `docker.io/username/ex2:0.0.6` | ✅ Pushed |
| Quay.io | `quay.io/username/ex2:0.0.6` | ✅ Pushed |

## 🔧 Pull Commands

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
