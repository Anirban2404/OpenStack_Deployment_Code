#!/bin/bash
##################################################
#                                                #
# Purpose: Setup the  live migration in          #
#          Controller node.                      #
# Author: Anirban Bhattacharjee                  #
# Date: 28-APR-2016                              #
#                                                #
##################################################
#                                                #
# Should run on CONTROLLER NODE                  #
#                                                #
##################################################

## get UID
uid=$(id -u)

# Make sure only root can run our script
if [ $uid -ne 0 ]; then
   echo "$USER, you need to have root access."
   exit 1
fi

# Install the required packages for NFS server
apt-get install nfs-kernel-server -y

# Get the name of nic card of public network
pub_nic=$(cat ~/.nic_interfaces |awk '/public_interface/ {print $3}')
# Get the name of ip of public network
controller_node_ip=$(ip addr show $pub_nic | awk '/inet / {print $2}'|sed 's/\/.*//')

# Add this line to ports
cat >>  /etc/exports  <<EOF
/var/lib/nova/instances $controller_node_ip/255.255.255.128(rw,sync,fsid=0,no_root_squash)
EOF

# Install libvirt bin 
apt-get install qemu-kvm libvirt-bin -y

# Edit /etc/default/libvirt-bin file
cat >  /etc/default/libvirt-bin  <<EOF
# Defaults for libvirt-bin initscript (/etc/init.d/libvirt-bin)
# This is a POSIX shell fragment

# Start libvirtd to handle qemu/kvm:
start_libvirtd="yes"

# options passed to libvirtd, add "-l" to listen on tcp
libvirtd_opts="-d -l"

# pass in location of kerberos keytab
#export KRB5_KTNAME=/etc/libvirt/libvirt.keytab
EOF

# Edit /etc/libvirt/libvirtd.conf file
cat > /etc/libvirt/libvirtd.conf <<EOF
# Master libvirt daemon configuration file
#
# For further information consult http://libvirt.org/format.html
#
# NOTE: the tests/daemon-conf regression test script requires
# that each "PARAMETER = VALUE" line in this file have the parameter
# name just after a leading "#".

#################################################################
#
# Network connectivity controls
#

# Flag listening for secure TLS connections on the public TCP/IP port.
# NB, must pass the --listen flag to the libvirtd process for this to
# have any effect.
#
# It is necessary to setup a CA and issue server certificates before
# using this capability.
#
# This is enabled by default, uncomment this to disable it
listen_tls = 0

# Listen for unencrypted TCP connections on the public TCP/IP port.
# NB, must pass the --listen flag to the libvirtd process for this to
# have any effect.
#
# Using the TCP socket requires SASL authentication by default. Only
# SASL mechanisms which support data encryption are allowed. This is
# DIGEST_MD5 and GSSAPI (Kerberos5)
#
# This is disabled by default, uncomment this to enable it.
listen_tcp = 1



# Override the port for accepting secure TLS connections
# This can be a port number, or service name
#
#tls_port = "16514"

# Override the port for accepting insecure TCP connections
# This can be a port number, or service name
#
tcp_port = "16509"


# Override the default configuration which binds to all network
# interfaces. This can be a numeric IPv4/6 address, or hostname
#
# If the libvirtd service is started in parallel with network
# startup (e.g. with systemd), binding to addresses other than
# the wildcards (0.0.0.0/::) might not be available yet.
#
#listen_addr = "0.0.0.0/::"


# Flag toggling mDNS advertizement of the libvirt service.
#
# Alternatively can disable for all services on a host by
# stopping the Avahi daemon
#
# This is disabled by default, uncomment this to enable it
#mdns_adv = 1

# Override the default mDNS advertizement name. This must be
# unique on the immediate broadcast network.
#
# The default is "Virtualization Host HOSTNAME", where HOSTNAME
# is substituted for the short hostname of the machine (without domain)
#
#mdns_name = "Virtualization Host Joe Demo"


#################################################################
#
# UNIX socket access controls
#

# Beware that if you are changing *any* of these options, and you use
# socket activation with systemd, you need to adjust the settings in
# the libvirtd.socket file as well since it could impose a security
# risk if you rely on file permission checking only.

