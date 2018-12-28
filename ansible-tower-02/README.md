# Let's build a tower (part 3) [draft]

## Introduction
[On previous chapter](/ansible-tower-01) we configured Azure AD authentication and created hello-world project. Now we can try to do something more useful. For example, we could try to install NGINX package on some test VM using AWX. 

![Scheme](/images/ansible-tower/awx_flow.png)

## Workflow
1. Create an inventory
1. Add a host to the inventory
1. Create a credential
1. Setup a project
1. Create a job template
1. Launch the template
![](https://d1jnx9ba8s6j9r.cloudfront.net/blog/wp-content/uploads/2018/09/4-1.png)
