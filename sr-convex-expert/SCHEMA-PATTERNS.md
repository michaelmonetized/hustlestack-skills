# SCHEMA-PATTERNS.md - Convex Schema Standards

## The HurleyUS Pattern

**Core principle: Colocate table definition, Zod validator, types, and CRUD in `convex/[table].ts`**

### File Structure

```
convex/
├── _generated/           # Auto-generated (don't touch)
├── schema.ts             # Imports tables, adds indexes/search
├── auth.config.ts        # Clerk/auth configuration
├── users.ts              # UserTable + UserValidator + CRUD
├── employees.ts          # EmployeeTable + EmployeeValidator + CRUD
├── messages.ts           # MessageTable + MessageValidator + CRUD
└── ...
```

---

## Pattern: Table File (`convex/[table].ts`)

Each table file exports 4 things:
1. **`[Name]Table`** — Convex validators for `defineTable()`
2. **`[Name]Validator`** — Zod schema for form validation
3. **`type [Name]`** — TypeScript type (inferred from Zod)
4. **CRUD functions** — Queries and mutations

### Example: `convex/employees.ts`

```typescript
import { v } from "convex/values";
import { query, mutation } from "./_generated/server";
import { z } from "zod";

// ============================================
// 1. CONVEX TABLE DEFINITION
// ============================================
export const EmployeeTable = {
  uid: v.optional(v.string()),
  eid: v.string(),
  first: v.string(),
  last: v.string(),
  phone: v.string(),
  email: v.string(),
  dob: v.string(),
  status: v.union(
    v.literal("active"),
    v.literal("inactive"),
    v.literal("terminated"),
    v.literal("pending")
  ),
  hired: v.string(),
  terminated: v.optional(v.string()),
  position: v.union(
    v.literal("cashier"),
    v.literal("cook"),
    v.literal("trainer"),
    v.literal("shift leader"),
    v.literal("gm")
  ),
  rate: v.string(),
  type: v.union(v.literal("salary"), v.literal("hourly")),
};

// ============================================
// 2. ZOD VALIDATOR (for forms/API validation)
// ============================================
export const EmployeeValidator = z.object({
  uid: z.string().optional(),
  eid: z.string().regex(/^22703-?\d{4}$/, "Invalid EID format"),
  first: z.string().min(1, "First name is required"),
  last: z.string().min(1, "Last name is required"),
  phone: z.string().regex(/^\d{10}$/, "Phone must be 10 digits"),
  email: z.string().email("Invalid email format"),
  dob: z.string().min(1, "Date of birth is required"),
  status: z.enum(["active", "inactive", "terminated", "pending"]),
  hired: z.string().min(1, "Hire date is required"),
  terminated: z.string().optional(),
  position: z.enum(["cashier", "cook", "trainer", "shift leader", "gm"]),
  rate: z.string().regex(/^\d+\.\d{2}$/, "Invalid rate format"),
  type: z.enum(["salary", "hourly"]),
});

// ============================================
// 3. TYPESCRIPT TYPE
// ============================================
export type Employee = z.infer<typeof EmployeeValidator>;

// ============================================
// 4. CRUD FUNCTIONS
// ============================================
export const createEmployee = mutation({
  args: EmployeeTable,
  handler: async (ctx, args) => {
    return await ctx.db.insert("employees", args);
  },
});

export const listEmployees = query({
  args: {
    status: v.optional(v.union(
      v.literal("active"),
      v.literal("inactive"),
      v.literal("terminated"),
      v.literal("pending")
    )),
  },
  returns: v.array(v.object({
    _id: v.id("employees"),
    _creationTime: v.number(),
    ...EmployeeTable,
  })),
  handler: async (ctx, args) => {
    let query = ctx.db.query("employees");
    
    if (args.status) {
      query = query.withIndex("by_status", (q) => q.eq("status", args.status!));
    }
    
    return await query.collect();
  },
});

export const getEmployee = query({
  args: { id: v.id("employees") },
  handler: async (ctx, args) => {
    return await ctx.db.get(args.id);
  },
});

export const updateEmployee = mutation({
  args: {
    id: v.id("employees"),
    ...Object.fromEntries(
      Object.entries(EmployeeTable).map(([k, v]) => [k, v.isOptional ? v : v.optional()])
    ),
  },
  handler: async (ctx, args) => {
    const { id, ...updates } = args;
    const filtered = Object.fromEntries(
      Object.entries(updates).filter(([_, v]) => v !== undefined)
    );
    await ctx.db.patch(id, filtered);
  },
});

export const deleteEmployee = mutation({
  args: { id: v.id("employees") },
  handler: async (ctx, args) => {
    await ctx.db.delete(args.id);
  },
});
```

---

## Pattern: Schema File (`convex/schema.ts`)

**Schema.ts ONLY handles:**
- Importing table definitions
- Defining indexes
- Defining search indexes

