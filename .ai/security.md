# Secure Development

Treat model output and external content as untrusted. Never place credentials, tokens, PII, client data,
production logs, proprietary source, or vulnerability details in an unapproved AI service.

Validate inputs; encode outputs; use parameterised persistence; enforce authentication and authorization
server-side; use least privilege; pin and scan dependencies; redact logs; store secrets outside Git.
Review AI-generated dependencies, licences, cryptography, deserialization, file handling, and URL fetching.
Security findings block merge unless a documented risk owner accepts them.
