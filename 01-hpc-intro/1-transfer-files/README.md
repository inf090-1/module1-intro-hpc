# Transfer Files To/From INFO090

This tutorial covers the most common ways to move files between your computer and the remote HPC cluster INFO090.

## 1. Prerequisites

- A INFO090 account (`yourUsername`)
- Terminal access (Linux/macOS/CMD/PowerShell/WSL/Git Bash)

## 2. Basic file transfer with `scp`

Secure Copy (`scp`) is a simple command-line tool for transferring files over SSH. It is available on Linux/macOS by default, and on Windows via CMD/PowerShell.

### 2.1 Upload one file with `scp`

First, navigate to the directory containing the file you want to upload. Then run:

```bash
scp local_file <USER>@<HOST>:~
```
Example:

```bash
# Download the file from the internet to your local machine
wget https://github.com/hpc-carpentry/amdahl/archive/refs/tags/v0.4.1.tar.gz -O amdahl.tar.gz

# Upload the file to INFO090
scp amdahl.tar.gz yourUsername@143.106.73.68:~
```
The above command uploads `amdahl.tar.gz` from your local machine to your home directory `~` on INFO090.  You can check the file is there by logging into INFO090 and running `ls`.

### 2.2 Download one file with `scp`

You can also download files from a remote machine to your local machine. To do this, you must know the full remote file path. 

---

**I don’t know the full path**

If you don’t know it, first log in to INFO090 and navigate to the directory where your file is located. Then run `pwd` (print working directory) to see the absolute path of that directory. Finally, append the `filename` to this path.

**Example:**

Suppose you log in to INFO090, go to a folder, and run:

```bash
pwd
```

which returns:

```bash
/home/yourUsername/
```
As your file is named `amdahl.tar.gz`, then the full remote path is:

```
/home/yourUsername/amdahl.tar.gz
```

---

The syntax for downloading a file is a reversal of the upload command:

```bash
scp <USER>@<HOST>:remote_file_path ./
```

**Example:**

Using the path from the previous example, to download `amdahl.tar.gz` to your current local directory `./`, run:

```bash
## Remove the file if it already exists locally to avoid confusion
rm -f amdahl.tar.gz

## Download the file from INFO090 to your local machine
scp yourUsername@143.106.73.68:/home/yourUsername/amdahl.tar.gz ./
```

A shortcut for the home directory is `~`, so you could also write:

```bash
scp yourUsername@143.106.73.68:~/amdahl.tar.gz ./
```

### 2.3 Transfer a directory

If you want to transfer an entire directory, add the `-r` (recursive) flag to the upload and download commands shown in the previous sections. This tells the command to include all files and subdirectories inside the folder.

For example, to upload a local directory named `amdahl`:

```bash
## Uncompress the amdahl file locally to get the amdahl-0.4.1 directory
tar -xzf amdahl.tar.gz 

## Upload the entire 'amdahl-0.4.1' directory to INFO090
scp -r amdahl-0.4.1 yourUsername@143.106.73.68:~/
```

To download back the `amdahl-0.4.1` directory from INFO090 to your local machine:

```bash
## Remove the local directory if it already exists to avoid confusion
rm -rf amdahl-0.4.1

## Download the entire 'amdahl-0.4.1' directory from INFO090 to your local machine
scp -r yourUsername@143.106.73.68:~/amdahl-0.4.1 ./
```
> For large directories, `rsync` is usually faster and more reliable.

## 3. File transfer with `rsync` (recommended for bigger transfers)

`rsync` is a powerful tool for synchronizing files and directories between two locations over SSH. It is more efficient than `scp` for large transfers or when transferring many files, as it only copies the differences between source and destination.

### 3.1 Upload with progress and resume support

```bash
rsync -avzP local_folder <USER>@<HOST>:~/
```
where:
- `-a` archive mode (preserves timestamps/permissions, recursive)
- `-v` verbose output
- `-z` compress file data during the transfer
- `-P` progress + keep partial files if interrupted

**Example:**

Following the previous example, we will delete the `amdahl` subdirectory within `amdahl-0.4.1` to verify how `rsync` uploads only the missing files instead of the entire directory:

```bash
## Log in to INFO090 and navigate to the 'amdahl-0.4.1' directory
ssh yourUsername@143.106.73.68
cd amdahl-0.4.1
rm -rf amdahl

## Exit INFO090
exit

## Upload the entire 'amdahl-0.4.1' directory again with rsync
rsync -avzP amdahl-0.4.1/ yourUsername@143.106.73.68:~/
```

### 3.2 Download with progress and resume support

The syntax is similar to the upload command, but with source and destination reversed:

```bash
rsync -avzP <USER>@<HOST>:remote_folder ./
```

**Example:**

Download the `amdahl-0.4.1` folder with progress and resume support:

```bash
## Remove the local directory if it already exists to avoid confusion
rm -rf amdahl-0.4.1

## Download the entire 'amdahl-0.4.1' directory from INFO090 to your local machine 
rsync -avP yourUsername@143.106.73.68:~/amdahl-0.4.1 ./
```

## 4. Further reading
- Transferring files with remote computers: https://carpentries-incubator.github.io/hpc-intro/16-transferring-files.html
- `scp` manual: https://man7.org/linux/man-pages/man1/scp.1.html
- `rsync` manual: https://man7.org/linux/man-pages/man1/rsync.1.html