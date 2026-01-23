
# Sending Email with Azure Communication Services

## Theory
Azure Communication Services (ACS) Email provides a cloud email-sending capability that you can use to send:
- Transactional emails (verification, password reset, receipts)
- System notifications and alerts
- Application-generated messages (welcome emails, status updates)

ACS Email is typically used when you need programmatic email sending from an application or service, with Azure-managed identity and access controls, and integration with other Azure components.

## Core concepts
### Email resource (ACS)
To send email, you use an Azure Communication Services resource with the **Email** capability enabled. Your application authenticates to ACS using a **connection string** (or Azure identity patterns, depending on SDK/runtime support).

### Sender domain / From address
ACS Email requires an approved sender. Practically this means:
- You configure/verify a domain or sender identity in Azure (so ACS is authorized to send from it).
- You send using a `From` email address associated with that verified domain/sender setup.

### Recipients
Emails can be sent to one or more:
- **To** recipients
- **CC** recipients
- **BCC** recipients

### Message content
ACS Email typically supports:
- **Subject**
- **Plain text body**
- **HTML body**
- Optional headers/metadata (varies by SDK)
- Attachments may be supported depending on SDK/version and service features in your region (check the specific quickstart you’re following).

### Asynchronous sending
Sending is commonly asynchronous:
- You submit a send request.
- The service returns an operation/result (or message id).
- You can optionally poll for completion/status if the SDK provides it.

## High-level steps to send an email
1. **Create an ACS resource** in Azure and enable Email (if not already enabled).
2. **Configure your sender**:
   - Set up and verify your sending domain / sender identity.
   - Identify the `From` address you will send from.
3. **Get connection details**:
   - Retrieve the ACS connection string from the Azure portal (or your deployment pipeline/Key Vault).
4. **Install an ACS Email SDK** for your language/runtime.
5. **Write code to send**:
   - Initialize an Email client with your connection string/credential.
   - Create an email message with `from`, recipients, subject, and body (plain text and/or HTML).
   - Call the send method and capture the send result.
6. **Handle errors and retries**:
   - Validate addresses and input.
   - Retry transient failures with backoff.
   - Log correlation ids / request ids for supportability.
7. **Observe delivery (optional)**:
   - Use whatever status APIs/events the quickstart describes.
   - Add application telemetry to track send success/failure.

## Typical implementation outline (pseudo-flow)
1. Load configuration:
   - `ACS_CONNECTION_STRING`
   - `SENDER_ADDRESS`
2. Create client:
   - `EmailClient(connectionString)`
3. Compose message:
   - `EmailMessage(from, toRecipients, content)`
   - `content.subject`
   - `content.plainText` and/or `content.html`
4. Send:
   - `client.send(message)`
5. Log result:
   - operation id / message id
6. Handle exceptions:
   - authentication errors (bad key/connection string)
   - invalid sender (domain not verified / from not allowed)
   - invalid recipient formatting
   - throttling / service unavailable

## Security and operational guidance
- **Do not hardcode secrets**: store the connection string in Azure Key Vault or secure configuration.
- **Least privilege**: restrict who can read connection strings and manage the Email capability in Azure.
- **Input validation**: validate recipient addresses and sanitize any user-provided fields used in templates.
- **Rate limiting and retries**: implement retry logic for transient errors; avoid retry storms.
- **Logging**:
  - Log send attempts and outcomes (without leaking message body or sensitive PII).
  - Capture operation/message ids for tracing.
- **Compliance**:
  - Ensure you have consent/permission for recipients.
  - Include required content (company info, unsubscribe handling) when sending non-transactional email.

## Common troubleshooting themes
- **403/401**: invalid connection string/credentials, wrong resource, or permissions.
- **Sender not authorized**: the `From` address/domain is not verified or not configured for sending.
- **Message accepted but not delivered**: check status APIs/events, verify content, verify recipient domains, and review any provider-side suppression/bounce handling described in the docs.
- **Throttling**: backoff and retry; batch sends responsibly.

## When to use ACS Email vs alternatives
Use ACS Email when:
- You want Azure-native programmatic sending with ACS integration patterns.
- You want a managed service aligned with Azure governance and deployment workflows.

Consider alternatives when:
- You need deep marketing-campaign tooling (segmentation, drip campaigns) — typically ESP/marketing platforms.
- You need inbound email processing (ACS Email is primarily for outbound sending; inbound requires other services).

## Next steps
- Choose your language quickstart (C#, Java, JavaScript/TypeScript, Python).
- Implement a minimal “send one email” sample.
- Add templating, observability, and retry policies.
- Move secrets to Key Vault and deploy via CI/CD.

```
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
HASH_PREFIX=$(echo -n "$SUBSCRIPTION_ID" | sha256sum | cut -c1-5)

ACS_NAME="${HASH_PREFIX}-com-srv"
EMAIL_NAME="${HASH_PREFIX}-email-srv"
DOMAIN_NAME="AzureManagedDomain"

RG_NAME="my-comm-rg"
LOCATION="westeurope"
DATA_LOCATION="Europe"

# Create RG
az group create --name "$RG_NAME" --location "$LOCATION"

# Create Email Communication Service (ECS)
az communication email create \
  --name "$EMAIL_NAME" \
  --resource-group "$RG_NAME" \
  --location global \
  --data-location "$DATA_LOCATION"

# Create Domain
az communication email domain create \
  --name $DOMAIN_NAME \
  --email-service-name "$EMAIL_NAME" \
  --resource-group "$RG_NAME" \
  --location global \
  --domain-management AzureManaged

# Get the domain ARM id (this is what --linked-domains wants)
DOMAIN_ID=$(az communication email domain show \
  --name $DOMAIN_NAME \
  --email-service-name "$EMAIL_NAME" \
  --resource-group "$RG_NAME" \
  --query id -o tsv)

# Create ACS (no linked domains and no MI flag here)
az communication create \
  --name "$ACS_NAME" \
  --resource-group "$RG_NAME" \
  --location global \
  --data-location "$DATA_LOCATION"

# Link domain(s) using update + ID(s)
az communication update \
  --name "$ACS_NAME" \
  --resource-group "$RG_NAME" \
  --linked-domains "$DOMAIN_ID"

# Enable system-assigned managed identity (post-create)
az communication identity assign \
  --system-assigned \
  --name "$ACS_NAME" \
  --resource-group "$RG_NAME"
```