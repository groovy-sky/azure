# Guide to Azure Template Specs

## Introduction

In modern cloud environments, infrastructure as code ensures consistency, compliance, and operational efficiency. Traditional methods of sharing ARM templates via external repositories or storage accounts introduce security risks, version control complexities, and governance gaps. Azure Template Specs address these issues by converting templates into native Azure resources that integrate seamlessly with Azure’s management, security, and policy frameworks. They provide a centralized, secure, and governed approach to managing infrastructure as code at enterprise scale. By packaging templates with built-in versioning, access control, and policy integration, Template Specs solve common challenges around consistency, compliance, and collaboration.

## Theoretical Part

Template Specs (`Microsoft.Resources/templateSpecs`) are Azure resources designed to store, version, and distribute ARM templates directly within your subscription. They bundle a main template and any linked dependencies into a single, reusable object. You can reference them by resource ID or alias in your deployments, eliminating the need to manage file paths or repository URLs.

### Core Characteristics

- Native Azure Resources  
  Template Specs have a full lifecycle as first-class resources, visible in portals, CLI, and Azure Resource Graph.

- Version Control  
  Each publish creates a new version. You can pin deployments to specific versions or always use the latest.

- Security Integration  
  Leverages Azure RBAC for fine-grained access control at the template level, removing the need for storage keys or repo permissions.

- Policy and Governance  
  Integrates with Azure Policy to enforce naming conventions, allowed template usage, and audit changes through Resource Graph.

- Template Packaging  
  Automatically includes linked templates and nested deployments, ensuring all dependencies travel together.

### Resource Hierarchy

Template Specs use a parent-child model for versioning:

```
Template Spec: mySpec
├── Version 1.0
├── Version 1.1
└── Version 2.0
```

Each version is a child resource under the parent `templateSpec`, enabling clear life cycle and rollback capabilities.

### Template Specs vs ARM Templates

| Feature              | Repo/Storage Templates        | Template Specs                   |
|----------------------|-------------------------------|----------------------------------|
| Storage Location     | Git or storage account        | Native Azure resource            |
| Versioning           | Git tags, branches            | First-class `version` property    |
| Access Control       | Storage or repo permissions   | Azure RBAC on the spec resource  |
| Policy Integration   | Indirect                      | Direct via Resource Graph & Policy|
| Deployment Reference | URLs or file paths            | Resource ID or spec alias        |

### Template publish example

1. Author your ARM JSON or Bicep template locally.

2. Publish a version with Azure CLI:
   ```bash
   az ts create \
     --name mySpec \
     --resource-group infraRG \
     --version 1.0 \
     --template-file main.json
   ```

3. Deploy from the Template Spec:
   ```bash
   az deployment group create \
     --resource-group infraRG \
     --template-spec /subscriptions/<sub>/resourceGroups/infraRG/providers/Microsoft.Resources/templateSpecs/mySpec/versions/1.0 \
     --parameters key=value
   ```

4. Update your template and publish version 1.1, 2.0, and so on.

## Summary

By making ARM templates native Azure resources, Template Specs deliver consistent, secure, and governed infrastructure deployments at scale. Organizations can achieve better visibility, stronger control, and streamlined teamwork—while preserving the flexibility of infrastructure as code.
