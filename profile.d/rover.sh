#
## Managed by Rocketho.me
## Revision 10 Mar 2014

#
#-- Set IP Env stuff

# Extract the local IP
export IP=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

# Extract the External IP
export EIP=$(curl -s icanhazip.com)

#
#-- Set Directory Stuff

# Set WWW dir
export WWWDIR='/var/www/'
export GITDIR='/var/git/'
