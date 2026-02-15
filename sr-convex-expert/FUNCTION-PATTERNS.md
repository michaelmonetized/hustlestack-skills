# Convex Function Patterns

Production-ready function implementations for common use cases.

---

## Auth Patterns

### Get Current User Profile
```typescript
import { v } from "convex/values";
import { query, mutation } from "./_generated/server";

// Nullable version (doesn't throw)
export const getMyProfile = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) return null;

    return await ctx.db
      .query("profiles")
      .withIndex("by_clerk", (q) => q.eq("clerkId", identity.subject))
      .first();
  },
});

// Strict version (throws if not authenticated)
export const requireProfile = query({
  args: {},
  handler: async (ctx) => {
    const identity = await ctx.auth.getUserIdentity();
    if (!identity) {
      throw new Error("Unauthorized");
    }

    const profile = await ctx.db
      .query("profiles")
      .withIndex("by_clerk", (q) => q.eq("clerkId", identity.subject))
      .first();

    if (!profile) {
      throw new Error("Profile not found");
    }

    return profile;
  },
});
```

### Auth Helper (Reusable)
```typescript
// convex/lib/auth.ts
import { QueryCtx, MutationCtx } from "./_generated/server";

export async function getAuthenticatedUser(ctx: QueryCtx | MutationCtx) {
  const identity = await ctx.auth.getUserIdentity();
  if (!identity) return null;

  return await ctx.db
    .query("profiles")
    .withIndex("by_clerk", (q) => q.eq("clerkId", identity.subject))
    .first();
}

export async function requireAuth(ctx: QueryCtx | MutationCtx) {
  const user = await getAuthenticatedUser(ctx);
  if (!user) {
    throw new Error("Unauthorized");
  }
  return user;
}

// Usage in functions
export const myMutation = mutation({
  args: {},
  handler: async (ctx) => {
    const user = await requireAuth(ctx);
    // user is guaranteed to exist
  },
});
```

---

## CRUD Patterns

### Create with Timestamps
```typescript
export const create = mutation({
  args: {
    title: v.string(),
    content: v.string(),
    status: v.optional(v.union(v.literal("draft"), v.literal("published"))),
  },
  handler: async (ctx, args) => {
    const user = await requireAuth(ctx);
    const now = Date.now();

    return await ctx.db.insert("posts", {
      authorId: user._id,
      title: args.title,
      content: args.content,
      status: args.status ?? "draft",
      viewCount: 0,
      likeCount: 0,
      _creationTime is automatic
      updatedAt: now,
    });
  },
});
```

### Read with Authorization
```typescript
export const getById = query({
  args: { id: v.id("posts") },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.id);
    if (!post) return null;

    // Public posts are visible to everyone
    if (post.status === "published") {
      return post;
    }

    // Draft posts only visible to author
    const user = await getAuthenticatedUser(ctx);
    if (!user || post.authorId !== user._id) {
      return null;
    }

    return post;
  },
});
```

### Update with Ownership Check
```typescript
export const update = mutation({
  args: {
    id: v.id("posts"),
    title: v.optional(v.string()),
    content: v.optional(v.string()),
    status: v.optional(v.union(v.literal("draft"), v.literal("published"))),
  },
  handler: async (ctx, args) => {
    const user = await requireAuth(ctx);
    const post = await ctx.db.get(args.id);

    if (!post) {
      throw new Error("Post not found");
    }

    if (post.authorId !== user._id) {
      throw new Error("Not authorized to edit this post");
    }

    const { id, ...updates } = args;
    await ctx.db.patch(id, {
      ...updates,
      updatedAt: Date.now(),
      // Set publishedAt when publishing
      ...(updates.status === "published" && !post.publishedAt
        ? { publishedAt: Date.now() }
        : {}),
    });
  },
});
```