# Set the UNIX domain socket group ownership. This can be used to
# allow a 'trusted' set of users access to management capabilities
# without becoming root.
#
# This is restricted to 'root' by default.
unix_sock_group = "libvirtd"

# Set the UNIX socket permissions for the R/O socket. This is used
# for monitoring VM status only
#
# Default allows any user. If setting group ownership, you may want to
# restrict this too.
unix_sock_ro_perms = "0777"

# Set the UNIX socket permissions for the R/W socket. This is used
# for full management of VMs
#
# Default allows only root. If PolicyKit is enabled on the socket,
# the default will change to allow everyone (eg, 0777)
#
# If not using PolicyKit and setting group ownership for access
# control, then you may want to relax this too.
unix_sock_rw_perms = "0770"

# Set the name of the directory in which sockets will be found/created.
#unix_sock_dir = "/var/run/libvirt"

#################################################################
#
# Authentication.
#
#  - none: do not perform auth checks. If you can connect to the
#          socket you are allowed. This is suitable if there are
#          restrictions on connecting to the socket (eg, UNIX
#          socket permissions), or if there is a lower layer in
#          the network providing auth (eg, TLS/x509 certificates)
#
#  - sasl: use SASL infrastructure. The actual auth scheme is then
#          controlled from /etc/sasl2/libvirt.conf. For the TCP
#          socket only GSSAPI & DIGEST-MD5 mechanisms will be used.
#          For non-TCP or TLS sockets, any scheme is allowed.
#
#  - polkit: use PolicyKit to authenticate. This is only suitable
#            for use on the UNIX sockets. The default policy will
#            require a user to supply their own password to gain
#            full read/write access (aka sudo like), while anyone
#            is allowed read/only access.
#
# Set an authentication scheme for UNIX read-only sockets
# By default socket permissions allow anyone to connect
#
# To restrict monitoring of domains you may wish to enable
# an authentication mechanism here
auth_unix_ro = "none"

# Set an authentication scheme for UNIX read-write sockets
# By default socket permissions only allow root. If PolicyKit
# support was compiled into libvirt, the default will be to
# use 'polkit' auth.
#
# If the unix_sock_rw_perms are changed you may wish to enable
# an authentication mechanism here
auth_unix_rw = "none"

# Change the authentication scheme for TCP sockets.
#
# If you don't enable SASL, then all TCP traffic is cleartext.
# Don't do this outside of a dev/test scenario. For real world
# use, always enable SASL and use the GSSAPI or DIGEST-MD5
# mechanism in /etc/sasl2/libvirt.conf
#auth_tcp = "sasl"
auth_tcp = "none"

# Change the authentication scheme for TLS sockets.
#
# TLS sockets already have encryption provided by the TLS
# layer, and limited authentication is done by certificates
#
# It is possible to make use of any SASL authentication
# mechanism as well, by using 'sasl' for this option
#auth_tls = "none"


# Change the API access control scheme
#
# By default an authenticated user is allowed access
# to all APIs. Access drivers can place restrictions
# on this. By default the 'nop' driver is enabled,
# meaning no access control checks are done once a
# client has authenticated with libvirtd
#
#access_drivers = [ "polkit" ]

#################################################################
#
# TLS x509 certificate configuration
#


# Override the default server key file path
#
#key_file = "/etc/pki/libvirt/private/serverkey.pem"

# Override the default server certificate file path
#
#cert_file = "/etc/pki/libvirt/servercert.pem"

# Override the default CA certificate path
#
#ca_file = "/etc/pki/CA/cacert.pem"

# Specify a certificate revocation list.
#
# Defaults to not using a CRL, uncomment to enable it
#crl_file = "/etc/pki/CA/crl.pem"



#################################################################
#
# Authorization controls
#


# Flag to disable verification of our own server certificates
#
# When libvirtd starts it performs some sanity checks against
# its own certificates.
#
# Default is to always run sanity checks. Uncommenting this
# will disable sanity checks which is not a good idea
#tls_no_sanity_certificate = 1

# Flag to disable verification of client certificates
#
# Client certificate verification is the primary authentication mechanism.
# Any client which does not present a certificate signed by the CA
# will be rejected.
#
# Default is to always verify. Uncommenting this will disable
# verification - make sure an IP whitelist is set
#tls_no_verify_certificate = 1


