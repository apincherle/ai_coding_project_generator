# Testing Standard - React TypeScript

Use Vitest, React Testing Library, jest-dom and MSW. Use Playwright for critical browser journeys.
Test through accessible roles, names and user-visible behaviour rather than component internals.
Mock the network/browser boundary with MSW or approved adapters; avoid mocking every child component or hook.
Every test must contain a meaningful outcome assertion such as visibility, accessible state, navigation or rendered data.
Mock-call verification alone is insufficient.
Cover keyboard use, validation, loading, empty, error and authorization-aware states.
Use axe-core as an aid, not a replacement for manual accessibility testing.