### Delete with Cascade
```typescript
export const deletePost = mutation({
  args: { id: v.id("posts") },
  handler: async (ctx, args) => {
    const user = await requireAuth(ctx);
    const post = await ctx.db.get(args.id);

    if (!post) {
      throw new Error("Post not found");
    }

    if (post.authorId !== user._id) {
      throw new Error("Not authorized to delete this post");
    }

    // Delete related data first
    const comments = await ctx.db
      .query("comments")
      .withIndex("by_post", (q) => q.eq("postId", args.id))
      .collect();

    for (const comment of comments) {
      await ctx.db.delete(comment._id);
    }

    const likes = await ctx.db
      .query("post_likes")
      .withIndex("by_post", (q) => q.eq("postId", args.id))
      .collect();

    for (const like of likes) {
      await ctx.db.delete(like._id);
    }

    // Delete the post
    await ctx.db.delete(args.id);
  },
});
```

---

## List & Filter Patterns

### List with Pagination
```typescript
export const list = query({
  args: {
    cursor: v.optional(v.string()),
    limit: v.optional(v.number()),
    status: v.optional(v.union(v.literal("draft"), v.literal("published"))),
  },
  handler: async (ctx, args) => {
    const limit = Math.min(args.limit ?? 20, 100);

    let query = ctx.db.query("posts").order("desc");

    if (args.status) {
      query = query.withIndex("by_status", (q) => q.eq("status", args.status!));
    }

    const results = await query.paginate({
      numItems: limit,
      cursor: args.cursor ?? null,
    });

    return {
      items: results.page,
      nextCursor: results.continueCursor,
      hasMore: !results.isDone,
    };
  },
});
```

### List by Owner
```typescript
export const getMyPosts = query({
  args: {
    status: v.optional(v.union(v.literal("draft"), v.literal("published"))),
  },
  handler: async (ctx, args) => {
    const user = await requireAuth(ctx);

    if (args.status) {
      return await ctx.db
        .query("posts")
        .withIndex("by_author_status", (q) =>
          q.eq("authorId", user._id).eq("status", args.status!)
        )
        .order("desc")
        .collect();
    }

    return await ctx.db
      .query("posts")
      .withIndex("by_author", (q) => q.eq("authorId", user._id))
      .order("desc")
      .collect();
  },
});
```

### Search
```typescript
export const search = query({
  args: {
    query: v.string(),
    limit: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    if (args.query.length < 2) {
      return [];
    }

    return await ctx.db
      .query("posts")
      .withSearchIndex("search_content", (q) =>
        q.search("content", args.query).eq("status", "published")
      )
      .take(args.limit ?? 10);
  },
});
```

---

## Relationship Patterns

### Fetch Related Data
```typescript
export const getPostWithAuthor = query({
  args: { id: v.id("posts") },
  handler: async (ctx, args) => {
    const post = await ctx.db.get(args.id);
    if (!post) return null;

    const author = await ctx.db.get(post.authorId);

    return {
      ...post,
      author: author
        ? {
            _id: author._id,
            name: author.name,
            avatarUrl: author.avatarUrl,
          }
        : null,
    };
  },
});
```

### Fetch Multiple Related
```typescript
export const getPostsWithAuthors = query({
  args: { limit: v.optional(v.number()) },
  handler: async (ctx, args) => {
    const posts = await ctx.db
      .query("posts")
      .withIndex("by_status", (q) => q.eq("status", "published"))
      .order("desc")
      .take(args.limit ?? 20);

    // Batch fetch all authors
    const authorIds = [...new Set(posts.map((p) => p.authorId))];
    const authors = await Promise.all(
      authorIds.map((id) => ctx.db.get(id))
    );
    const authorMap = new Map(
      authors.filter(Boolean).map((a) => [a!._id, a])
    );

    return posts.map((post) => ({
      ...post,
      author: authorMap.get(post.authorId) ?? null,
    }));
  },
});
```

### Toggle Pattern (Like/Unlike)
```typescript
export const toggleLike = mutation({
  args: { postId: v.id("posts") },
  handler: async (ctx, args) => {
    const user = await requireAuth(ctx);

    // Check if already liked
    const existing = await ctx.db
      .query("post_likes")
      .withIndex("by_post_profile", (q) =>
        q.eq("postId", args.postId).eq("profileId", user._id)
      )
      .first();

    const post = await ctx.db.get(args.postId);
    if (!post) throw new Error("Post not found");

    if (existing) {
      // Unlike
      await ctx.db.delete(existing._id);
      await ctx.db.patch(args.postId, {
        likeCount: Math.max(0, post.likeCount - 1),
      });
      return { liked: false };
    } else {
      // Like
      await ctx.db.insert("post_likes", {
        postId: args.postId,
        profileId: user._id,
        _creationTime is automatic
      });
      await ctx.db.patch(args.postId, {
        likeCount: post.likeCount + 1,
      });
      return { liked: true };
    }
  },
});
```