# A whitelist of allowed x509 Distinguished Names
# This list may contain wildcards such as
#
#    "C=GB,ST=London,L=London,O=Red Hat,CN=*"
#
# See the POSIX fnmatch function for the format of the wildcards.
#
# NB If this is an empty list, no client can connect, so comment out
# entirely rather than using empty list to disable these checks
#
# By default, no DN's are checked
#tls_allowed_dn_list = ["DN1", "DN2"]


# A whitelist of allowed SASL usernames. The format for usernames
# depends on the SASL authentication mechanism. Kerberos usernames
# look like username@REALM
#
# This list may contain wildcards such as
#
#    "*@EXAMPLE.COM"
#
# See the POSIX fnmatch function for the format of the wildcards.
#
# NB If this is an empty list, no client can connect, so comment out
# entirely rather than using empty list to disable these checks
#
# By default, no Username's are checked
#sasl_allowed_username_list = ["joe@EXAMPLE.COM", "fred@EXAMPLE.COM" ]



#################################################################
#
# Processing controls
#

# The maximum number of concurrent client connections to allow
# over all sockets combined.
#max_clients = 5000

# The maximum length of queue of connections waiting to be
# accepted by the daemon. Note, that some protocols supporting
# retransmission may obey this so that a later reattempt at
# connection succeeds.
#max_queued_clients = 1000

# The maximum length of queue of accepted but not yet
# authenticated clients. The default value is zero, meaning
# the feature is disabled.
#max_anonymous_clients = 20

# The minimum limit sets the number of workers to start up
# initially. If the number of active clients exceeds this,
# then more threads are spawned, up to max_workers limit.
# Typically you'd want max_workers to equal maximum number
# of clients allowed
#min_workers = 5
#max_workers = 20


# The number of priority workers. If all workers from above
# pool are stuck, some calls marked as high priority
# (notably domainDestroy) can be executed in this pool.
#prio_workers = 5

# Total global limit on concurrent RPC calls. Should be
# at least as large as max_workers. Beyond this, RPC requests
# will be read into memory and queued. This directly impacts
# memory usage, currently each request requires 256 KB of
# memory. So by default up to 5 MB of memory is used
#
# XXX this isn't actually enforced yet, only the per-client
# limit is used so far
#max_requests = 20

# Limit on concurrent requests from a single client
# connection. To avoid one client monopolizing the server
# this should be a small fraction of the global max_requests
# and max_workers parameter
#max_client_requests = 5

#################################################################
#
# Logging controls
#

# Logging level: 4 errors, 3 warnings, 2 information, 1 debug
# basically 1 will log everything possible
# Note: Journald may employ rate limiting of the messages logged
# and thus lock up the libvirt daemon. To use the debug level with
# journald you have to specify it explicitly in 'log_outputs', otherwise
# only information level messages will be logged.
#log_level = 3

# Logging filters:
# A filter allows to select a different logging level for a given category
# of logs
# The format for a filter is one of:
#    x:name
#    x:+name
#      where name is a string which is matched against source file name,
#      e.g., "remote", "qemu", or "util/json", the optional "+" prefix
#      tells libvirt to log stack trace for each message matching name,
#      and x is the minimal level where matching messages should be logged:
#    1: DEBUG
#    2: INFO
#    3: WARNING
#    4: ERROR
#
# Multiple filters can be defined in a single @filters, they just need to be
# separated by spaces.
#
# e.g. to only get warning or errors from the remote layer and only errors
# from the event layer:
#log_filters="3:remote 4:event"

# Logging outputs:
# An output is one of the places to save logging information
# The format for an output can be:
#    x:stderr
#      output goes to stderr
#    x:syslog:name
#      use syslog for the output and use the given name as the ident
#    x:file:file_path
#      output to a file, with the given filepath
#    x:journald
#      output to journald logging system
# In all case the x prefix is the minimal level, acting as a filter
#    1: DEBUG
#    2: INFO
#    3: WARNING
#    4: ERROR
#
# Multiple outputs can be defined, they just need to be separated by spaces.
# e.g. to log all warnings and errors to syslog under the libvirtd ident:
#log_outputs="3:syslog:libvirtd"
#

