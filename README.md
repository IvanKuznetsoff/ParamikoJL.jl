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
- **SSH Jump Host**: Handle connections through an SSH proxy (jump host).
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



