# Running a self-hosted build agent on Azure Kubernetes Service 
## Introduction

## Theoretical Part


## Prerequisites
## Practical Part
Start by centralizing every value you would otherwise hardcode. Reusing the same environment variables across each step keeps scripts portable and prevents accidental typos.

```bash
export SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export LOCATION="eastus"
export RG_NAME="myRG"
export IDENTITY_NAME="myAgentMI"
export ACR_NAME="myacr"
export AGENT_IMAGE_NAME="azdo-agent"
export AGENT_IMAGE_TAG="latest"
export KEYVAULT_NAME="myKeyVault"
export KEYVAULT_SECRET_NAME="MySecret"
export AZP_URL="https://dev.azure.com/myOrg"
export AZP_POOL="MyPool"
export ACI_NAME="my-agent-aci"
export ACA_ENV_NAME="myEnv"
export ACA_APP_NAME="my-agent-app"
export ADO_SERVICE_ID="499b84ac-1321-427f-aa17-267ca6975798"

az account set --subscription "$SUBSCRIPTION_ID"
export ACR_LOGIN_SERVER="${ACR_NAME}.azurecr.io"
export AGENT_IMAGE="${ACR_LOGIN_SERVER}/${AGENT_IMAGE_NAME}:${AGENT_IMAGE_TAG}"
```

Update the variable values to match your environment, then continue with the numbered steps.

1. Create and Configure the Managed Identity

    ```bash
    az identity create \
      --resource-group "$RG_NAME" \
      --name "$IDENTITY_NAME" \
      --location "$LOCATION"

    export UAMI_ID=$(az identity show --resource-group "$RG_NAME" --name "$IDENTITY_NAME" --query id -o tsv)
    export MI_CLIENT_ID=$(az identity show --resource-group "$RG_NAME" --name "$IDENTITY_NAME" --query clientId -o tsv)
    export MI_PRINCIPAL_ID=$(az identity show --resource-group "$RG_NAME" --name "$IDENTITY_NAME" --query principalId -o tsv)
    ```

    Grant the identity access to dependent services without hardcoding resource IDs:

    ```bash
    export ACR_ID=$(az acr show --name "$ACR_NAME" --resource-group "$RG_NAME" --query id -o tsv)
    az role assignment create --assignee "$MI_CLIENT_ID" --role AcrPull --scope "$ACR_ID"

    az keyvault set-policy \
      --name "$KEYVAULT_NAME" \
      --resource-group "$RG_NAME" \
      --object-id "$MI_PRINCIPAL_ID" \
      --secret-permissions get
    ```

    In Azure DevOps, invite the managed identity user by referencing the same `$IDENTITY_NAME`. Assign the Basic license and agent-pool permissions, ensuring the identity lives in the same Azure AD tenant as the organization.

2. Build the DevOps Agent Docker Image

    ```dockerfile
    FROM ubuntu:22.04
    RUN apt-get update && apt-get install -y curl git jq libicu70 \
      && curl -sL https://aka.ms/InstallAzureCLIDeb | bash
    WORKDIR /azp
    COPY ./start.sh /azp/start.sh
    RUN chmod +x /azp/start.sh
    RUN useradd -m agent && chown -R agent:agent /azp /home/agent
    USER agent
    ENTRYPOINT ["./start.sh"]
    ```

    Build and push the image by reusing the earlier variables:

    ```bash
    docker build -t "$AGENT_IMAGE" .
    docker push "$AGENT_IMAGE"
    ```

    If you rely on a public registry, skip the AcrPull assignment and registry references.

3. Agent Entrypoint: Authenticate with the Managed Identity

    Obtain an Azure DevOps token with the managed identity instead of embedding a PAT.

    - For Azure Container Instances (IMDS):

        ```bash
        az login --identity --allow-no-subscriptions
        token=$(az account get-access-token --resource "$ADO_SERVICE_ID" --query accessToken -o tsv)
        ```

    - For Azure Container Apps (IDENTITY_ENDPOINT):

        ```bash
        resp=$(curl -s -H "X-IDENTITY-HEADER: $IDENTITY_HEADER" "${IDENTITY_ENDPOINT}?resource=${ADO_SERVICE_ID}&api-version=2019-08-01")
        token=$(echo "$resp" | jq -r '.access_token')
        ```

    Configure the agent with the token treated as a dynamic PAT:

    ```bash
    ./config.sh --unattended \
      --agent "${AZP_AGENT_NAME:-$(hostname)}" \
      --url "$AZP_URL" \
      --auth pat --token "$token" \
      --pool "$AZP_POOL"
    ```

    `config.sh` chains into `run.sh`, so the agent immediately begins listening once configuration succeeds.

4. Deploy to Azure Container Instance (ACI)

    ```bash
    az container create \
      --resource-group "$RG_NAME" \
      --name "$ACI_NAME" \
      --image "$AGENT_IMAGE" \
      --assign-identity "$UAMI_ID" \
      --restart-policy OnFailure \
      --environment-variables AZP_URL="$AZP_URL" AZP_POOL="$AZP_POOL"
    ```

    Use `--registry-login-server`, `--registry-username`, and `--registry-password` only when you are not leveraging the managed identity for AcrPull. Confirm the deployment with `az container show --resource-group "$RG_NAME" --name "$ACI_NAME"` and inspect the `.identity` block to verify the attachment.

5. Deploy to Azure Container Apps (ACA)

    ```bash
    az containerapp env create \
      --name "$ACA_ENV_NAME" \
      --resource-group "$RG_NAME" \
      --location "$LOCATION"

    az containerapp create \
      --name "$ACA_APP_NAME" \
      --resource-group "$RG_NAME" \
      --environment "$ACA_ENV_NAME" \
      --image "$AGENT_IMAGE" \
      --registry-server "$ACR_LOGIN_SERVER" \
      --user-assigned "$UAMI_ID" \
      --registry-identity "$UAMI_ID"
    ```

    If the container image is public, omit the registry arguments. Container Apps automatically injects `IDENTITY_ENDPOINT` and `IDENTITY_HEADER`, which the earlier start script already understands.

6. Validate the Agent and Key Vault Access

    Confirm the Azure DevOps agent registration without typing URLs multiple times:

    ```bash
    az devops login --organization "$AZP_URL" <<<"$token"
    az pipelines agent list --pool "$AZP_POOL" --organization "$AZP_URL"
    ```

    Test Key Vault access inside the agent context:

    ```bash
    az keyvault secret show --vault-name "$KEYVAULT_NAME" --name "$KEYVAULT_SECRET_NAME"

    # ACI IMDS example
    KV_TOKEN=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net' -H Metadata:true | jq -r '.access_token')
    curl -H "Authorization: Bearer $KV_TOKEN" "https://${KEYVAULT_NAME}.vault.azure.net/secrets/${KEYVAULT_SECRET_NAME}?api-version=7.4"
    ```

    Use the same `IDENTITY_ENDPOINT` flow from step 3 when running on Container Apps. Successful secret retrieval confirms both the AcrPull and Key Vault permissions granted to the managed identity.

## Results
## Summary
## Related Information