# Log debug buffer size:
#
# This configuration option is no longer used, since the global
# log buffer functionality has been removed. Please configure
# suitable log_outputs/log_filters settings to obtain logs.
#log_buffer_size = 64


##################################################################
#
# Auditing
#
# This setting allows usage of the auditing subsystem to be altered:
#
#   audit_level == 0  -> disable all auditing
#   audit_level == 1  -> enable auditing, only if enabled on host (default)
#   audit_level == 2  -> enable auditing, and exit if disabled on host
#
#audit_level = 2
#
# If set to 1, then audit messages will also be sent
# via libvirt logging infrastructure. Defaults to 0
#
#audit_logging = 1

###################################################################
# UUID of the host:
# Provide the UUID of the host here in case the command
# 'dmidecode -s system-uuid' does not provide a valid uuid. In case
# 'dmidecode' does not provide a valid UUID and none is provided here, a
# temporary UUID will be generated.
# Keep the format of the example UUID below. UUID must not have all digits
# be the same.

# NB This default all-zeros UUID will not work. Replace
# it with the output of the 'uuidgen' command and then
# uncomment this entry
#host_uuid = "00000000-0000-0000-0000-000000000000"

###################################################################
# Keepalive protocol:
# This allows libvirtd to detect broken client connections or even
# dead clients.  A keepalive message is sent to a client after
# keepalive_interval seconds of inactivity to check if the client is
# still responding; keepalive_count is a maximum number of keepalive
# messages that are allowed to be sent to the client without getting
# any response before the connection is considered broken.  In other
# words, the connection is automatically closed approximately after
# keepalive_interval * (keepalive_count + 1) seconds since the last
# message received from the client.  If keepalive_interval is set to
# -1, libvirtd will never send keepalive requests; however clients
# can still send them and the daemon will send responses.  When
# keepalive_count is set to 0, connections will be automatically
# closed after keepalive_interval seconds of inactivity without
# sending any keepalive messages.
#
#keepalive_interval = 5
#keepalive_count = 5
#
# If set to 1, libvirtd will refuse to talk to clients that do not
# support keepalive protocol.  Defaults to 0.
#
#keepalive_required = 1
EOF

# Edit /etc/libvirt/qemu.conf file
cat > /etc/libvirt/qemu.conf <<EOF
# Master configuration file for the QEMU driver.
# All settings described here are optional - if omitted, sensible
# defaults are used.

# VNC is configured to listen on 127.0.0.1 by default.
# To make it listen on all public interfaces, uncomment
# this next option.
#
# NB, strong recommendation to enable TLS + x509 certificate
# verification when allowing public access
#
#vnc_listen = "0.0.0.0"

# Enable this option to have VNC served over an automatically created
# unix socket. This prevents unprivileged access from users on the
# host machine, though most VNC clients do not support it.
#
# This will only be enabled for VNC configurations that do not have
# a hardcoded 'listen' or 'socket' value. This setting takes preference
# over vnc_listen.
#
#vnc_auto_unix_socket = 1

# Enable use of TLS encryption on the VNC server. This requires
# a VNC client which supports the VeNCrypt protocol extension.
# Examples include vinagre, virt-viewer, virt-manager and vencrypt
# itself. UltraVNC, RealVNC, TightVNC do not support this
#
# It is necessary to setup CA and issue a server certificate
# before enabling this.
#
#vnc_tls = 1


# Use of TLS requires that x509 certificates be issued. The
# default it to keep them in /etc/pki/libvirt-vnc. This directory
# must contain
#
#  ca-cert.pem - the CA master certificate
#  server-cert.pem - the server certificate signed with ca-cert.pem
#  server-key.pem  - the server private key
#
# This option allows the certificate directory to be changed
#
#vnc_tls_x509_cert_dir = "/etc/pki/libvirt-vnc"


# The default TLS configuration only uses certificates for the server
# allowing the client to verify the server's identity and establish
# an encrypted channel.
#
# It is possible to use x509 certificates for authentication too, by
# issuing a x509 certificate to every client who needs to connect.
#
# Enabling this option will reject any client who does not have a
# certificate signed by the CA in /etc/pki/libvirt-vnc/ca-cert.pem
#
#vnc_tls_x509_verify = 1