---

## Upsert Pattern

```typescript
export const upsertProfile = mutation({
  args: {
    clerkId: v.string(),
    name: v.string(),
    email: v.optional(v.string()),
    avatarUrl: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    const existing = await ctx.db
      .query("profiles")
      .withIndex("by_clerk", (q) => q.eq("clerkId", args.clerkId))
      .first();

    const now = Date.now();

    if (existing) {
      await ctx.db.patch(existing._id, {
        name: args.name,
        email: args.email,
        avatarUrl: args.avatarUrl,
        updatedAt: now,
      });
      return existing._id;
    }

    return await ctx.db.insert("profiles", {
      clerkId: args.clerkId,
      name: args.name,
      email: args.email,
      avatarUrl: args.avatarUrl,
      plan: "free",
      _creationTime is automatic
      updatedAt: now,
    });
  },
});
```

---

## Idempotency Pattern

```typescript
export const createNotification = mutation({
  args: {
    profileId: v.id("profiles"),
    type: v.string(),
    data: v.any(),
    idempotencyKey: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    // Check for duplicate
    if (args.idempotencyKey) {
      const existing = await ctx.db
        .query("notifications")
        .withIndex("by_idempotency", (q) =>
          q.eq("idempotencyKey", args.idempotencyKey)
        )
        .first();

      if (existing) {
        return existing._id;  // Return existing, don't duplicate
      }
    }

    return await ctx.db.insert("notifications", {
      profileId: args.profileId,
      type: args.type,
      data: args.data,
      idempotencyKey: args.idempotencyKey,
      read: false,
      _creationTime is automatic
    });
  },
});
```

---

## Background Processing Patterns

### Schedule Work
```typescript
import { internal } from "./_generated/api";

export const scheduleAssessment = mutation({
  args: { profileId: v.id("profiles"), type: v.string() },
  handler: async (ctx, args) => {
    // Create job record
    const jobId = await ctx.db.insert("jobs", {
      profileId: args.profileId,
      type: args.type,
      status: "pending",
      _creationTime is automatic
    });

    // Schedule the actual work
    await ctx.scheduler.runAfter(0, internal.workers.processAssessment, {
      jobId,
      profileId: args.profileId,
      type: args.type,
    });

    return jobId;
  },
});

// convex/workers.ts
export const processAssessment = internalMutation({
  args: {
    jobId: v.id("jobs"),
    profileId: v.id("profiles"),
    type: v.string(),
  },
  handler: async (ctx, args) => {
    // Mark as processing
    await ctx.db.patch(args.jobId, { status: "processing" });

    try {
      // Do the work...
      const result = await doAssessment(ctx, args.profileId, args.type);

      // Mark complete
      await ctx.db.patch(args.jobId, {
        status: "complete",
        result,
        completedAt: Date.now(),
      });
    } catch (error) {
      // Mark failed
      await ctx.db.patch(args.jobId, {
        status: "failed",
        error: String(error),
        completedAt: Date.now(),
      });
    }
  },
});
```

