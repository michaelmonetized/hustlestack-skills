# sr-* Skills Index

Quick reference for citing best practices in code reviews.

---

## Architecture & Planning

### sr-software-architect
**Domain:** System design, architecture decisions, delegation
**Cite when:** Wrong abstractions, coupling issues, missing architecture docs
**Key patterns:**
- Read architecture before writing code
- Understand the system context
- Document decisions in PLAN.md

### sr-engineering-director
**Domain:** Multi-agent orchestration, phased builds, verification
**Cite when:** Complex features need breakdown, sub-agent coordination, functional verification
**Key files:**
- `TECH-REQ.md` — Full stack specification
- `CODING-STANDARDS.md` — Code conventions
- `CONTRACTS-TEMPLATE.md` — API contracts

---

## Backend

### sr-convex-expert
**Domain:** Convex schema, queries, mutations, actions, deployment
**Cite when:** Schema issues, auth patterns, deployment problems
**Key rules:**
- Use `_id` not `id` for document references
- Use `_creationTime` not `createdAt` (built-in)
- Index every query filter field
- Use `v.optional()` for new fields
- Use `--cmd` wrapper for Next.js deploys

### sr-next-clerk-expert
**Domain:** Clerk auth, middleware, protected routes, user sync
**Cite when:** Auth flow issues, missing middleware, user sync patterns
**Key patterns:**
- Middleware for route protection
- UserSyncProvider for Convex sync
- Clerk JWT validation in Convex

---

## Frontend

### sr-react-design-expert
**Domain:** UI/UX, component design, visual quality
**Cite when:** Generic AI aesthetics, poor UX, missing states
**Key principles:**
- Bold, distinctive design choices
- All interactive states (hover, active, disabled)
- Consistent spacing and typography
- No default shadcn without customization

### sr-production-engineer
**Domain:** 12-step dev workflow, PRs, deploys, verification
**Cite when:** Missing CHANGELOG, no TODO tracking, deploy issues
**Workflow:**
1. Update TODO.md
2. Implement
3. Update CHANGELOG.md
4. Create PR with Graphite
5. Verify deploy

---

## Mobile / Native

### sr-native-architect
**Domain:** React Native / Expo architecture, navigation, state
**Cite when:** Mobile architecture decisions, platform-specific patterns
**Key patterns:**
- Expo Router for navigation
- NativeWind for styling
- Platform-specific code organization

### sr-native-engineer
**Domain:** React Native implementation, components, performance
**Cite when:** Mobile UI issues, performance problems, platform bugs
**Key patterns:**
- FlatList for long lists
- Memoization for performance
- Platform-specific styling

### sr-swift-architect
**Domain:** iOS/macOS architecture, SwiftUI, data flow
**Cite when:** Swift architecture decisions, SwiftUI patterns
**Key patterns:**
- MVVM with Observable
- Dependency injection
- Async/await patterns

### sr-swift-engineer
**Domain:** Swift implementation, UI components, platform APIs
**Cite when:** Swift code issues, UIKit/SwiftUI problems
**Key patterns:**
- SwiftUI view composition
- Combine for reactivity
- Platform API integration

---

## Global Standards

### STANDARDS.md (root)
**Domain:** Cross-skill standards
**Current standards:**
- **Icons:** Phosphor Icons for all platforms
  - Web: `@phosphor-icons/react`
  - React Native: `phosphor-react-native`
  - Swift: `phosphor-swift`

---

## Citation Format

Use brackets with skill name:

```
[sr-convex-expert] Use _creationTime instead of custom createdAt field
[sr-production-engineer] Missing CHANGELOG entry
[sr-react-design-expert] Button needs hover/active states
[TECH-REQ.md#auth] Auth check required in mutation
[CODING-STANDARDS.md] Use explicit return types on functions
```

For file-specific references:
```
[sr-engineering-director/TECH-REQ.md] Full stack specification
[sr-engineering-director/CODING-STANDARDS.md] Code conventions
```
