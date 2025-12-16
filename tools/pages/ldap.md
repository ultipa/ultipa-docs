# LDAP

> This article introduces the minimum procedure of using **Ultipa LDAP** in conjuction with **phpLDAPadmin** to manage users of Ultipa server. Other LDAP administration tools such as Active Directory are also compatible.

## Prerequisites

- A command line terminal such as: 
    - Linux: [bash](https://www.gnu.org/software/bash), [zsh](https://www.zsh.org/), [tcsh](https://www.tcsh.org/)
    - MacOS X Terminal, iTerm
    - Windows: [PowerShell](https://learn.microsoft.com/en-us/powershell/)
- A version of [Ultipa LDAP](https://www.ultipa.com/download) compatible with your operating system
- phpLDAPadmin deployed on your operating system

## Operation Procedure

1. Generate sample configuration file `example_config.yaml`
<p tit= "bash" ></p> 

```bash
./ultipaLDAP -g 
```

2. Revise `example_config.yaml` and start Ultipa LDAP
```bash
./ultipaLDAP -config example_config.yaml -logfile log.log
```

Command options:  

| <div table-width=20>Option</div> | Explanation |
| - | - |
| -h  | Show help  |
| -config [string]  | Specify configuration file name (default 'config.yaml')   |
| -g  | Generate configuration file template ('example_config.yaml')   |
| -logfile [string]  | Specify log file name (default 'log.log')     |


## Configuration File  
<p tit= "YAML" type="yaml"></p> 

```yml
ProxyConfig:
# proxi listen
  ListenHost: 0.0.0.0
  ListenPort: 19090

# ultipa server
UltipaServerConfig:
  UserName: root
  PassWord: root
  Hosts:
    - "192.168.56.101:60010"

# ldap server
LdapServerConfig:
  Url: "ldap://192.168.56.102:389"
  Username: "cn=admin,dc=ultipa,dc=it"
  Password: "password"
  BaseDn: "ou=tech,dc=ultipa,dc=it"
  # default: inetOrgPerson, use uid as user name
  UserObjectClass:
  # default: posixGroup
  GroupObjectClass:
  # default: objectClass=inetOrgPerson
  UserFilter:
  # default: objectClass=posixGroup
  GroupFilter:

# synchronization
SyncUserConfig:
  # a string to be prefixed to the user name in ldap when creating user in the ultipa server, default: ldapuser_, e.g., user 'jim' in ldap will be created as 'ldapuser_jim' in ultipa server
  UserNamePrefix: ldap_
  # synchronizing cycle in seconds, default: 60
  SyncCycle: 5
  # whether to delete user from ultipa server when its corresponding user is deleted from ldap, default: false
  DelUser: true
  # when creating users, whether to assign related polices to users in ultipa server according to users and their groups in ldap and always maintain these assignments; this also applies to those policies that are created later than the users
  GrantPoliciesByGroup: true
  # a string to be prefixed to the group name in ldap when mapping policy in the ultipa server, e.g., group 'dev' in ldap will be mapped as 'ldap_dev' in ultipa server
  UltipaPolicyPrefix: ldap_
  # static mapping between groups in ldap and policies in ultipa server, which takes effect simultaneously with the above item
  StaticMap:
    # LdapUserGroup : UltipaPolicy
    dev : dev_policy
```

## User Management via phpLDAPadmin

1. Use `Username` and `Password` configured under `LdapServerConfig` in the yaml file to login to phpLDAPadmin

2. In phpLDAPadmin, create a generic user account 'mlee', create a posix group 'general' and assign 'mlee' to this group:

<center><img src="https://img.ultipa.cn/img/2024-02-29-17-12-44-general.jpg"></center>

3. In Ultipa Manager, user 'ldap_mlee' is automatically created. Manually create policy 'ldap_general' and run `show().user()`:

<center><img src="https://img.ultipa.cn/img/2024-02-29-17-21-57-ldap-general.jpg"></center>

> According to the setting of `UserNamePrefix` and `UltipaPolicyPrefix` under `SyncUserConfig` in the yaml file, an 'ldap_' will be prefixed to 'mlee' and 'general', this explains why the user name and policy created in Ultipa server is 'ldap_mlee' and 'ldap_general' instead of 'mlee' and 'general'.

