# Let's build a tower (part 2)

## Introduction

One of the main AWX features is "Role-based access" option(which should be familiar if you worked before with Azure RM). It can be configured to centrally use OAuth2, SAML, RADIUS, or even LDAP. For our environment we will configure Azure AD OAuth2 authentication. For doing that, we will need to create new Azure user and register Azure AD application.

## Create Azure AD user for accessing AWX
There is [misunderstanding](https://techcommunity.microsoft.com/t5/Azure-Active-Directory-Identity/Cleaning-up-the-AzureAD-and-Microsoft-account-overlap/ba-p/245105) in Azure AD about what type account should/could be used in different cases. Which is why the easiest way to avoid it - create new account with a default domain name.

> User creation requires admin rights

To check what is default domain please follow instructions below:
![Azure domain name](/images/ansible-tower/find_aad_domain.png)

Now we can create new user, using default domain (which should end with '.onmicrosoft.com' or '.emea.microsoftonline.com'):
![New Azure AD user](/images/ansible-tower/new_aad_user.png)

## Azure AD application registration

Any application that wants to use the capabilities of Azure AD must first be registered in an [Azure AD tenant](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-v1-add-azure-ad-app). Please, be aware, and during registration use 'http://yourdomain/sso/complete/azuread-oauth2/' (not https://) for a 'Sign-on URL':
![Azure AD app registration](/images/ansible-tower/aad_app_reg.png)

For a new created application generate secret key and copy application id and application key:
![Azure AD app secret](/images/ansible-tower/aad_oauth2.png)

## Configure AWX

In AWX update the system settings - 'BASE URL' (to the AWX address) and 'REMOTE HOST HEADERS' (add parameter ['HTTP_X_FORWARDED_FOR'](https://docs.ansible.com/ansible-tower/latest/html/administration/proxy-support.html#configure-known-proxies)):
![System configuration](/images/ansible-tower/system_config.png)

Fill required parameters using Azure AD application id and secret:
![AWX Azure Authentication](/images/ansible-tower/aad_auth_conf.png)

## Test new authentication method

Now we can try to access AWX using Azure user. To be sure that some credentials wasn't cached I suggest using Firefox in private-mode:
![AWX Azure login](/images/ansible-tower/aad_login.png)

## Clean and update the Organization

As an [official documentation](https://docs.ansible.com/ansible-tower/latest/html/userguide/organizations.html#) says - "an Organization is a logical collection of Users, Teams, Projects, and Inventories, and is the highest level in the Tower object hierarchy." 

![AWX hierarchy](/images/ansible-tower/tower_h.png)

Also, from the same document - "If you are using Ansible Tower with a Self-Support level license (formerly called Basic), you must use the default Organization. Do not delete it and try to add a new Organization, or you will break your Tower setup. Only two Tower license types (Enterprise: Standard or Enterprise: Premium) have the ability to add new Organizations beyond the default."

Which is why we don't remove/create an organization and just update existing one(please use whatever organization name is preferable for you):
![AWX configuration](/images/ansible-tower/cleanup_00.png)

To eliminate disarray let's clean-up created by default environment:
![AWX configuration](/images/ansible-tower/cleanup.png)

## Assign user to the Organization

Now then we have ensured that Azure authorization works, we can [grant rights to our new user](https://docs.ansible.com/ansible-tower/2.4.1/html/quickstart/create_project.html):
![AWX assign user to an organization](/images/ansible-tower/grant_user_rights.png)

## Create your first project

From now on we will use Azure's user to engage with AWX. For a test purposes let's create new project using [an official example playbook]( https://github.com/ansible/tower-example.git):

![New project creation](/images/ansible-tower/initial_project.png)
![Job execution results](/images/ansible-tower/init_run_result.png)

## Useful documentation

* [Organization structure](https://docs.ansible.com/ansible-tower/latest/html/userguide/organizations.html)

* [Teams](https://docs.ansible.com/ansible-tower/latest/html/userguide/teams.html)

* [Tower Authentication](https://docs.ansible.com/ansible-tower/3.3.2/html/administration/social_auth.html#ag-authentication)

* [Create new user](https://docs.ansible.com/ansible-tower/latest/html/userguide/users.html)

## References

[Let's build a tower (part 1)](/ansible-tower-00/README.md)

[Let's build a tower (part 2)](/ansible-tower-01/README.md)

[Let's build a tower (part 3)](/ansible-tower-02/README.md)
