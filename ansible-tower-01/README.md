# Let's build a tower (part 2) [draft]

Before starting to use AWX we need to check/configure first things.

[Tower Authentication](https://docs.ansible.com/ansible-tower/latest/html/administration/configure_tower_in_tower.html)
[Create new user](https://docs.ansible.com/ansible-tower/latest/html/userguide/users.html)

## Configure host settings

Under 'Administration' section choose 'Settings' -> 'Configuration' and change 'BASE URL' to your AWX address and add ['HTTP_X_FORWARDED_FOR'](https://docs.ansible.com/ansible-tower/latest/html/administration/proxy-support.html#configure-known-proxies) parameter to 'REMOTE HOST HEADERS':
![System configuration](/images/ansible-tower/system_config.png)

## Create Azure AD test user
![Azure domain name](/images/ansible-tower/find_aad_domain.png)
![New Azure AD user](/images/ansible-tower/new_aad_user.png)

## Implement and try Azure AD authentication

Go to [Azure Portal](https://portal.azure.com/) and create new application:
![Azure AD app registration](/images/ansible-tower/aad_app_reg.png)

For a new created application generate secret key:
![Azure AD app secret](/images/ansible-tower/aad_oauth2.png)

Setup Azure AD authentication on AWX side:
![AWX Azure Authentication](/images/ansible-tower/aad_auth_conf.png)

Open browser in incognito mode and try to login using Azure credentials:
![AWX Azure login](/images/ansible-tower/aad_login.png)

## Update environment settings

![AWX configuration](/images/ansible-tower/cleanup_00.png)
![AWX configuration](/images/ansible-tower/cleanup_01.png)
![AWX configuration](/images/ansible-tower/cleanup_02.png)


## Run a first project
Due to [official documentation](https://docs.ansible.com/ansible-tower/2.4.1/html/quickstart/create_project.html):
![AWX assign user to an organisation](/images/ansible-tower/grant_user_rights.png)

![New project creation](/images/ansible-tower/initial_project.png)
![Job execution results](/images/ansible-tower/init_run_result.png)


https://docs.ansible.com/ansible-tower/latest/html/administration/social_auth.html

https://docs.ansible.com/ansible-tower/latest/html/administration/configure_tower_in_tower.html

https://docs.ansible.com/ansible-tower/latest/html/administration/oauth2_token_auth.html#application-functions

https://docs.ansible.com/ansible-tower/latest/html/userguide/organizations.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/users.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/teams.html