# The default VNC password. Only 8 bytes are significant for
# VNC passwords. This parameter is only used if the per-domain
# XML config does not already provide a password. To allow
# access without passwords, leave this commented out. An empty
# string will still enable passwords, but be rejected by QEMU,
# effectively preventing any use of VNC. Obviously change this
# example here before you set this.
#
#vnc_password = "XYZ12345"


# Enable use of SASL encryption on the VNC server. This requires
# a VNC client which supports the SASL protocol extension.
# Examples include vinagre, virt-viewer and virt-manager
# itself. UltraVNC, RealVNC, TightVNC do not support this
#
# It is necessary to configure /etc/sasl2/qemu.conf to choose
# the desired SASL plugin (eg, GSSPI for Kerberos)
#
#vnc_sasl = 1


# The default SASL configuration file is located in /etc/sasl2/
# When running libvirtd unprivileged, it may be desirable to
# override the configs in this location. Set this parameter to
# point to the directory, and create a qemu.conf in that location
#
#vnc_sasl_dir = "/some/directory/sasl2"


# QEMU implements an extension for providing audio over a VNC connection,
# though if your VNC client does not support it, your only chance for getting
# sound output is through regular audio backends. By default, libvirt will
# disable all QEMU sound backends if using VNC, since they can cause
# permissions issues. Enabling this option will make libvirtd honor the
# QEMU_AUDIO_DRV environment variable when using VNC.
#
#vnc_allow_host_audio = 0



# SPICE is configured to listen on 127.0.0.1 by default.
# To make it listen on all public interfaces, uncomment
# this next option.
#
# NB, strong recommendation to enable TLS + x509 certificate
# verification when allowing public access
#
#spice_listen = "0.0.0.0"


# Enable use of TLS encryption on the SPICE server.
#
# It is necessary to setup CA and issue a server certificate
# before enabling this.
#
#spice_tls = 1


# Use of TLS requires that x509 certificates be issued. The
# default it to keep them in /etc/pki/libvirt-spice. This directory
# must contain
#
#  ca-cert.pem - the CA master certificate
#  server-cert.pem - the server certificate signed with ca-cert.pem
#  server-key.pem  - the server private key
#
# This option allows the certificate directory to be changed.
#
#spice_tls_x509_cert_dir = "/etc/pki/libvirt-spice"


# The default SPICE password. This parameter is only used if the
# per-domain XML config does not already provide a password. To
# allow access without passwords, leave this commented out. An
# empty string will still enable passwords, but be rejected by
# QEMU, effectively preventing any use of SPICE. Obviously change
# this example here before you set this.
#
#spice_password = "XYZ12345"


# Enable use of SASL encryption on the SPICE server. This requires
# a SPICE client which supports the SASL protocol extension.
#
# It is necessary to configure /etc/sasl2/qemu.conf to choose
# the desired SASL plugin (eg, GSSPI for Kerberos)
#
#spice_sasl = 1

# The default SASL configuration file is located in /etc/sasl2/
# When running libvirtd unprivileged, it may be desirable to
# override the configs in this location. Set this parameter to
# point to the directory, and create a qemu.conf in that location
#
#spice_sasl_dir = "/some/directory/sasl2"


# By default, if no graphical front end is configured, libvirt will disable
# QEMU audio output since directly talking to alsa/pulseaudio may not work
# with various security settings. If you know what you're doing, enable
# the setting below and libvirt will passthrough the QEMU_AUDIO_DRV
# environment variable when using nographics.
#
#nographics_allow_host_audio = 1


# Override the port for creating both VNC and SPICE sessions (min).
# This defaults to 5900 and increases for consecutive sessions
# or when ports are occupied, until it hits the maximum.
#
# Minimum must be greater than or equal to 5900 as lower number would
# result into negative vnc display number.
#
# Maximum must be less than 65536, because higher numbers do not make
# sense as a port number.
#
#remote_display_port_min = 5900
#remote_display_port_max = 65535

# VNC WebSocket port policies, same rules apply as with remote display
# ports.  VNC WebSockets use similar display <-> port mappings, with
# the exception being that ports start from 5700 instead of 5900.
#
#remote_websocket_port_min = 5700
#remote_websocket_port_max = 65535

