# Let's build a tower (part 2) [draft]

Before starting to use AWX we need to check/configure first things:
1. Under 'Administration' section choose 'Settings' -> 'Configuration' and change 'BASE URL' to your AWX address and add ['HTTP_X_FORWARDED_FOR'](https://docs.ansible.com/ansible-tower/latest/html/administration/proxy-support.html#configure-known-proxies) parameter to 'REMOTE HOST HEADERS':
![System configuration](/images/ansible-tower/system_config.png)


https://docs.ansible.com/ansible-tower/latest/html/administration/configure_tower_in_tower.html

https://docs.ansible.com/ansible-tower/latest/html/administration/oauth2_token_auth.html#application-functions

https://docs.ansible.com/ansible-tower/latest/html/userguide/organizations.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/users.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/teams.html