```typescript
import { defineSchema, defineTable } from "convex/server";
import { UserTable } from "./users";
import { EmployeeTable } from "./employees";
import { MessageTable } from "./messages";
import { TaskTable } from "./tasks";

export default defineSchema({
  // Users
  users: defineTable(UserTable)
    .index("by_uid", ["uid"])
    .index("by_email", ["email"])
    .index("by_phone", ["phone"])
    .searchIndex("search_users", {
      searchField: "email",
      filterFields: ["first", "last", "phone"],
    }),

  // Employees
  employees: defineTable(EmployeeTable)
    .index("by_uid", ["uid"])
    .index("by_eid", ["eid"])
    .index("by_email", ["email"])
    .index("by_status", ["status"])
    .index("by_position", ["position"])
    .searchIndex("search_employees", {
      searchField: "first",
      filterFields: ["last", "eid", "email", "status", "position"],
    }),

  // Messages
  messages: defineTable(MessageTable)
    .index("by_from", ["from"])
    .index("by_to", ["to"])
    .searchIndex("search_messages", {
      searchField: "message",
      filterFields: ["from", "to"],
    }),

  // Tasks
  tasks: defineTable(TaskTable)
    .index("by_status", ["status"])
    .index("by_assignee", ["assignee"])
    .index("by_status_and_assignee", ["status", "assignee"]),
});
```

---

## Index Naming Convention

| Pattern | Example | Use Case |
|---------|---------|----------|
| `by_[field]` | `by_status` | Single field lookup |
| `by_[field1]_and_[field2]` | `by_employee_and_date` | Compound lookup |
| `search_[table]` | `search_employees` | Full-text search |
| `search_[table]_[field]` | `search_employees_name` | Search on specific field |

---

## Validator Patterns

### Union Types (Enums)

```typescript
// Convex validator
status: v.union(
  v.literal("draft"),
  v.literal("published"),
  v.literal("archived")
),

// Zod equivalent
status: z.enum(["draft", "published", "archived"]),
```

### Optional Fields

```typescript
// Convex
terminated: v.optional(v.string()),

// Zod
terminated: z.string().optional(),
```

### Nested Objects

```typescript
// Convex
docs: v.optional(v.array(v.object({
  label: v.string(),
  url: v.string(),
  uploadedAt: v.string(),
}))),

// Zod
docs: z.array(z.object({
  label: z.string(),
  url: z.string(),
  uploadedAt: z.string(),
})).optional(),
```

### ID References

```typescript
// Convex - reference to another table
authorId: v.id("users"),
avatar: v.optional(v.id("_storage")),

// Zod - just a string (IDs are strings in transit)
authorId: z.string(),
avatar: z.string().optional(),
```

---

## Why This Pattern?

### Benefits

1. **Colocation** — Types, validators, and CRUD live together
2. **DRY** — Table shape defined once, used by Convex AND Zod
3. **Separation** — schema.ts only handles DB concerns (indexes)
4. **Scalability** — Each domain is self-contained
5. **IDE Support** — Jump to definition works naturally
6. **Testing** — Can test validators independently

### Compared to Other Patterns

| Approach | Pros | Cons |
|----------|------|------|
| **HurleyUS (this)** | Colocated, DRY, scalable | Requires Zod dependency |
| **All in schema.ts** | Simple | Gets unwieldy, no form validation |
| **Separate types file** | Centralized types | Duplication, drift risk |

---

## Form Integration

### With react-hook-form

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { EmployeeValidator, type Employee } from "@/convex/employees";

function EmployeeForm() {
  const form = useForm<Employee>({
    resolver: zodResolver(EmployeeValidator),
    defaultValues: {
      status: "pending",
      type: "hourly",
    },
  });

  // Form validated by Zod before submission
  const onSubmit = (data: Employee) => {
    createEmployee(data);
  };
}
```

### Server-Side Validation

The Convex validators (`EmployeeTable`) automatically validate on the server. Zod is for client-side form UX — Convex handles the source of truth.

---

## Search Index Patterns

### Basic Search

```typescript
.searchIndex("search_employees", {
  searchField: "first",  // Primary search field
  filterFields: ["last", "email", "status"],  // Can filter results
})
```

### Using Search

```typescript
export const searchEmployees = query({
  args: { 
    query: v.string(),
    status: v.optional(v.string()),
  },
  handler: async (ctx, args) => {
    let search = ctx.db
      .query("employees")
      .withSearchIndex("search_employees", (q) => 
        q.search("first", args.query)
      );
    
    if (args.status) {
      search = search.filter((q) => q.eq(q.field("status"), args.status));
    }
    
    return await search.collect();
  },
});
```

---

## Migration Checklist

When changing schema:

1. [ ] Update `[Table]Table` validators
2. [ ] Update `[Table]Validator` Zod schema
3. [ ] Update TypeScript type (automatic if inferred)
4. [ ] Update CRUD functions if args changed
5. [ ] Update indexes in schema.ts if new fields
6. [ ] Run `npx convex dev` to validate
7. [ ] Test locally before deploying

---

*Based on production patterns from getat.me and waynesville.yourzaxbys.com*