# The default security driver is SELinux. If SELinux is disabled
# on the host, then the security driver will automatically disable
# itself. If you wish to disable QEMU SELinux security driver while
# leaving SELinux enabled for the host in general, then set this
# to 'none' instead. It's also possible to use more than one security
# driver at the same time, for this use a list of names separated by
# comma and delimited by square brackets. For example:
#
#       security_driver = [ "selinux", "apparmor" ]
#
# Notes: The DAC security driver is always enabled; as a result, the
# value of security_driver cannot contain "dac".  The value "none" is
# a special value; security_driver can be set to that value in
# isolation, but it cannot appear in a list of drivers.
#
#security_driver = "selinux"

# If set to non-zero, then the default security labeling
# will make guests confined. If set to zero, then guests
# will be unconfined by default. Defaults to 1.
#security_default_confined = 1

# If set to non-zero, then attempts to create unconfined
# guests will be blocked. Defaults to 0.
#security_require_confined = 1

# The user for QEMU processes run by the system instance. It can be
# specified as a user name or as a user id. The qemu driver will try to
# parse this value first as a name and then, if the name doesn't exist,
# as a user id.
#
# Since a sequence of digits is a valid user name, a leading plus sign
# can be used to ensure that a user id will not be interpreted as a user
# name.
#
# Some examples of valid values are:
#
#       user = "qemu"   # A user named "qemu"
#       user = "+0"     # Super user (uid=0)
#       user = "100"    # A user named "100" or a user with uid=100
#
user = "root"

# The group for QEMU processes run by the system instance. It can be
# specified in a similar way to user.
group = "root"

# Whether libvirt should dynamically change file ownership
# to match the configured user/group above. Defaults to 1.
# Set to 0 to disable file ownership changes.
dynamic_ownership = 0


# What cgroup controllers to make use of with QEMU guests
#
#  - 'cpu' - use for schedular tunables
#  - 'devices' - use for device whitelisting
#  - 'memory' - use for memory tunables
#  - 'blkio' - use for block devices I/O tunables
#  - 'cpuset' - use for CPUs and memory nodes
#  - 'cpuacct' - use for CPUs statistics.
#
# NB, even if configured here, they won't be used unless
# the administrator has mounted cgroups, e.g.:
#
#  mkdir /dev/cgroup
#  mount -t cgroup -o devices,cpu,memory,blkio,cpuset none /dev/cgroup
#
# They can be mounted anywhere, and different controllers
# can be mounted in different locations. libvirt will detect
# where they are located.
#
#cgroup_controllers = [ "cpu", "devices", "memory", "blkio", "cpuset", "cpuacct" ]

# This is the basic set of devices allowed / required by
# all virtual machines.
#
# As well as this, any configured block backed disks,
# all sound device, and all PTY devices are allowed.
#
# This will only need setting if newer QEMU suddenly
# wants some device we don't already know about.
#
#cgroup_device_acl = [
#    "/dev/null", "/dev/full", "/dev/zero",
#    "/dev/random", "/dev/urandom",
#    "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
#    "/dev/rtc","/dev/hpet", "/dev/vfio/vfio"
#]
#
# RDMA migration requires the following extra files to be added to the list:
#   "/dev/infiniband/rdma_cm",
#   "/dev/infiniband/issm0",
#   "/dev/infiniband/issm1",
#   "/dev/infiniband/umad0",
#   "/dev/infiniband/umad1",
#   "/dev/infiniband/uverbs0"


# The default format for Qemu/KVM guest save images is raw; that is, the
# memory from the domain is dumped out directly to a file.  If you have
# guests with a large amount of memory, however, this can take up quite
# a bit of space.  If you would like to compress the images while they
# are being saved to disk, you can also set "lzop", "gzip", "bzip2", or "xz"
# for save_image_format.  Note that this means you slow down the process of
# saving a domain in order to save disk space; the list above is in descending
# order by performance and ascending order by compression ratio.
#
# save_image_format is used when you use 'virsh save' or 'virsh managedsave'
# at scheduled saving, and it is an error if the specified save_image_format
# is not valid, or the requested compression program can't be found.
#
# dump_image_format is used when you use 'virsh dump' at emergency
# crashdump, and if the specified dump_image_format is not valid, or
# the requested compression program can't be found, this falls
# back to "raw" compression.
#
# snapshot_image_format specifies the compression algorithm of the memory save
# image when an external snapshot of a domain is taken. This does not apply
# on disk image format. It is an error if the specified format isn't valid,
# or the requested compression program can't be found.
#
#save_image_format = "raw"
#dump_image_format = "raw"
#snapshot_image_format = "raw"

