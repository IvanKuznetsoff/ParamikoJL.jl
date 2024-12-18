module ParamikoJL
using PyCall
using FilePathsBase  # For path manipulations
using Printf
using Dates

# Import Python libraries
@pyimport paramiko
@pyimport scp
@pyimport os as pyos
@pyimport builtins

abstract type AbstractSSHClient end
mutable struct SSHClient <: AbstractSSHClient
    pyobj           :: PyObject
    name
    config          :: Dict
end
mutable struct SSHJumpClient <: AbstractSSHClient
    pyobj           :: PyObject
    name
    config          :: Dict
    proxy           :: SSHClient
end
mutable struct SFTPClient <: AbstractSSHClient
    pyobj :: PyObject
    ssh   :: AbstractSSHClient
end
mutable struct SCPClient <: AbstractSSHClient
    pyobj :: PyObject
    ssh   :: AbstractSSHClient
end
function Base.getproperty(h::AbstractSSHClient, s::Symbol) #構造体を引数に保つ関数！
    if s == :pyobj || s == :config || s == :name
        getfield(h, s)
    else
        getproperty(getfield(h, :pyobj), s)
    end
end
function Base.getproperty(h::SSHJumpClient, s::Symbol) #構造体を引数に保つ関数！
    if s == :pyobj || s == :config || s == :name || s == :proxy
        getfield(h, s)
    else
        getproperty(getfield(h, :pyobj), s)
    end
end
function Base.getproperty(h::SFTPClient, s::Symbol) #構造体を引数に保つ関数！
    if s == :pyobj || s == :config || s == :name || s == :ssh
        getfield(h, s)
    else
        getproperty(getfield(h, :pyobj), s)
    end
end
function Base.getproperty(h::SCPClient, s::Symbol) #構造体を引数に保つ関数！
    if s == :pyobj || s == :config || s == :name || s == :ssh
        getfield(h, s)
    else
        getproperty(getfield(h, :pyobj), s)
    end
end
function SSHClient(alias :: String)
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    config = load_ssh_config(alias)
    key = paramiko.RSAKey.from_private_key_file(
    config["identityfile"])
    ssh.connect(
        config["hostname"],
        port        = config["port"],
        username    = config["username"],
        pkey        = key
    )
    return SSHClient(ssh, alias, config)
end
function SSHJumpClient(proxy :: SSHClient, alias :: String)
    config = load_ssh_config(alias)
    key = paramiko.RSAKey.from_private_key_file(
    config["identityfile"])
    sock = proxy.get_transport().open_channel(
        "direct-tcpip", 
        (config["hostname"], config["port"]), 
        ("", proxy.config["port"])
    )
    ssh = paramiko.Transport(sock)
    ssh.connect(
        username    = config["username"],
        pkey        = key
    )
    return SSHJumpClient(ssh, alias, config, proxy)
end
function reconnect!(ssh :: SSHClient)
    pyssh = paramiko.SSHClient()
    pyssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    config = ssh.config
    key = paramiko.RSAKey.from_private_key_file(
    config["identityfile"])
    pyssh.connect(
        config["hostname"],
        port        = config["port"],
        username    = config["username"],
        pkey        = key
    )
    ssh.pyobj = pyssh
    nothing
end
function reconnect!(ssh :: SSHJumpClient)
    name = ssh.name
    proxy = ssh.proxy
    reconnect!(proxy)
    config = ssh.config
    key = paramiko.RSAKey.from_private_key_file(
    config["identityfile"])
    sock = proxy.get_transport().open_channel(
        "direct-tcpip", 
        (config["hostname"], config["port"]), 
        ("", proxy.config["port"])
    )
    pyssh = paramiko.Transport(sock)
    pyssh.connect(
        username    = config["username"],
        pkey        = key
    )
    ssh.pyobj = pyssh
    nothing
end

function reconnect!(sftp :: SFTPClient)
    reconnect!(sftp.ssh)
    pysftp = paramiko.SFTPClient.from_transport(sftp.ssh.pyobj)
    sftp.pyobj = pysftp
end
function reconnect!(scp :: SCPClient)
    reconnect!(scp.ssh)
    pysftp = paramiko.SFTPClient.from_transport(scp.ssh.pyobj)
    scp.pyobj = pysftp
end

function finalize(ssh :: AbstractSSHClient)
    ssh.close()
    nothing
end
function close!(ssh :: AbstractSSHClient)
    ssh.close()
    nothing
end
# Function to load SSH configuration for a given host alias
function load_ssh_config(
    alias               ::String, 
    ssh_config_path     ::String = "~/.ssh/config",
    ssh_identity_path   ::String = "~/.ssh/id_rsa"
    )
    ssh_config = paramiko.SSHConfig()
    expanded_path = expanduser(ssh_config_path)
    
    if !isfile(expanded_path)
        error("SSH config file not found at $(expanded_path)")
    end
    
    f = builtins.open(expanded_path)
    ssh_config.parse(f)
    f.__exit__()
    
    host_config = ssh_config.lookup(alias)
    
    if isempty(host_config)
        error("No configuration found for alias '$(alias)'")
    end
    
    # Extract connection parameters with defaults
    hostname = get(host_config, "hostname", nothing)
    if hostname === nothing
        error("Hostname not specified for alias '$(alias)' in SSH config.")
    end
    
    port = get(host_config, "port", "22")
    port = parse(Int, port)
    
    username = get(host_config, "user", nothing)
    if username === nothing
        error("Username not specified for alias '$(alias)' in SSH config.")
    end
    
    identityfile = get(host_config, "identityfile", nothing)
    # identityfile can be a list
    if identityfile !== nothing
        # Paramiko expects a single path; take the first one if multiple
        identityfile = identityfile[1]
        identityfile = expanduser(identityfile)
    else
        identityfile = expanduser(ssh_identity_path)
    end
    proxycommand = get(host_config, "proxycommand", nothing)
    # Password is typically not stored in SSH config; set to None
    password = nothing
    
    return Dict(
        "hostname" => hostname,
        "port" => port,
        "username" => username,
        "identityfile" => identityfile,
        "password" => password,
        "proxycommand" => proxycommand
    )
end
function SFTPClient(ssh :: SSHClient)
    sftp = ssh.open_sftp()
    return SFTPClient(sftp, ssh)
end
function SFTPClient(ssh :: SSHJumpClient)
    sftp = paramiko.SFTPClient.from_transport(ssh.pyobj)
    return SFTPClient(sftp, ssh)
end
function SCPClient(ssh :: SSHJumpClient)
    scpc = scp.SCPClient(ssh.pyobj)
    return SCPClient(scpc, ssh)
end
import Base.readdir
function readdir(
        sftp    :: SFTPClient,
        dir     :: String)
    fn_list = nothing
    try
        fn_list = sftp.listdir(dir)
    catch
        reconnect!(sftp)
        @info("SSH reconnected!")
        fn_list = sftp.listdir(dir)
    end
    return fn_list
end
import Base.download
function download(
    scp             :: SCPClient,
    file_source     :: String,
    file_dest       :: String)
    try 
        scp.get(file_source, file_dest)
    catch
        reconnect!(scp)
        @info("SSH reconnected!")
        scp.get(file_source, file_dest)
    end
    return
end
function upload(
    scp             :: SCPClient,
    file_source     :: String,
    file_dest       :: String)
    try
        scp.put(file_source, file_dest) 
    catch
        reconnect!(scp)
        @info("SSH reconnected!")
        scp.put(file_source, file_dest) 
    end
    return
end 
export SSHClient, SCPClient, SSHJumpClient, SFTPClient, readdir, reconnect!, download, upload
end
