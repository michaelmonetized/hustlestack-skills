# sr-* Skills Index

Quick reference for citing skills in reviews. Load the full skill when deeper guidance needed.

---

## Backend

### sr-convex-expert
**Domain:** Convex database, queries, mutations, actions, schemas
**Key Rules:**
- Use `_id` not `id`, `_creationTime` not `createdAt`
- Index every query filter field
- Use `--cmd` wrapper for Next.js deploys
- Use internal functions for sensitive logic
- New fields must be `v.optional()`

**Cite when:** Schema issues, query patterns, auth in mutations, deployment

### sr-next-clerk-expert
**Domain:** Clerk authentication in Next.js
**Key Rules:**
- Use `proxy.ts` not `middleware.ts` (Next.js 16+)
- Never mix client/server auth patterns
- Set all 4 redirect env vars
- Use `auth()` server-side, `useAuth()` client-side

**Cite when:** Auth errors, 500s, redirect loops, protected routes

---

## Frontend

### sr-react-design-expert
**Domain:** UI/UX, component design, styling
**Key Rules:**
- Avoid generic AI aesthetics
- Every interactive element needs hover/active states
- Use design system tokens, not arbitrary values
- Prefer composition over configuration

**Cite when:** Design quality, component structure, styling issues

### sr-native-engineer
**Domain:** React Native, Expo, NativeWind
**Key Rules:**
- Use NativeWind for styling
- Platform-specific code in `.ios.tsx`/`.android.tsx`
- Test on both platforms before merge

**Cite when:** Mobile code, cross-platform issues

### sr-native-architect
**Domain:** Mobile app architecture
**Key Rules:**
- Offline-first for data-heavy apps
- Proper navigation patterns (stack, tab, drawer)
- State management decisions

**Cite when:** App structure, navigation, state

---

## Apple Platforms

### sr-swift-architect
**Domain:** macOS/iOS architecture decisions
**Key Rules:**
- AppKit for complex macOS, UIKit for iOS
- SwiftUI for simple UI only
- Document-based app patterns

**Cite when:** Architecture decisions, framework choice

### sr-swift-engineer
**Domain:** Swift implementation
**Key Rules:**
- Prefer native frameworks over SwiftUI
- Proper memory management
- AppKit/UIKit patterns

**Cite when:** Implementation issues, Swift code quality

---

## Process

### sr-production-engineer
**Domain:** Dev workflow, PRs, deploys
**Key Rules:**
- Update TODO.md before work
- Update CHANGELOG.md after
- Use Graphite for stacked PRs
- Run `vl` to verify Vercel deploys

**Cite when:** Workflow issues, missing docs, deploy problems

### sr-engineering-director
**Domain:** Multi-agent orchestration
**Key Rules:**
- Phase builds into deliverables
- Verify each phase before proceeding
- Single agent + full context > many agents

**Cite when:** Project structure, delegation issues

### sr-software-architect
**Domain:** Architecture documentation
**Key Rules:**
- Architecture before code
- Document decisions in ARCHITECTURE.md
- Contracts for cross-boundary interfaces

**Cite when:** Missing architecture docs, unclear boundaries

---

## Standards

### STANDARDS.md (Global)
**Key Rules:**
- Phosphor Icons for all platforms
- Document overrides in project

**Cite when:** Icon library, global patterns

### TECH-REQ.md
**Location:** sr-engineering-director/TECH-REQ.md
**Key Rules:**
- Error boundaries for async components
- Loading states for all data fetching
- Auth on all mutations

**Cite when:** Technical requirements, patterns
