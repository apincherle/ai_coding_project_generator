# AI Governance

Classify work as low, medium, or high risk. Low: documentation and local refactoring. Medium: feature code,
dependencies, data access. High: authentication, authorization, cryptography, money, safety, regulated data,
production operations.

High-risk work requires a domain owner and security review. Record model/tool, purpose, human owner, changed
files, validation evidence, and exceptions in the pull request. AI never approves its own output.
Retain prompts only where policy permits; never use prompt logs as a secret store.