# When a domain is configured to be auto-dumped when libvirtd receives a
# watchdog event from qemu guest, libvirtd will save dump files in directory
# specified by auto_dump_path. Default value is /var/lib/libvirt/qemu/dump
#
#auto_dump_path = "/var/lib/libvirt/qemu/dump"

# When a domain is configured to be auto-dumped, enabling this flag
# has the same effect as using the VIR_DUMP_BYPASS_CACHE flag with the
# virDomainCoreDump API.  That is, the system will avoid using the
# file system cache while writing the dump file, but may cause
# slower operation.
#
#auto_dump_bypass_cache = 0

# When a domain is configured to be auto-started, enabling this flag
# has the same effect as using the VIR_DOMAIN_START_BYPASS_CACHE flag
# with the virDomainCreateWithFlags API.  That is, the system will
# avoid using the file system cache when restoring any managed state
# file, but may cause slower operation.
#
#auto_start_bypass_cache = 0

# If provided by the host and a hugetlbfs mount point is configured,
# a guest may request huge page backing.  When this mount point is
# unspecified here, determination of a host mount point in /proc/mounts
# will be attempted.  Specifying an explicit mount overrides detection
# of the same in /proc/mounts.  Setting the mount point to "" will
# disable guest hugepage backing. If desired, multiple mount points can
# be specified at once, separated by comma and enclosed in square
# brackets, for example:
#
#     hugetlbfs_mount = ["/dev/hugepages2M", "/dev/hugepages1G"]
#
# The size of huge page served by specific mount point is determined by
# libvirt at the daemon startup.
#
# NB, within these mount points, guests will create memory backing
# files in a location of $MOUNTPOINT/libvirt/qemu
#
#hugetlbfs_mount = "/dev/hugepages"


# Path to the setuid helper for creating tap devices.  This executable
# is used to create <source type='bridge'> interfaces when libvirtd is
# running unprivileged.  libvirt invokes the helper directly, instead
# of using "-netdev bridge", for security reasons.
#bridge_helper = "/usr/libexec/qemu-bridge-helper"



# If clear_emulator_capabilities is enabled, libvirt will drop all
# privileged capabilities of the QEmu/KVM emulator. This is enabled by
# default.
#
# Warning: Disabling this option means that a compromised guest can
# exploit the privileges and possibly do damage to the host.
#
#clear_emulator_capabilities = 1


# If enabled, libvirt will have QEMU set its process name to
# "qemu:VM_NAME", where VM_NAME is the name of the VM. The QEMU
# process will appear as "qemu:VM_NAME" in process listings and
# other system monitoring tools. By default, QEMU does not set
# its process title, so the complete QEMU command (emulator and
# its arguments) appear in process listings.
#
#set_process_name = 1


# If max_processes is set to a positive integer, libvirt will use
# it to set the maximum number of processes that can be run by qemu
# user. This can be used to override default value set by host OS.
# The same applies to max_files which sets the limit on the maximum
# number of opened files.
#
#max_processes = 0
#max_files = 0



# mac_filter enables MAC addressed based filtering on bridge ports.
# This currently requires ebtables to be installed.
#
#mac_filter = 1


# By default, PCI devices below non-ACS switch are not allowed to be assigned
# to guests. By setting relaxed_acs_check to 1 such devices will be allowed to
# be assigned to guests.
#
#relaxed_acs_check = 1


# If allow_disk_format_probing is enabled, libvirt will probe disk
# images to attempt to identify their format, when not otherwise
# specified in the XML. This is disabled by default.
#
# WARNING: Enabling probing is a security hole in almost all
# deployments. It is strongly recommended that users update their
# guest XML <disk> elements to include  <driver type='XXXX'/>
# elements instead of enabling this option.
#
#allow_disk_format_probing = 1


# In order to prevent accidentally starting two domains that
# share one writable disk, libvirt offers two approaches for
# locking files. The first one is sanlock, the other one,
# virtlockd, is then our own implementation. Accepted values
# are "sanlock" and "lockd".
#
#lock_manager = "lockd"



