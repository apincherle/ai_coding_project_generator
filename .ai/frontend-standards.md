# Frontend Engineering Standards

Apply this file to browser applications and full-stack frameworks that render user interfaces.

## Component design

- Keep components focused on presentation and user interaction.
- Move domain decisions into named services, policies or pure functions rather than render bodies.
- Use custom hooks for reusable stateful behaviour; use plain functions for deterministic transformations.
- Prefer composition over large configurable components with many boolean props.
- Avoid generic `helpers.ts`, `utils.ts` and `common.ts` dumping grounds. Use responsibility-based names.
- Keep state as local as practical. Introduce shared/global state only for genuine cross-cutting ownership.
- Derive values during rendering where possible; do not use effects for calculations or event handling.
- Make loading, empty, error, partial and offline states explicit.

## Accessibility and user experience

- Use semantic HTML before ARIA.
- Support keyboard navigation, visible focus and logical focus management.
- Associate form labels, instructions and validation errors correctly.
- Meet the organisation's WCAG target and test critical journeys with automated and manual checks.
- Respect reduced-motion, contrast, zoom, reflow and screen-reader requirements.
- Preserve accessibility through loading, modal, notification and route-transition behaviour.

## Browser security and privacy

- Treat URL, storage, postMessage, API, third-party script and rendered content as untrusted.
- Do not render unsanitised HTML. Avoid `dangerouslySetInnerHTML`; document and test any approved exception.
- Do not store long-lived bearer tokens or sensitive data in browser storage without an approved threat model.
- Enforce authorization on the server; UI visibility is not an authorization control.
- Apply Content Security Policy, secure cookies and cross-origin policy at the hosting/server boundary.
- Minimise analytics and telemetry data; do not log sensitive form values.
- Review npm lifecycle scripts, package provenance, lockfile changes and browser supply-chain risk.

## Testing

- Test user-visible behaviour and accessible roles rather than component implementation details.
- Use network-level interception such as MSW for API behaviour; avoid mocking every internal module.
- Every test contains a meaningful outcome assertion. Mock-call verification alone is insufficient.
- Cover keyboard interaction, validation, loading, empty, error and authorization-aware states.
- Use browser tests for critical journeys and integration boundaries.
- Add visual regression tests only where layout regressions carry material risk; keep them deterministic and reviewed.
