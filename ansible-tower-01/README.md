# Let's build a tower (part 2)
## Introduction

One of the main AWX features is "Role-based access" option. It can be configured to centrally use OAuth2, SAML, RADIUS, or even LDAP. For our environment we will configure Azure AD OAuth2 authentication. For doing that we will need to create new Azure user and register Azure AD application

## Create Azure AD test user
There is [misunderstanding](https://techcommunity.microsoft.com/t5/Azure-Active-Directory-Identity/Cleaning-up-the-AzureAD-and-Microsoft-account-overlap/ba-p/245105) in Azure AD about what type account should/could be used in different cases. Which is why the easiest way to avoid it - create new account with a default domain name.

> User creation requires admin rights

To check what is default domain please follow instructions below:
![Azure domain name](/images/ansible-tower/find_aad_domain.png)

Now we can create new user, using default domain (which should ends with '.onmicrosoft.com' or '.emea.microsoftonline.com' names):
![New Azure AD user](/images/ansible-tower/new_aad_user.png)

## Azure AD application registration

Any application that wants to use the capabilities of Azure AD must first be registered in an [Azure AD tenant](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-v1-add-azure-ad-app). Please, be aware, and during registration use 'http://yourdomain/sso/complete/azuread-oauth2/' for a 'Sign-on URL':
![Azure AD app registration](/images/ansible-tower/aad_app_reg.png)

For a new created application generate secret key and copy application id and application key:
![Azure AD app secret](/images/ansible-tower/aad_oauth2.png)

## Configure AWX

In AWX update the system settings - 'BASE URL' and 'REMOTE HOST HEADERS' (add parameter ['HTTP_X_FORWARDED_FOR'](https://docs.ansible.com/ansible-tower/latest/html/administration/proxy-support.html#configure-known-proxies)):
![System configuration](/images/ansible-tower/system_config.png)

Fill required parameters using Azure AD application id and secret (created in previous chapter):
![AWX Azure Authentication](/images/ansible-tower/aad_auth_conf.png)

## Test new authentication method

Now we can try to access AWX using Azure user. To be sure that some credentials wasn't cached I suggest to use Firefox in private-mode:
![AWX Azure login](/images/ansible-tower/aad_login.png)

## Clean and update the Organization

As an [official documentation](https://docs.ansible.com/ansible-tower/latest/html/userguide/organizations.html#) says - "an Organization is a logical collection of Users, Teams, Projects, and Inventories, and is the highest level in the Tower object hierarchy." 

![AWX hierarchy](/images/ansible-tower/tower_h.png)

Also from the documentation - "If you are using Ansible Tower with a Self-Support level license (formerly called Basic), you must use the default Organization. Do not delete it and try to add a new Organization, or you will break your Tower setup. Only two Tower license types (Enterprise: Standard or Enterprise: Premium) have the ability to add new Organizations beyond the default."

Which is why we don't remove/create an organization and just update it(please use whatever Organization name is prefferable for you):
![AWX configuration](/images/ansible-tower/cleanup_00.png)

In order to eliminate disarray let's remove demo inventory and demo project:
![AWX configuration](/images/ansible-tower/cleanup_01.png)
![AWX configuration](/images/ansible-tower/cleanup_02.png)

## Assign user to the Organization

Now then we have make sure that Azure authorization works we can grant 
Due to [official documentation](https://docs.ansible.com/ansible-tower/2.4.1/html/quickstart/create_project.html):
![AWX assign user to an organisation](/images/ansible-tower/grant_user_rights.png)

## Run a first project

![New project creation](/images/ansible-tower/initial_project.png)
![Job execution results](/images/ansible-tower/init_run_result.png)

## Useful documentation
[Tower Authentication](https://docs.ansible.com/ansible-tower/latest/html/administration/configure_tower_in_tower.html)

[Create new user](https://docs.ansible.com/ansible-tower/latest/html/userguide/users.html)

[Organization structure](https://docs.ansible.com/ansible-tower/latest/html/userguide/organizations.html)
https://docs.ansible.com/ansible-tower/latest/html/administration/configure_tower_in_tower.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/users.html

https://docs.ansible.com/ansible-tower/latest/html/userguide/teams.html
