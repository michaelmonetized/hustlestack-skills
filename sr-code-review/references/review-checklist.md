# Code Review Checklist

Use this checklist for systematic reviews. Not every item applies to every review.

---

## 1. Correctness

### Logic
- [ ] Does the code do what it's supposed to?
- [ ] Are edge cases handled?
- [ ] Are error conditions handled gracefully?
- [ ] Is the logic readable and followable?

### Data
- [ ] Are data transformations correct?
- [ ] Are null/undefined cases handled?
- [ ] Are array bounds checked?
- [ ] Are type coercions explicit?

---

## 2. Architecture

### Structure
- [ ] Does it fit the project's architecture?
- [ ] Is it in the right layer? (UI, business logic, data)
- [ ] Are dependencies pointing in the right direction?
- [ ] Is it appropriately coupled/decoupled?

### Abstractions
- [ ] Are abstractions at the right level?
- [ ] Is there unnecessary abstraction?
- [ ] Are there missing abstractions?
- [ ] Do names reflect the abstraction?

### Patterns
- [ ] Does it follow established patterns in the codebase?
- [ ] If introducing a new pattern, is it justified?
- [ ] Are sr-* skill patterns followed?

---

## 3. Convex-Specific (if applicable)

### Schema
- [ ] All query filter fields indexed?
- [ ] Using `_id` not `id`?
- [ ] Using `_creationTime` not custom `createdAt`?
- [ ] New fields are `v.optional()`?
- [ ] Field types match existing data?

### Functions
- [ ] Queries don't mutate state?
- [ ] Mutations check auth when needed?
- [ ] Actions used for external APIs?
- [ ] Internal functions for sensitive logic?

### Deployment
- [ ] `--cmd` wrapper in build script?
- [ ] Migrations for breaking changes?

---

## 4. Next.js-Specific (if applicable)

### Routing
- [ ] Correct use of app router patterns?
- [ ] Route groups used appropriately?
- [ ] Dynamic routes have proper validation?

### Auth (Clerk)
- [ ] Protected routes use `proxy.ts`?
- [ ] Client components use `useAuth()`?
- [ ] Server components use `auth()`?
- [ ] Redirect URLs configured?

### Performance
- [ ] Unnecessary client components?
- [ ] Missing Suspense boundaries?
- [ ] Large bundles could be lazy loaded?

---

## 5. Security

### Authentication
- [ ] Auth checks on protected endpoints?
- [ ] Auth state verified server-side?
- [ ] No auth bypass possible?

### Authorization
- [ ] User can only access their data?
- [ ] Role checks where needed?
- [ ] Ownership verified in mutations?

### Input
- [ ] User input validated?
- [ ] SQL/NoSQL injection prevented?
- [ ] XSS prevented?

### Secrets
- [ ] No hardcoded API keys?
- [ ] No secrets in client code?
- [ ] Env vars used for config?

---

## 6. Performance

### Database
- [ ] No N+1 queries?
- [ ] Indexes on filtered/sorted fields?
- [ ] Pagination for lists?
- [ ] Unnecessary data not fetched?

### Frontend
- [ ] No unnecessary re-renders?
- [ ] Expensive computations memoized?
- [ ] Images optimized?
- [ ] Large dependencies avoided?

### General
- [ ] No obvious bottlenecks?
- [ ] Async operations where appropriate?

---

## 7. Maintainability

### Naming
- [ ] Variables/functions clearly named?
- [ ] Names match behavior?
- [ ] Consistent naming conventions?

### Comments
- [ ] Complex logic explained?
- [ ] No redundant comments?
- [ ] TODOs have context/tickets?

### Structure
- [ ] Functions are focused (single responsibility)?
- [ ] Files aren't too large?
- [ ] Related code grouped together?

### DRY
- [ ] No copy-paste duplication?
- [ ] Reusable code extracted?
- [ ] But not over-abstracted?

---

## 8. Documentation

### Code
- [ ] Public APIs documented?
- [ ] Complex types explained?
- [ ] Non-obvious decisions commented?

### Project
- [ ] README updated if needed?
- [ ] CHANGELOG entry for user-facing changes?
- [ ] TODO.md updated?
- [ ] PLAN.md aligned with changes?

---

## 9. Testing (if tests exist)

### Coverage
- [ ] Happy path tested?
- [ ] Edge cases tested?
- [ ] Error cases tested?

### Quality
- [ ] Tests are focused?
- [ ] Tests are readable?
- [ ] Tests don't test implementation details?

---

## 10. Style

### Formatting
- [ ] Consistent with codebase?
- [ ] No obvious linting issues?

### Conventions
- [ ] Import ordering consistent?
- [ ] File structure consistent?
- [ ] TypeScript strictness maintained?

---

## Review Output Template

```markdown
## Review: [PR Title / Component Name]

### Critical (Must Fix)
- [ ] Issue with citation

### Should Fix
- [ ] Issue with citation

### Suggestions
- [ ] Nice-to-have improvement

### Nits
- [ ] Minor style/naming thing

### Questions
- [ ] Clarification needed

### Good Stuff 👍
- Positive observations
```
