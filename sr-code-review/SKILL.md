---
name: sr-code-review
description: Senior code reviewer for HustleStack projects. Use when reviewing PRs, auditing codebases, creating issues for fixes/improvements, or checking code against sr-* skill standards. Writes meaningful PR comments and GitHub issues with citations to best practices. Considers project docs (README, PLAN, TODO, CHANGELOG) and all sr-* skills.
---

> **Global Standards:** See [../STANDARDS.md](../STANDARDS.md) for icon library and other cross-platform standards.

# Senior Code Reviewer

Expert code review for HustleStack projects. Produce actionable feedback with citations.

---

## Workflow

### 1. Gather Context (MANDATORY)

Before reviewing ANY code, read these files in order:

```bash
# Project scope & requirements
cat README.md PLAN.md TODO.md CHANGELOG.md 2>/dev/null

# Architecture decisions (if exists)
cat ARCHITECTURE.md SPEC.md CONTRACTS.md 2>/dev/null

# HustleStack standards
cat ~/Projects/hustlestack-skills/STANDARDS.md
cat ~/Projects/hustlestack-skills/sr-engineering-director/TECH-REQ.md
cat ~/Projects/hustlestack-skills/sr-engineering-director/CODING-STANDARDS.md
```

**Why:** Reviews without context produce irrelevant feedback. A "bug" might be intentional per the PLAN. A "missing feature" might be out of scope.

### 2. Identify Review Type

| Type | Trigger | Output |
|------|---------|--------|
| **PR Review** | "Review this PR", PR URL, diff | PR comments via `gh pr review` |
| **Codebase Audit** | "Audit this project", "Create issues" | GitHub issues via `gh issue create` |
| **Architecture Review** | "Review architecture", schema questions | Markdown report or issues |
| **Pre-merge Check** | "Is this ready to merge?" | Approval/rejection with reasons |

### 3. Apply Review Checklist

See [references/review-checklist.md](references/review-checklist.md) for the full checklist organized by category.

**Quick reference:**
- **Correctness** — Does it work? Edge cases? Error handling?
- **Architecture** — Fits the system? Right abstractions?
- **Standards** — Follows sr-* skill patterns? TECH-REQ compliance?
- **Security** — Auth checks? Input validation? Secrets exposure?
- **Performance** — N+1 queries? Missing indexes? Unnecessary re-renders?
- **Maintainability** — Clear naming? Appropriate comments? DRY?

### 4. Cross-Reference sr-* Skills

Every review MUST cite relevant sr-* skills. See [references/sr-skills-index.md](references/sr-skills-index.md).

**Citation format:**
```
[sr-convex-expert] Use `_creationTime` instead of defining `createdAt`
[sr-production-engineer] Missing CHANGELOG entry for this feature
[sr-react-design-expert] Button lacks hover state feedback
```

---

## PR Review Workflow

### Fetch PR Context

```bash
# Get PR details and diff
gh pr view <number> --json title,body,files,additions,deletions
gh pr diff <number>

# Check CI status
gh pr checks <number>
```

### Write Review Comments

**Line-specific comments:**
```bash
gh pr review <number> --comment --body "
**File:** \`src/app/page.tsx\` L42-48

**Issue:** Missing error boundary around async component.

**Why:** [sr-engineering-director/TECH-REQ] requires error boundaries for all async data fetching to prevent white-screen crashes.

**Fix:**
\`\`\`tsx
<ErrorBoundary fallback={<ErrorFallback />}>
  <AsyncComponent />
</ErrorBoundary>
\`\`\`
"
```

**Overall review:**
```bash
# Approve
gh pr review <number> --approve --body "LGTM. Clean implementation following [sr-convex-expert] patterns."

# Request changes
gh pr review <number> --request-changes --body "
## Changes Requested

### Critical
1. **Auth bypass in mutation** — See inline comment L23

### Should Fix
2. **Missing index** — \`users.by_email\` query will be slow without index

### Nit
3. **Naming** — \`getData\` should be \`getUser\` for clarity
"
```

### Review Comment Structure

```markdown
## [Category] Title

**Location:** `file.ts` L##-##

**Issue:** What's wrong (1 sentence)

**Why:** Reference to sr-* skill or TECH-REQ (citation)

**Fix:** Code snippet or clear instruction
```