# Set limit of maximum APIs queued on one domain. All other APIs
# over this threshold will fail on acquiring job lock. Specially,
# setting to zero turns this feature off.
# Note, that job lock is per domain.
#
#max_queued = 0

###################################################################
# Keepalive protocol:
# This allows qemu driver to detect broken connections to remote
# libvirtd during peer-to-peer migration.  A keepalive message is
# sent to the daemon after keepalive_interval seconds of inactivity
# to check if the daemon is still responding; keepalive_count is a
# maximum number of keepalive messages that are allowed to be sent
# to the daemon without getting any response before the connection
# is considered broken.  In other words, the connection is
# automatically closed approximately after
# keepalive_interval * (keepalive_count + 1) seconds since the last
# message received from the daemon.  If keepalive_interval is set to
# -1, qemu driver will not send keepalive requests during
# peer-to-peer migration; however, the remote libvirtd can still
# send them and source libvirtd will send responses.  When
# keepalive_count is set to 0, connections will be automatically
# closed after keepalive_interval seconds of inactivity without
# sending any keepalive messages.
#
#keepalive_interval = 5
#keepalive_count = 5



# Use seccomp syscall whitelisting in QEMU.
# 1 = on, 0 = off, -1 = use QEMU default
# Defaults to -1.
#
#seccomp_sandbox = 1


# Override the listen address for all incoming migrations. Defaults to
# 0.0.0.0, or :: if both host and qemu are capable of IPv6.
#migration_address = "0.0.0.0"


# The default hostname or IP address which will be used by a migration
# source for transferring migration data to this host.  The migration
# source has to be able to resolve this hostname and connect to it so
# setting "localhost" will not work.  By default, the host's configured
# hostname is used.
#migration_host = "host.example.com"


# Override the port range used for incoming migrations.
#
# Minimum must be greater than 0, however when QEMU is not running as root,
# setting the minimum to be lower than 1024 will not work.
#
# Maximum must not be greater than 65535.
#
#migration_port_min = 49152
#migration_port_max = 49215



# Timestamp QEMU's log messages (if QEMU supports it)
#
# Defaults to 1.
#
#log_timestamp = 0


# Location of master nvram file
#
# When a domain is configured to use UEFI instead of standard
# BIOS it may use a separate storage for UEFI variables. If
# that's the case libvirt creates the variable store per domain
# using this master file as image. Each UEFI firmware can,
# however, have different variables store. Therefore the nvram is
# a list of strings when a single item is in form of:
#   ${PATH_TO_UEFI_FW}:${PATH_TO_UEFI_VARS}.
# Later, when libvirt creates per domain variable store, this list is
# searched for the master image. The UEFI firmware can be called
# differently for different guest architectures. For instance, it's OVMF
# for x86_64 and i686, but it's AAVMF for aarch64. The libvirt default
# follows this scheme.
#nvram = [
#   "/usr/share/OVMF/OVMF_CODE.fd:/usr/share/OVMF/OVMF_VARS.fd",
#   "/usr/share/AAVMF/AAVMF_CODE.fd:/usr/share/AAVMF/AAVMF_VARS.fd"
#]
EOF



# Edit /etc/libvirt/qemu.conf file
cat >> /etc/nova/nova.conf  <<EOF

[libvirt]
live_migration_flag=VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_TUNNELLED
live_migration_uri=qemu+tcp://%s/system

EOF

# restart the libvirt-bin service
service libvirt-bin restart
/etc/init.d/nfs-kernel-server restart

service nova-api restart

# Change the permissions
chmod 777 /var/lib/nova/instances

# change the shell of nova
chsh -s /bin/sh nova

# copy the .ssh file
cp -r ~/.ssh /var/lib/nova/.ssh/

# Edit /etc/ssh/ssh_config file
cat >>  /etc/ssh/ssh_config  <<EOF
    StrictHostKeyChecking no
EOF

# Change the permissions
chmod 644 /var/lib/nova/.ssh/authorized_keys
chown nova:nova /var/lib/nova/instances

# Restart ssh service
service ssh restart



echo;
echo "##############################################################################################"
echo;
echo "Live migration setup in Controller node is done."
echo;
echo "##############################################################################################"
echo;