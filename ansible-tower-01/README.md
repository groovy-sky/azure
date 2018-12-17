# Let's build a tower (part 2) [draft]

Before starting to use AWX we need to check/configure first things:
1. Configure host settings
Under 'Administration' section choose 'Settings' -> 'Configuration' and change 'BASE URL' to your AWX address and add ['HTTP_X_FORWARDED_FOR'](https://docs.ansible.com/ansible-tower/latest/html/administration/proxy-support.html#configure-known-proxies) parameter to 'REMOTE HOST HEADERS':
![System configuration](/images/ansible-tower/system_config.png)

1. Implement Azure AD authentication
Got to (Azure Portal)[https://portal.azure.com/] and create new application:
![Azure AD app registration](/images/ansible-tower/aad_app_reg.png)

For a new created application generate secret key:
![Azure AD app secret](/images/ansible-tower/aad_oauth2.png)

Setup Azure AD authentication on AWX side:
![AWX AD app secret](/images/ansible-tower/aad_auth_config.png)


https://docs.ansible.com/ansible-tower/latest/html/administration/social_auth.html

https://docs.ansible.com/ansible-tower/latest/html/administration/configure_tower_in_tower.html

https://docs.ansible.com/ansible-tower/latest/html/administration/oauth2_token_auth.html#application-functions

https://docs.ansible.com/ansible-tower/latest/html/userguide/organizations.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/users.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/teams.html
