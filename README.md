DataBase_fundas
===============

all queries are written only for postgres database.


Interesting Articles:

http://patshaughnessy.net/2014/10/13/following-a-select-statement-through-postgres-internals

http://patshaughnessy.net/2014/11/11/discovering-the-computer-science-behind-postgres-indexes

http://blog.tarkalabs.com/2015/04/16/managing-big-enough-data-in-postgres/


INSATLL POSTGRES
================

[kelvin@schettino ~]$ sudo yum install postgresql-server


Configure Postgres – Initialize and start service
--------------------------------------------------
kelvin@schettino ~]$ sudo service postgresql initdb


Set the server to restart on reboots and start the postmaster service:
-----------------------------------------------------------------------
[kelvin@schettino ~]$ sudo chkconfig postgresql on
[kelvin@schettino ~]$ sudo service postgresql start


Configure Postgres – Set superuser password
--------------------------------------------
[kelvin@schettino ~]$ su -
[root@schettino ~]# su - postgres
-bash-4.1$ psql

postgres=# \password postgres
Enter new password:
Enter it again:
postgres=# \q



Configure Postgres – Activate password authentication
-------------------------------------------------------
By default, the server uses ident as defined in the “PostgreSQL Client Authentication Configuration File”.
If you open up pg_hba.conf you can see this default configuration:

# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
 
# "local" is for Unix domain socket connections only
local   all         all                               ident
# IPv4 local connections:
host    all         all         127.0.0.1/32          ident
# IPv6 local connections:
host    all         all         ::1/128               ident

Ident is a mapping of local system users (see /etc/passwd for list of system users) to Postgres users.
I have never found this authentication method useful for any of the web development work that I have done. I always change it to “md5″ which allows you to create arbitrary users and passwords.
Let’s change the server’s client configuration file (I assume you are still using the postgres user shell):


-bash-4.1$ whoami
postgres
-bash-4.1$ vim /var/lib/pgsql/data/pg_hba.conf


Change the “ident” methods to “md5″ methods at the bottom of the pg_hba.conf file:
----------------------------------------------------------------------------------

# TYPE  DATABASE    USER        CIDR-ADDRESS          METHOD
 
# "local" is for Unix domain socket connections only
local   all         all                               md5
# IPv4 local connections:
host    all         all         127.0.0.1/32          md5
# IPv6 local connections:
host    all         all         ::1/128               md5
# If you don't want to open Postgres to the Internet
# don't enable this line
host    all         all         0.0.0.0/0             md5



By default, Postgres binds only to localhost and you will need to explicitly tell it to bind to your machine’s IP address. The setting is in postgres.conf. If you don’t need remote access you can skip this.

-bash-4.1$ vim /var/lib/pgsql/data/postgresql.conf

Change the listen_addresses setting to an asterisk to listen to all available IP addresses:

# - Connection Settings -
 
listen_addresses = '*'
#listen_addresses = 'localhost'         # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost', '*' = all
                                        # (change requires restart)


Restart your postgres server (exit postgres user into the root shell):
-bash-4.1$ exit
[root@schettino ~]# service postgresql restart



Open Firewall
----------------
If you want remote access to the server on Postgres port 5432 you will have to open a port on the firewall.
If you still are the root user, type the following:

[root@schettino ~]# whoami
root
[root@schettino ~]# vim /etc/sysconfig/iptables

You can just copy the SSH port rule in iptables and modify the port number from 22 to 5432.

Add the following rule just below the SSH port rule and above the rejection rule for the INPUT chain:
10

-A INPUT -m state --state NEW -m tcp -p tcp --dport 5432 -j ACCEPT


Reload the rules:
------------------
[root@schettino ~]# service iptables restart
[root@schettino ~]# exit


Create a new Postgres user by using the createuser wrapper (the P switch allows you to set a password for your new user):
---------------------------------------------------------------------------------------------------------
[kelvin@schettino ~]$ su -
[root@schettino ~]# su - postgres
-bash-4.1$ createuser -P francesco


Make a new database named “winnings” and change the owner to “francesco”:
-bash-4.1$ createdb -O francesco winnings











