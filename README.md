# ParamikoJL

[![Build Status](https://github.com/IvanKuznetsoff/ParamikoJL.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/IvanKuznetsoff/ParamikoJL.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Build Status](https://app.travis-ci.com/IvanKuznetsoff/ParamikoJL.jl.svg?branch=main)](https://app.travis-ci.com/IvanKuznetsoff/ParamikoJL.jl)
[![Coverage](https://codecov.io/gh/IvanKuznetsoff/ParamikoJL.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/IvanKuznetsoff/ParamikoJL.jl)
[![Coverage](https://coveralls.io/repos/github/IvanKuznetsoff/ParamikoJL.jl/badge.svg?branch=main)](https://coveralls.io/github/IvanKuznetsoff/ParamikoJL.jl?branch=main)

This is a a wrapper package of Python Paramiko (using PyCall).
This package is intended for the file transaction via SFTP or SCP.
This package requires the following Python package installation:

- paramiko
- scp

## Examples

### Establishing SSH connections
Prior to use this package, register the ssh server to be connected.
```
# .ssh/config
Host localhost
  HostName 127.0.0.1
  User johnsmith
  Port 22
```
Ensure that you can ssh without providing password, using credential certification.
```
% ssh -T localhost true
```

