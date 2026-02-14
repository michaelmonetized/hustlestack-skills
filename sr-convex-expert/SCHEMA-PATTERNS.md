# Convex Schema Design Patterns

Production-ready schema patterns extracted from real applications.

---

## Basic Structure

```typescript
// convex/schema.ts
import { defineSchema, defineTable } from "convex/server";
import { v } from "convex/values";

export default defineSchema({
  // Tables defined here
});
```

---

## Validator Types

### Primitives
```typescript
v.string()              // string
v.number()              // number (int or float)
v.boolean()             // boolean
v.null()                // null literal
v.int64()               // BigInt
v.bytes()               // ArrayBuffer
```

### Optional & Nullable
```typescript
v.optional(v.string())  // string | undefined (field can be missing)
v.union(v.string(), v.null())  // string | null (field present but null)
v.optional(v.union(v.string(), v.null()))  // string | null | undefined
```

### Complex Types
```typescript
v.array(v.string())     // string[]
v.object({              // { name: string, age: number }
  name: v.string(),
  age: v.number(),
})
v.any()                 // any (use sparingly)
```

### IDs & References
```typescript
v.id("users")           // Id<"users"> - reference to users table
v.id("_storage")        // Id<"_storage"> - Convex file storage
```

### Literal & Union (Enums)
```typescript
// String literal (single value)
v.literal("admin")

// Union of literals (enum-like)
v.union(
  v.literal("pending"),
  v.literal("active"),
  v.literal("completed")
)

// Reusable validator
const statusValidator = v.union(
  v.literal("pending"),
  v.literal("active"),
  v.literal("completed")
);
```

---

## Index Patterns

### Single-Field Index
```typescript
.index("by_email", ["email"])
.index("by_created", ["createdAt"])
```

### Compound Index (Multi-Field)
```typescript
// Query: profileId + status
.index("by_profile_status", ["profileId", "status"])

// Query with range
.index("by_status_created", ["status", "createdAt"])
```

### Index Usage
```typescript
// Single field
await ctx.db
  .query("users")
  .withIndex("by_email", (q) => q.eq("email", email))
  .first();

// Compound index - must use fields in order
await ctx.db
  .query("matches")
  .withIndex("by_profile_status", (q) => 
    q.eq("profileId", profileId).eq("status", "active")
  )
  .collect();

// Range query on last field
await ctx.db
  .query("activities")
  .withIndex("by_status_created", (q) =>
    q.eq("status", "pending").gte("createdAt", cutoff)
  )
  .collect();
```

### Search Index
```typescript
.searchIndex("search_content", {
  searchField: "content",
  filterFields: ["isPublished", "authorId"],
})

// Usage
await ctx.db
  .query("posts")
  .withSearchIndex("search_content", (q) =>
    q.search("content", searchTerm).eq("isPublished", true)
  )
  .take(10);
```

---

## Common Table Patterns

### User Profile (Clerk Extension)
```typescript
profiles: defineTable({
  // Clerk user ID - NEVER store as indexed email
  clerkId: v.string(),
  
  // Basic info
  name: v.string(),
  email: v.optional(v.string()),  // Denormalized from Clerk
  avatarUrl: v.optional(v.string()),
  
  // Profile details
  headline: v.optional(v.string()),
  bio: v.optional(v.string()),
  location: v.optional(v.string()),
  
  // Settings/preferences
  plan: v.union(v.literal("free"), v.literal("pro"), v.literal("enterprise")),
  preferences: v.optional(v.object({
    theme: v.union(v.literal("light"), v.literal("dark")),
    notifications: v.boolean(),
  })),
  
  // Timestamps
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index("by_clerk", ["clerkId"])  // Primary lookup
  .index("by_email", ["email"])    // Optional search
  .index("by_plan", ["plan"]),     // Filter by plan
```

### Items with Owner
```typescript
posts: defineTable({
  authorId: v.id("profiles"),
  
  // Content
  title: v.string(),
  content: v.string(),
  excerpt: v.optional(v.string()),
  
  // Media
  coverImage: v.optional(v.id("_storage")),
  
  // Status
  status: v.union(
    v.literal("draft"),
    v.literal("published"),
    v.literal("archived")
  ),
  publishedAt: v.optional(v.number()),
  
  // Engagement
  viewCount: v.number(),
  likeCount: v.number(),
  
  // Timestamps
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index("by_author", ["authorId"])
  .index("by_status", ["status"])
  .index("by_author_status", ["authorId", "status"])
  .index("by_published", ["publishedAt"])
  .searchIndex("search_posts", {
    searchField: "content",
    filterFields: ["status", "authorId"],
  }),
```

