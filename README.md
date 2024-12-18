# ParamikoJL

[![Build Status](https://github.com/IvanKuznetsoff/ParamikoJL.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/IvanKuznetsoff/ParamikoJL.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Build Status](https://app.travis-ci.com/IvanKuznetsoff/ParamikoJL.jl.svg?branch=main)](https://app.travis-ci.com/IvanKuznetsoff/ParamikoJL.jl)
[![Coverage](https://codecov.io/gh/IvanKuznetsoff/ParamikoJL.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/IvanKuznetsoff/ParamikoJL.jl)
[![Coverage](https://coveralls.io/repos/github/IvanKuznetsoff/ParamikoJL.jl/badge.svg?branch=main)](https://coveralls.io/github/IvanKuznetsoff/ParamikoJL.jl?branch=main)

ParamikoJL is a Julia package that wraps the Python libraries `paramiko` and `scp` to provide SSH and SCP functionalities. It enables secure file transfer and remote command execution using SSH in a Julia environment.


## Features

- **SSH Client**: Create and manage SSH connections.
- **SCP Client**: Transfer files securely using SCP.
- **SFTP Client**: Manage remote files via SFTP.
- **SSH Jump Host**: Handle connections through an SSH proxy jump.
- **Automatic Reconnection**: Reconnect automatically upon connection errors.
- **SSH Config Integration**: Load connection details from `.ssh/config`.

## Installation

To use ParamikoJL, you need PyCall package and the required Python dependencies (`paramiko` and `scp`) installed:

1. Add `PyCall` and `FilePathsBase` to your Julia environment:
   ```julia
   using Pkg
   Pkg.add("PyCall")
   Pkg.add("FilePathsBase")
2. Install the Python dependencies:
   ```sh
   pip install paramiko scp
   ```
3. Install the `ParamikoJL` package using the Julia package manager:
    ```julia
    ] add https://github.com/IvanKuznetsoff/ParamikoJL.jl
    ```
## Setting Up SSH Configuration

To ensure secure SSH connections using public key authentication, follow these steps to register your SSH host in the `.ssh/config` file:

1. Generate an SSH Key Pair (if you haven't already):

    ```bash
    ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
    ```

    Follow the prompts to save the key in the default location (`~/.ssh/id_rsa`) and set a passphrase if desired.

2. Copy the Public Key to the Remote Server:

    ```bash
    ssh-copy-id username@ssh_server_name
    ```

3. Edit the `.ssh/config` File:

    Open the `.ssh/config` file in your preferred text editor. If it doesn't exist, create it:

    ```bash
    nano ~/.ssh/config
    ```

    Add the following configuration:

    ```config
    Host ssh_server_name
        HostName your.server.address
        User your_username
        Port 22
        IdentityFile ~/.ssh/id_rsa
        PreferredAuthentications publickey
    ```

4. **Test the SSH Connection**:

    Use the following command to test your SSH connection:

    ```bash
    ssh -T ssh_server_name
    ```
    
    Replace `ssh_server_name` with a name for your server, `your.server.address` with the actual server address, and `your_username` with your SSH username.

## Usage

### Setting up an SSH Client

```julia
using ParamikoJL

# Create an SSH client using a host alias from ~/.ssh/config
ssh = SSHClient("host_alias")

# Execute remote commands
channel = ssh.exec_command("ls -l")
output = channel.read()
println(String(output))
```

### Using SFTP

```julia
sftp = SFTPClient(ssh)

# List directory contents
files = readdir(sftp, "/remote/path/")
println(files)
```

### Reconnection
ParamikoJL automatically reconnects SSH, SCP, and SFTP clients in case of connection errors. 
You can also manually trigger reconnection:

```julia
reconnect!(ssh)
```

### Closing Connections

 Close the connections when file transfer is done:
 ```julia
close!(ssh)
```

## Quick Reference

### Exported Types

- `SSHClient`: Represents an SSH connection.
- `SSHJumpClient`: Represents an SSH connection through a proxy (jump host).
- `SFTPClient`: Manages file transfers and directory operations.
- `SCPClient`: Facilitates secure file transfers using SCP.

### Exported Functions

- `readdir(sftp, dir)`: List files in a directory via SFTP.
- `download(scp, file_source, file_dest)`: Download a file via SCP.
- `upload(scp, file_source, file_dest)`: Upload a file via SCP.
- `reconnect!(client)`: Reconnects the client to the remote server.



