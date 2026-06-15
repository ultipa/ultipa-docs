# Security

## Encryption at Rest

Ultipa supports transparent file-level encryption for data stored on disk using AES-256-CTR or SM4-CTR algorithms. When enabled, all data files are encrypted with less than 5% performance overhead for AES.

### Configuration

Add the following section to both `shard-server.config` and `meta-server.config`:

```ini
[Encryption]
enabled = true
algorithm = AES
key_file = /path/to/encryption.key
```

| <div table-width="15">Parameter</div> | Default | Description |
| -- | -- | -- |
| `enabled` | `false` | Enables or disables encryption at rest. |
| `algorithm` | `AES` | Encryption algorithm: `AES` (AES-256-CTR) or `SM4` (SM4-CTR). |
| `key_file` | (empty) | Path to the encryption key file. Must be identical across all nodes. |

> Encryption at rest is only available for newly created databases. Existing unencrypted data requires export and re-import with encryption enabled.

## SM/TLS Encryption

Ultipa supports Chinese national standard SM2/SM3/SM4 TLS ciphers for compliance with domestic regulations. The system auto-detects whether to use standard RSA or SM2 certificates based on the certificate files provided.

### Configuration

Configure TLS in the server config file:

```ini
[TLS]
enabled = true
cert_file = /path/to/cert.pem
key_file = /path/to/key.pem
ca_file = /path/to/ca.pem
```

For SM2 certificates, use SM2 certificate and key files in the same configuration. The server automatically detects and uses the appropriate cipher suite.

## SSO/OIDC Authentication

Ultipa supports external identity provider (IdP) authentication via JWT tokens, enabling single sign-on with providers such as Keycloak, Auth0, Okta, and Azure AD.

### Configuration

Add the following section to `name-server.config`:

```ini
[SSO]
enabled = true
issuer = https://your-idp.com/realms/ultipa
jwks_uri = https://your-idp.com/realms/ultipa/protocol/openid-connect/certs
client_id = ultipa-client
username_claim = preferred_username
clock_skew_seconds = 30
password_fallback = true
```

| <div table-width="22">Parameter</div> | Default | Description |
| -- | -- | -- |
| `enabled` | `false` | Enables or disables SSO authentication. |
| `issuer` | (empty) | Expected JWT issuer URL. |
| `jwks_uri` | (empty) | URL of the JWKS endpoint for public key retrieval. |
| `client_id` | (empty) | Expected audience (client ID) in the JWT token. |
| `username_claim` | `preferred_username` | JWT claim field used as the Ultipa username. |
| `clock_skew_seconds` | `30` | Allowed clock skew for token validation. |
| `password_fallback` | `true` | When enabled, allows password authentication if JWT is not provided. |

### Authentication Flow

1. The client obtains a JWT token from the identity provider.
2. The client sends the JWT token to Ultipa in the authentication header.
3. Ultipa validates the token signature using cached JWKS public keys.
4. Ultipa extracts the username from the configured claim field.
5. If the user does not exist in Ultipa, it is automatically created (if auto-creation is enabled).

## Property-Level Security

Property-level access control supports two behaviors for restricted properties:

- **DENY**: Returns an error when the user attempts to access the property.
- **NO_GRANT**: Returns `null` for the property value without raising an error.

This allows fine-grained control over which properties are visible to different users and roles.