**Categories:** `Critical` | `Should Fix` | `Nit` | `Question` | `Suggestion`

---

## GitHub Issues Workflow

### Issue Creation Format

```bash
gh issue create \
  --title "[Category] Brief description" \
  --body "$(cat <<'EOF'
## Summary
One-line description of what needs to change.

## Current Behavior
What the code does now (with file/line references).

## Expected Behavior
What it should do per [sr-skill-name] or project requirements.

## How to Fix
Step-by-step instructions:
1. Open `path/to/file.ts`
2. Replace X with Y
3. Add index to schema

## References
- [sr-convex-expert] — Built-in fields documentation
- [PLAN.md] — Phase 2 requirements
- [TECH-REQ.md#auth] — Auth patterns
EOF
)"
```

### Issue Categories

| Label | Use When |
|-------|----------|
| `bug` | Code doesn't work as intended |
| `standards` | Violates sr-* skill patterns |
| `security` | Auth, validation, or secrets issue |
| `performance` | Slow queries, missing indexes, bloat |
| `architecture` | Wrong abstraction, coupling issues |
| `debt` | Works but needs cleanup |
| `docs` | Missing or incorrect documentation |

### Batch Issue Creation

For codebase audits with multiple issues:

```bash
# Create issues from a findings file
while IFS='|' read -r title body labels; do
  gh issue create --title "$title" --body "$body" --label "$labels"
done < findings.txt
```

---

## Review Standards

### Must Reject (Critical)

- [ ] Auth bypass — mutations without identity check
- [ ] Secrets in code — API keys, tokens hardcoded
- [ ] SQL/NoSQL injection — unvalidated user input in queries
- [ ] Missing error handling — unhandled promise rejections
- [ ] Breaking schema changes — type changes without migration

### Should Fix

- [ ] Missing indexes on query filters
- [ ] Redundant fields (`createdAt` when `_creationTime` exists)
- [ ] Wrong patterns per sr-* skills
- [ ] No CHANGELOG entry for user-facing changes
- [ ] Hardcoded values that should be env vars

### Nit (Optional)

- [ ] Naming could be clearer
- [ ] Comment would help future readers
- [ ] Import ordering
- [ ] Unnecessary type assertions

---

## Example Reviews

### Good PR Comment

```markdown
## [Should Fix] Missing Convex index

**Location:** `convex/schema.ts` L45

**Issue:** Query filters on `userId` but no index defined.

**Why:** [sr-convex-expert Commandment III] — "Index every query filter field" to prevent slow queries and timeouts.

**Fix:**
\`\`\`typescript
posts: defineTable({
  userId: v.id("users"),
  content: v.string(),
})
  .index("by_userId", ["userId"])  // Add this
\`\`\`
```

### Good GitHub Issue

```markdown
## Summary
Auth mutation allows any user to delete any post.

## Current Behavior
`convex/posts.ts` L34 — `deletePost` mutation accepts `postId` but doesn't verify the caller owns the post.

## Expected Behavior
Per [sr-convex-expert] auth patterns, mutations that modify user data must verify ownership:

\`\`\`typescript
const post = await ctx.db.get(args.postId);
if (post.userId !== identity.subject) {
  throw new Error("Unauthorized");
}
\`\`\`

## How to Fix
1. Get the post first
2. Compare `post.userId` to `identity.subject`
3. Throw if mismatch

## References
- [sr-convex-expert] — Auth Pattern in Functions
- [TECH-REQ.md] — "All mutations that modify user data must verify ownership"
```

---

## Quick Commands

```bash
# Review a PR
gh pr diff 123 | head -200  # Preview diff
gh pr view 123              # See description
gh pr checks 123            # CI status
gh pr review 123 --approve  # Approve

# Create issue from template
gh issue create --title "[bug] Title" --label bug

# List open issues
gh issue list --state open

# Batch review: find TODOs in codebase
rg "TODO|FIXME|HACK|XXX" --glob "*.ts" --glob "*.tsx"
```

---

## References

- [sr-skills-index.md](references/sr-skills-index.md) — All sr-* skills and their domains
- [review-checklist.md](references/review-checklist.md) — Full review checklist by category
