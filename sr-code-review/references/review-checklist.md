# Code Review Checklist

Comprehensive checklist organized by category. Not every item applies to every review.

---

## Table of Contents
1. [Correctness](#correctness)
2. [Security](#security)
3. [Architecture](#architecture)
4. [Convex Backend](#convex-backend)
5. [Frontend / React](#frontend--react)
6. [Performance](#performance)
7. [Error Handling](#error-handling)
8. [Documentation](#documentation)
9. [Testing](#testing)
10. [Git / PR Hygiene](#git--pr-hygiene)

---

## Correctness

### Logic
- [ ] Code does what the PR/issue description says
- [ ] Edge cases handled (empty arrays, null values, zero)
- [ ] Off-by-one errors checked
- [ ] Race conditions considered for async code
- [ ] State mutations don't cause infinite loops

### Types
- [ ] No `any` types without justification
- [ ] Nullable values checked before use
- [ ] Type assertions (`as X`) are justified
- [ ] Generic types used appropriately

---

## Security

### Authentication
- [ ] All mutations verify `ctx.auth.getUserIdentity()`
- [ ] Null identity handled (throw or return early)
- [ ] Ownership verified before modifying user data
- [ ] No auth bypass via optional parameters

### Authorization
- [ ] Role checks where required
- [ ] Can't escalate own privileges
- [ ] Admin-only routes protected
- [ ] Team/org membership verified

### Data Validation
- [ ] User input validated with Zod/Convex validators
- [ ] File uploads checked (type, size)
- [ ] URLs validated before fetch
- [ ] No SQL/NoSQL injection vectors

### Secrets
- [ ] No API keys in code
- [ ] No tokens in client-side code
- [ ] Secrets in env vars or Convex dashboard
- [ ] `.env` files in `.gitignore`

---

## Architecture

### System Fit
- [ ] Follows patterns established in codebase
- [ ] Matches architecture in PLAN.md/ARCHITECTURE.md
- [ ] Right level of abstraction
- [ ] No unnecessary coupling between modules

### Convex Schema
- [ ] Schema matches data requirements
- [ ] Relationships use `v.id("table")` not strings
- [ ] Denormalization justified for read performance
- [ ] No circular dependencies

### File Organization
- [ ] Files in correct directories
- [ ] Feature folders for complex features
- [ ] Shared code in appropriate location
- [ ] No orphaned/unused files

---

## Convex Backend

### Schema [sr-convex-expert]
- [ ] Uses `_id` not custom `id` field
- [ ] No `createdAt` field (use `_creationTime`)
- [ ] `updatedAt` defined only if needed
- [ ] New fields are `v.optional()`
- [ ] All query filter fields indexed

### Queries
- [ ] Uses `.withIndex()` for filtered queries
- [ ] Pagination for large result sets
- [ ] No `.collect()` without limits on large tables
- [ ] Returns minimal data needed

### Mutations
- [ ] Auth check at top of handler
- [ ] Ownership verified for user data
- [ ] Atomic operations where needed
- [ ] No external API calls (use actions)

### Actions
- [ ] Used only for external APIs/side effects
- [ ] Timeouts considered for long operations
- [ ] Errors handled and logged
- [ ] Retries for transient failures

### HTTP Actions
- [ ] Webhook signatures verified
- [ ] Request body validated
- [ ] Appropriate status codes returned
- [ ] CORS configured if needed

---

## Frontend / React

### Components [sr-react-design-expert]
- [ ] All interactive states (hover, active, disabled, loading)
- [ ] Loading states for async data
- [ ] Error states with recovery options
- [ ] Empty states for lists
- [ ] Accessible (keyboard, screen reader)

### Hooks
- [ ] Dependencies array correct in useEffect
- [ ] No infinite re-render loops
- [ ] Cleanup functions for subscriptions
- [ ] useMemo/useCallback where beneficial

### Data Fetching
- [ ] Uses Convex `useQuery` for real-time data
- [ ] Loading states while data undefined
- [ ] Error boundaries for component errors
- [ ] No fetch in useEffect for Convex data

### Forms
- [ ] Validation before submit
- [ ] Error messages displayed
- [ ] Loading state during submit
- [ ] Success feedback to user
- [ ] Prevents double submission

---

## Performance

### Queries
- [ ] Indexed queries (no full table scans)
- [ ] Pagination for large lists
- [ ] No N+1 query patterns
- [ ] Minimal data fetched (select fields)

### Rendering
- [ ] No unnecessary re-renders
- [ ] Large lists use virtualization
- [ ] Images optimized and lazy-loaded
- [ ] Bundle size considered

### Network
- [ ] No redundant API calls
- [ ] Debounced search/filter inputs
- [ ] Optimistic updates where appropriate
- [ ] Proper caching strategy

---

## Error Handling

### Backend
- [ ] Try/catch for external calls
- [ ] Meaningful error messages
- [ ] Errors don't leak sensitive data
- [ ] Logging for debugging

### Frontend
- [ ] Error boundaries catch render errors
- [ ] Network errors handled gracefully
- [ ] User-friendly error messages
- [ ] Retry options where appropriate

---

## Documentation

### Code Comments
- [ ] Complex logic explained
- [ ] "Why" comments for non-obvious decisions
- [ ] No commented-out code
- [ ] JSDoc for public APIs

### Project Docs
- [ ] README updated if setup changed
- [ ] CHANGELOG entry for user-facing changes
- [ ] PLAN.md updated if architecture changed
- [ ] API docs for new endpoints

---

## Testing

### Unit Tests
- [ ] Critical business logic tested
- [ ] Edge cases covered
- [ ] Mocks appropriate (not excessive)

### Integration Tests
- [ ] Happy path works end-to-end
- [ ] Error paths handled
- [ ] Auth flows tested

---

## Git / PR Hygiene

### Commits
- [ ] Atomic commits (one logical change)
- [ ] Clear commit messages
- [ ] No "WIP" or "fix" only messages
- [ ] No committed secrets/credentials

### PR
- [ ] Description explains what and why
- [ ] Links to issue if applicable
- [ ] Reasonable size (< 500 lines ideal)
- [ ] CI passing
- [ ] No unrelated changes

### Branch
- [ ] Named descriptively (feat/, fix/, etc.)
- [ ] Up to date with main
- [ ] No merge commits (rebased)

---

## Quick Reject Criteria

Immediately request changes if any of these are present:

1. **Auth bypass** — Mutation modifies data without identity check
2. **Secrets in code** — API keys, tokens hardcoded
3. **Breaking schema** — Type change without migration
4. **No error handling** — Unhandled async/promises
5. **Injection risk** — Unvalidated user input in queries