### Many-to-Many Relationship (Junction Table)
```typescript
// Skills can be added to multiple profiles
// Profiles can have multiple skills
profile_skills: defineTable({
  profileId: v.id("profiles"),
  skillId: v.id("skills"),
  
  // Relationship metadata
  proficiency: v.union(
    v.literal("beginner"),
    v.literal("intermediate"),
    v.literal("advanced"),
    v.literal("expert")
  ),
  yearsUsed: v.optional(v.number()),
  
  // Social
  endorsed: v.boolean(),
  endorsements: v.number(),
  
  // Timestamps
  addedAt: v.number(),
})
  .index("by_profile", ["profileId"])
  .index("by_skill", ["skillId"])
  .index("by_profile_skill", ["profileId", "skillId"]),  // Unique lookup
```

### Queue/Job Table
```typescript
notification_queue: defineTable({
  // Target
  profileId: v.id("profiles"),
  
  // Type
  type: v.union(v.literal("email"), v.literal("push"), v.literal("in_app")),
  priority: v.union(v.literal("low"), v.literal("normal"), v.literal("high"), v.literal("urgent")),
  
  // Content
  template: v.string(),
  data: v.any(),
  
  // Processing
  status: v.union(
    v.literal("pending"),
    v.literal("processing"),
    v.literal("sent"),
    v.literal("failed"),
    v.literal("cancelled")
  ),
  
  // Retry logic
  attempts: v.number(),
  maxAttempts: v.number(),
  lastAttemptAt: v.optional(v.number()),
  lastError: v.optional(v.string()),
  
  // Scheduling
  scheduledFor: v.number(),
  sentAt: v.optional(v.number()),
  
  // Response
  response: v.optional(v.any()),
  
  // Deduplication
  idempotencyKey: v.optional(v.string()),
  
  // Timestamps
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index("by_profile", ["profileId"])
  .index("by_status", ["status"])
  .index("by_status_scheduled", ["status", "scheduledFor"])  // For processing
  .index("by_idempotency", ["idempotencyKey"]),
```

### Subscription/Billing
```typescript
subscriptions: defineTable({
  // Owner
  profileId: v.id("profiles"),
  
  // Stripe IDs
  stripeCustomerId: v.string(),
  stripeSubscriptionId: v.string(),
  stripePriceId: v.string(),
  stripeProductId: v.optional(v.string()),
  
  // Plan info
  plan: v.union(v.literal("free"), v.literal("pro"), v.literal("premium"), v.literal("enterprise")),
  billingInterval: v.union(v.literal("monthly"), v.literal("annual")),
  
  // Status
  status: v.union(
    v.literal("active"),
    v.literal("past_due"),
    v.literal("canceled"),
    v.literal("incomplete"),
    v.literal("trialing"),
    v.literal("paused")
  ),
  
  // Billing period
  currentPeriodStart: v.number(),
  currentPeriodEnd: v.number(),
  
  // Trial
  trialStart: v.optional(v.number()),
  trialEnd: v.optional(v.number()),
  
  // Cancellation
  cancelAtPeriodEnd: v.boolean(),
  canceledAt: v.optional(v.number()),
  cancellationReason: v.optional(v.string()),
  
  // Timestamps
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index("by_profile", ["profileId"])
  .index("by_stripe_customer", ["stripeCustomerId"])
  .index("by_stripe_subscription", ["stripeSubscriptionId"])
  .index("by_status", ["status"]),
```

### Chat/Messages (Real-Time)
```typescript
chat_sessions: defineTable({
  // Participants
  profileId: v.id("profiles"),
  assignedTo: v.optional(v.id("users_admin")),
  
  // Session info
  topic: v.optional(v.string()),
  initialMessage: v.string(),
  
  // Status
  status: v.union(
    v.literal("waiting"),
    v.literal("active"),
    v.literal("ended"),
    v.literal("abandoned")
  ),
  
  // Metrics
  messageCount: v.number(),
  waitTime: v.optional(v.number()),  // Seconds before agent joined
  duration: v.optional(v.number()),   // Seconds of active session
  
  // Feedback
  satisfactionRating: v.optional(v.number()),
  satisfactionFeedback: v.optional(v.string()),
  
  // Timestamps
  createdAt: v.number(),
  assignedAt: v.optional(v.number()),
  endedAt: v.optional(v.number()),
})
  .index("by_profile", ["profileId"])
  .index("by_status", ["status"])
  .index("by_assigned", ["assignedTo"]),

chat_messages: defineTable({
  sessionId: v.id("chat_sessions"),
  
  // Sender
  senderType: v.union(v.literal("user"), v.literal("agent"), v.literal("bot")),
  senderProfileId: v.optional(v.id("profiles")),
  senderAdminId: v.optional(v.id("users_admin")),
  
  // Content
  content: v.string(),
  messageType: v.union(v.literal("text"), v.literal("image"), v.literal("system")),
  
  // Status
  readAt: v.optional(v.number()),
  
  // Timestamps
  createdAt: v.number(),
})
  .index("by_session", ["sessionId"]),
```

