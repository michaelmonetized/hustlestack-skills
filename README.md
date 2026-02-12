# HustleStack Skills

Battle-tested AI coding skills for shipping production web apps fast.

Born from building dozens of Next.js + Convex apps with Claude Code and OpenClaw. These aren't theoretical best practices — they're lessons learned from 50K lines of broken code, 29-agent disasters, and the rewrites that followed.

## The Stack (Opinionated)

| Layer | Tech |
|-------|------|
| Framework | Next.js 16+ (App Router, Turbopack, PPR) |
| React | React 19+ with react-compiler |
| Styling | Tailwind CSS v4 |
| Components | shadcn/ui + Radix UI |
| Icons | Phosphor (react-icons/pi, light weight only) |
| Database | Convex |
| Auth | Clerk |
| Payments | Stripe |
| Email | Resend |
| Analytics | PostHog |
| Errors | Sentry |
| Hosting | Vercel |

No config. No alternatives. This stack ships.

## Skills

### 🔧 [senior-dev](./senior-dev/SKILL.md)
12-step production workflow with TODO tracking, Graphite PRs, GitHub issues, and Vercel deploy checks. Use for any development task that needs tracked progress and code review.

### 🎨 [frontend-design](./frontend-design/SKILL.md)  
Create distinctive, production-grade interfaces that avoid generic AI aesthetics. Bold choices, memorable design, zero AI slop.

### 🏗️ [web-architecture](./web-architecture/SKILL.md)
Multi-agent orchestration for complex projects. Phased builds, functional verification, the full playbook for delegating to sub-agents without producing 50K lines of broken code.

### 📋 [delegation](./delegation/SKILL.md)
Architecture-first workflow for delegating individual tasks. Read the architecture, understand the system, then write code that fits.

## Installation

### OpenClaw
```bash
# Clone to your skills directory
git clone https://github.com/hustlestack/hustlestack-skills ~/.openclaw/workspace/skills/hustlestack

# Or add individual skills
cp -r hustlestack-skills/senior-dev ~/.openclaw/workspace/skills/
```

### Claude Code
```bash
# Add to your CLAUDE.md or project instructions
# Reference skill files directly in prompts
```

## Philosophy

1. **Single agent + full context > many agents + partial context**
2. **"Compiles" ≠ "works"** — verify functionality, not just builds
3. **Architecture first** — understand the system before writing code
4. **Opinionated stack** — decision fatigue kills velocity
5. **Ship daily** — momentum compounds

## Origin Story

These skills emerged from:
- 29 parallel agents writing 50K lines that didn't compile
- A "working" app with zero actual functionality (BreazyApp autopsy)
- Rewriting entire backends in 11 minutes with single-agent + full context
- Shipping 15+ production apps in early 2026

The hard lessons are baked in.

## License

MIT

---

Created by [Michael C. Hurley](https://michaelchurley.com) • Skills for [OpenClaw](https://openclaw.ai) & [ClawHub](https://clawhub.com)
