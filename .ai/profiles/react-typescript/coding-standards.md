# Coding Standards - React TypeScript

- Enable strict TypeScript and validate data received from APIs, storage, URLs and messages.
- Use function components and hooks. Keep components focused and composable.
- Keep domain logic out of render bodies; use pure functions, named policies or application services.
- Use custom hooks for reusable stateful behaviour and plain functions for deterministic transformations.
- Do not create interfaces for every component. Use types for meaningful props, domain contracts and adapters.
- Keep state local; introduce context or external stores only for genuine shared ownership.
- Avoid unnecessary effects. Never use an effect when derivation or an event handler expresses the behaviour.
- Use semantic HTML, accessible names and keyboard-operable interactions.
- Avoid generic helper files, index-barrel cycles and unsafe `dangerouslySetInnerHTML`.
- Model loading, empty, error and partial states explicitly.