### API Keys
```typescript
api_apps: defineTable({
  ownerProfileId: v.id("profiles"),
  
  // App info
  name: v.string(),
  description: v.optional(v.string()),
  websiteUrl: v.optional(v.string()),
  
  // OAuth
  redirectUris: v.optional(v.array(v.string())),
  scopes: v.array(v.string()),
  
  // Status
  status: v.union(
    v.literal("pending"),
    v.literal("approved"),
    v.literal("suspended"),
    v.literal("revoked")
  ),
  
  // Rate limits
  tier: v.union(v.literal("free"), v.literal("basic"), v.literal("pro"), v.literal("enterprise")),
  rateLimitPerMinute: v.number(),
  rateLimitPerDay: v.number(),
  
  // Timestamps
  createdAt: v.number(),
  updatedAt: v.number(),
})
  .index("by_owner_profile", ["ownerProfileId"])
  .index("by_status", ["status"]),

api_keys: defineTable({
  appId: v.id("api_apps"),
  
  // Key info (never store full key!)
  name: v.string(),
  keyPrefix: v.string(),  // First 8 chars for display (sk_abc1234...)
  keyHash: v.string(),    // Hash for lookup
  
  // Environment
  environment: v.union(v.literal("test"), v.literal("live")),
  
  // Status
  isActive: v.boolean(),
  expiresAt: v.optional(v.number()),
  
  // Usage tracking
  lastUsedAt: v.optional(v.number()),
  lastUsedIp: v.optional(v.string()),
  
  // Revocation
  revokedAt: v.optional(v.number()),
  revokedReason: v.optional(v.string()),
  
  // Timestamps
  createdAt: v.number(),
})
  .index("by_app", ["appId"])
  .index("by_key_prefix", ["keyPrefix"]),
```

---

## Anti-Patterns

### ❌ Storing Arrays That Grow Unbounded
```typescript
// WRONG - document size grows forever
posts: defineTable({
  likedBy: v.array(v.id("profiles")),  // Could be millions!
})

// CORRECT - separate table
post_likes: defineTable({
  postId: v.id("posts"),
  profileId: v.id("profiles"),
  createdAt: v.number(),
})
  .index("by_post", ["postId"])
  .index("by_profile", ["profileId"])
  .index("by_post_profile", ["postId", "profileId"]),
```

### ❌ Deep Nesting
```typescript
// WRONG - hard to query, update, index
profiles: defineTable({
  settings: v.object({
    notifications: v.object({
      email: v.object({
        marketing: v.boolean(),
        updates: v.boolean(),
      }),
    }),
  }),
})

// CORRECT - flat structure
profiles: defineTable({
  emailMarketing: v.boolean(),
  emailUpdates: v.boolean(),
})
```

### ❌ No Timestamps
```typescript
// WRONG - no audit trail
posts: defineTable({
  title: v.string(),
})

// CORRECT - always add timestamps
posts: defineTable({
  title: v.string(),
  createdAt: v.number(),
  updatedAt: v.number(),
})
```

### ❌ Missing Indexes
```typescript
// WRONG - this query scans entire table
const posts = await ctx.db
  .query("posts")
  .filter((q) => q.eq(q.field("authorId"), authorId))  // No index!
  .collect();

// CORRECT - use index
posts: defineTable({ ... })
  .index("by_author", ["authorId"])

const posts = await ctx.db
  .query("posts")
  .withIndex("by_author", (q) => q.eq("authorId", authorId))
  .collect();
```

---

## Migration Checklist

When changing schema:

1. **Adding fields**: Use `v.optional()` initially
2. **Adding indexes**: Safe to add anytime
3. **Adding tables**: Safe to add anytime
4. **Removing fields**: Remove from schema AFTER all docs updated
5. **Changing field types**: Never! Create new field, migrate, remove old
6. **Removing indexes**: Safe if no queries use it
7. **Removing tables**: Only after all references removed
