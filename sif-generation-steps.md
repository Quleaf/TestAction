# Singularity SIF Generation Process

## Step-by-Step Process

### 1. Export Container to TAR Archive
```bash
podman save --format docker-archive ex2:0.0.6 -o ex2_0.0.6.tar
```

### 2. Upload TAR to S3
```bash
rclone copy ex2_0.0.6.tar pawsey0012:docker-bucket/
```

### 3. Load Singularity Module
```bash
module load singularity/4.1.0
```

### 4. Verify Singularity Installation
```bash
singularity --version
```

### 5. Generate SIF File
```bash
singularity build ex2_0.0.6.sif docker-archive://ex2_0.0.6.tar
```

### 6. Upload SIF to S3
```bash
rclone copy ex2_0.0.6.sif pawsey0012:sif-bucket/
```

## Key Features

- **Module Loading**: Ensures Singularity 4.1.0 is properly loaded before building
- **Version Verification**: Confirms Singularity is available and working
- **Error Handling**: Fails gracefully if module loading or building fails
- **File Verification**: Checks that SIF file is created successfully
- **Dual Storage**: TAR and SIF files stored in separate S3 buckets

## Expected Output

```
Loading Singularity module and generating SIF file...
Source: docker-archive://ex2_0.0.6.tar
Output: ex2_0.0.6.sif

Loading Singularity module...
✓ Singularity module loaded successfully

singularity-ce version 4.1.0

Building SIF file from Docker archive...
INFO:    Starting build...
INFO:    Fetching OCI manifest from docker-archive://ex2_0.0.6.tar
INFO:    Extracting OCI rootfs layers
INFO:    Creating SIF file...
✓ SIF file generated successfully: ex2_0.0.6.sif (Size: 2.1G)
```