### Retry with Backoff
```typescript
export const processWithRetry = internalMutation({
  args: {
    notificationId: v.id("notification_queue"),
    attempt: v.optional(v.number()),
  },
  handler: async (ctx, args) => {
    const notification = await ctx.db.get(args.notificationId);
    if (!notification) return;

    const attempt = args.attempt ?? 1;
    const maxAttempts = 3;

    try {
      // Try to send...
      await sendNotification(notification);

      await ctx.db.patch(args.notificationId, {
        status: "sent",
        sentAt: Date.now(),
      });
    } catch (error) {
      if (attempt >= maxAttempts) {
        // Max retries reached
        await ctx.db.patch(args.notificationId, {
          status: "failed",
          lastError: String(error),
        });
      } else {
        // Schedule retry with exponential backoff
        const delayMs = Math.pow(2, attempt) * 60 * 1000;  // 2, 4, 8 minutes
        await ctx.scheduler.runAfter(
          delayMs,
          internal.workers.processWithRetry,
          { notificationId: args.notificationId, attempt: attempt + 1 }
        );

        await ctx.db.patch(args.notificationId, {
          status: "pending",
          lastAttemptAt: Date.now(),
          lastError: String(error),
        });
      }
    }
  },
});
```

---

## Error Handling

### Structured Errors
```typescript
import { ConvexError } from "convex/values";

export const createPost = mutation({
  args: { title: v.string(), content: v.string() },
  handler: async (ctx, args) => {
    const user = await getAuthenticatedUser(ctx);

    if (!user) {
      throw new ConvexError({
        code: "UNAUTHORIZED",
        message: "You must be logged in to create a post",
      });
    }

    if (args.title.length < 3) {
      throw new ConvexError({
        code: "VALIDATION_ERROR",
        message: "Title must be at least 3 characters",
        field: "title",
      });
    }

    // Rate limit check
    const recentPosts = await ctx.db
      .query("posts")
      .withIndex("by_author", (q) => q.eq("authorId", user._id))
      .order("desc")
      .take(10);

    const oneHourAgo = Date.now() - 60 * 60 * 1000;
    const postsInLastHour = recentPosts.filter((p) => p._creationTime > oneHourAgo);

    if (postsInLastHour.length >= 5) {
      throw new ConvexError({
        code: "RATE_LIMITED",
        message: "You can only create 5 posts per hour",
        retryAfter: postsInLastHour[4]._creationTime + 60 * 60 * 1000,
      });
    }

    // Create post...
  },
});
```

### Client Error Handling
```tsx
import { ConvexError } from "convex/values";

const createPost = useMutation(api.posts.create);

const handleCreate = async () => {
  try {
    await createPost({ title, content });
  } catch (error) {
    if (error instanceof ConvexError) {
      const data = error.data as { code: string; message: string };
      
      switch (data.code) {
        case "UNAUTHORIZED":
          router.push("/sign-in");
          break;
        case "VALIDATION_ERROR":
          setFieldError(data.field, data.message);
          break;
        case "RATE_LIMITED":
          toast.error(data.message);
          break;
        default:
          toast.error(data.message);
      }
    } else {
      toast.error("Something went wrong");
    }
  }
};
```

---

## Statistics & Aggregation

```typescript
export const getStats = query({
  args: {},
  handler: async (ctx) => {
    const all = await ctx.db.query("notification_queue").collect();

    const now = Date.now();
    const hourAgo = now - 60 * 60 * 1000;
    const dayAgo = now - 24 * 60 * 60 * 1000;

    return {
      total: all.length,
      pending: all.filter((n) => n.status === "pending").length,
      processing: all.filter((n) => n.status === "processing").length,
      sent: all.filter((n) => n.status === "sent").length,
      failed: all.filter((n) => n.status === "failed").length,
      sentLastHour: all.filter(
        (n) => n.status === "sent" && (n.sentAt ?? 0) > hourAgo
      ).length,
      sentLastDay: all.filter(
        (n) => n.status === "sent" && (n.sentAt ?? 0) > dayAgo
      ).length,
    };
  },
});
```

---

## Cleanup/Maintenance

```typescript
export const cleanup = internalMutation({
  args: { olderThanDays: v.number() },
  handler: async (ctx, args) => {
    const cutoff = Date.now() - args.olderThanDays * 24 * 60 * 60 * 1000;

    // Get old completed items
    const old = await ctx.db
      .query("notification_queue")
      .withIndex("by_status", (q) => q.eq("status", "sent"))
      .collect();

    let deleted = 0;
    for (const item of old) {
      if (item._creationTime < cutoff) {
        await ctx.db.delete(item._id);
        deleted++;
      }
    }

    return { deleted };
  },
});
```
