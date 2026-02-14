# Convex + Next.js Integration

Deep integration patterns for Next.js 15/16+ with App Router.

---

## Provider Setup

```tsx
// app/providers.tsx
"use client";

import { ClerkProvider, useAuth } from "@clerk/nextjs";
import { ConvexProviderWithClerk } from "convex/react-clerk";
import { ConvexReactClient } from "convex/react";
import { ReactNode, useMemo } from "react";

const convexUrl = process.env.NEXT_PUBLIC_CONVEX_URL!;

export function Providers({ children }: { children: ReactNode }) {
  // Memoize client to prevent reconnection on re-renders
  const convex = useMemo(() => new ConvexReactClient(convexUrl), []);

  return (
    <ClerkProvider>
      <ConvexProviderWithClerk client={convex} useAuth={useAuth}>
        {children}
      </ConvexProviderWithClerk>
    </ClerkProvider>
  );
}
```

```tsx
// app/layout.tsx
import { Providers } from "./providers";

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
```

**⚠️ Without Clerk:** Use plain `ConvexProvider`:
```tsx
import { ConvexProvider, ConvexReactClient } from "convex/react";

const convex = new ConvexReactClient(process.env.NEXT_PUBLIC_CONVEX_URL!);

export function Providers({ children }: { children: ReactNode }) {
  return <ConvexProvider client={convex}>{children}</ConvexProvider>;
}
```

---

## React Hooks

### useQuery (Real-Time Data)
```tsx
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function ProfileCard() {
  // Automatically subscribes to real-time updates
  const profile = useQuery(api.profiles.getMyProfile);

  // Loading state
  if (profile === undefined) {
    return <Skeleton />;
  }

  // No data state
  if (profile === null) {
    return <CreateProfilePrompt />;
  }

  return (
    <div>
      <h1>{profile.name}</h1>
      <p>{profile.email}</p>
    </div>
  );
}
```

### useMutation
```tsx
"use client";

import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

export function UpdateProfileButton() {
  const updateProfile = useMutation(api.profiles.update);
  const [isLoading, setIsLoading] = useState(false);

  const handleUpdate = async () => {
    setIsLoading(true);
    try {
      await updateProfile({ name: "New Name" });
      toast.success("Profile updated!");
    } catch (error) {
      toast.error("Failed to update profile");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <button onClick={handleUpdate} disabled={isLoading}>
      {isLoading ? "Updating..." : "Update Profile"}
    </button>
  );
}
```

### useAction (External APIs)
```tsx
"use client";

import { useAction } from "convex/react";
import { api } from "@/convex/_generated/api";

export function SendEmailButton({ to }: { to: string }) {
  const sendEmail = useAction(api.email.send);

  const handleSend = async () => {
    const success = await sendEmail({
      to,
      subject: "Hello",
      body: "<h1>Welcome!</h1>",
    });

    if (success) {
      toast.success("Email sent!");
    }
  };

  return <button onClick={handleSend}>Send Email</button>;
}
```

### Conditional Queries
```tsx
// Skip query when no ID
const profile = useQuery(
  api.profiles.getById,
  profileId ? { id: profileId } : "skip"
);

// Skip query when not authenticated
const { isSignedIn } = useAuth();
const myData = useQuery(
  api.users.getMyData,
  isSignedIn ? {} : "skip"
);
```

---

## Optimistic Updates

```tsx
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

export function LikeButton({ postId, currentLikes }: Props) {
  const like = useMutation(api.posts.like).withOptimisticUpdate(
    (localStore, args) => {
      const currentPost = localStore.getQuery(api.posts.getById, { id: args.postId });
      if (currentPost) {
        localStore.setQuery(api.posts.getById, { id: args.postId }, {
          ...currentPost,
          likes: currentPost.likes + 1,
        });
      }
    }
  );

  return (
    <button onClick={() => like({ postId })}>
      ❤️ {currentLikes}
    </button>
  );
}
```

---

## SSR Considerations

### ❌ Wrong: Query in Server Component
```tsx
// This DOESN'T WORK - Convex hooks are client-only
export default async function Page() {
  const data = useQuery(api.data.get); // ❌ ERROR
  return <div>{data}</div>;
}
```

### ✅ Correct: Client Component for Data
```tsx
// app/dashboard/page.tsx
import { DashboardClient } from "./client";

export default function DashboardPage() {
  return <DashboardClient />;
}

// app/dashboard/client.tsx
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function DashboardClient() {
  const data = useQuery(api.dashboard.getData);
  
  if (data === undefined) return <Loading />;
  
  return <Dashboard data={data} />;
}
```

### Preloading (Advanced)
```tsx
// Use preloadQuery for initial data
import { preloadQuery } from "convex/nextjs";
import { api } from "@/convex/_generated/api";

export default async function Page() {
  const preloaded = await preloadQuery(api.posts.list, { limit: 10 });
  
  return <PostList preloaded={preloaded} />;
}

// Client component receives preloaded data
"use client";

import { usePreloadedQuery } from "convex/react";

export function PostList({ preloaded }: { preloaded: Preloaded<typeof api.posts.list> }) {
  const posts = usePreloadedQuery(preloaded);
  
  return <>{posts.map(post => <Post key={post._id} {...post} />)}</>;
}
```

---

## Server Actions Integration

### Call Convex from Server Action
```tsx
// app/actions.ts
"use server";

import { fetchMutation, fetchQuery } from "convex/nextjs";
import { api } from "@/convex/_generated/api";

export async function createPost(formData: FormData) {
  const title = formData.get("title") as string;
  const content = formData.get("content") as string;

  // Call Convex mutation from server action
  const postId = await fetchMutation(api.posts.create, {
    title,
    content,
  });

  return { postId };
}

export async function getStats() {
  // Call Convex query from server action
  return await fetchQuery(api.stats.get);
}
```

### Use in Component
```tsx
// Client component with server action
"use client";

export function CreatePostForm() {
  const [state, formAction] = useFormState(createPost, null);

  return (
    <form action={formAction}>
      <input name="title" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  );
}
```

---

## Real-Time Subscriptions

### Live Data Updates
```tsx
"use client";

import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function LiveChat({ sessionId }: { sessionId: Id<"chat_sessions"> }) {
  // This automatically updates when new messages arrive
  const messages = useQuery(api.chat.getMessages, { sessionId });

  return (
    <div className="chat-container">
      {messages?.map((msg) => (
        <Message key={msg._id} {...msg} />
      ))}
    </div>
  );
}
```

### Watching Multiple Queries
```tsx
export function Dashboard() {
  // All queries update in real-time independently
  const profile = useQuery(api.profiles.getMyProfile);
  const notifications = useQuery(api.notifications.getUnread);
  const stats = useQuery(api.stats.getDashboard);

  const isLoading = profile === undefined || 
                    notifications === undefined || 
                    stats === undefined;

  if (isLoading) return <DashboardSkeleton />;

  return (
    <div>
      <ProfileWidget profile={profile} />
      <NotificationBell count={notifications.length} />
      <StatsCards stats={stats} />
    </div>
  );
}
```

---

## Form Patterns

### With React Hook Form
```tsx
"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { z } from "zod";

const schema = z.object({
  name: z.string().min(2),
  email: z.string().email(),
  bio: z.string().optional(),
});

type FormData = z.infer<typeof schema>;

export function ProfileForm() {
  const updateProfile = useMutation(api.profiles.update);
  
  const form = useForm<FormData>({
    resolver: zodResolver(schema),
  });

  const onSubmit = async (data: FormData) => {
    try {
      await updateProfile(data);
      toast.success("Profile updated!");
    } catch (error) {
      toast.error("Failed to update profile");
    }
  };

  return (
    <form onSubmit={form.handleSubmit(onSubmit)}>
      <input {...form.register("name")} />
      {form.formState.errors.name && (
        <span>{form.formState.errors.name.message}</span>
      )}
      
      <input {...form.register("email")} />
      <textarea {...form.register("bio")} />
      
      <button type="submit" disabled={form.formState.isSubmitting}>
        Save
      </button>
    </form>
  );
}
```

---

## Error Handling

### Query Error Boundaries
```tsx
"use client";

import { ConvexError } from "convex/values";

export function ProfileWrapper() {
  try {
    return <ProfileCard />;
  } catch (error) {
    if (error instanceof ConvexError) {
      return <ErrorMessage message={error.data as string} />;
    }
    throw error; // Re-throw for error boundary
  }
}
```

### Mutation Error Handling
```tsx
const createPost = useMutation(api.posts.create);

const handleCreate = async () => {
  try {
    const id = await createPost({ title, content });
    router.push(`/posts/${id}`);
  } catch (error) {
    if (error instanceof ConvexError) {
      // Structured error from Convex
      const data = error.data as { code: string; message: string };
      if (data.code === "RATE_LIMITED") {
        toast.error("Too many posts. Please wait.");
      } else {
        toast.error(data.message);
      }
    } else {
      toast.error("Something went wrong");
    }
  }
};
```

---

## File Uploads (Complete Example)

```tsx
"use client";

import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useState, useRef } from "react";

export function FileUploader() {
  const generateUploadUrl = useMutation(api.files.generateUploadUrl);
  const saveFile = useMutation(api.files.saveFile);
  
  const [isUploading, setIsUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    setProgress(0);

    try {
      // 1. Get signed upload URL
      const uploadUrl = await generateUploadUrl();

      // 2. Upload file with progress tracking
      const xhr = new XMLHttpRequest();
      xhr.upload.addEventListener("progress", (e) => {
        if (e.lengthComputable) {
          setProgress(Math.round((e.loaded / e.total) * 100));
        }
      });

      await new Promise((resolve, reject) => {
        xhr.open("POST", uploadUrl);
        xhr.setRequestHeader("Content-Type", file.type);
        xhr.onload = resolve;
        xhr.onerror = reject;
        xhr.send(file);
      });

      const response = JSON.parse(xhr.responseText);

      // 3. Save file reference to database
      await saveFile({
        storageId: response.storageId,
        filename: file.name,
        mimeType: file.type,
        size: file.size,
      });

      toast.success("File uploaded!");
    } catch (error) {
      toast.error("Upload failed");
    } finally {
      setIsUploading(false);
      setProgress(0);
      if (inputRef.current) inputRef.current.value = "";
    }
  };

  return (
    <div>
      <input
        ref={inputRef}
        type="file"
        onChange={handleUpload}
        disabled={isUploading}
      />
      {isUploading && (
        <div className="progress-bar">
          <div style={{ width: `${progress}%` }} />
        </div>
      )}
    </div>
  );
}
```

---

## Deployment Checklist

- [ ] `providers.tsx` has memoized ConvexReactClient
- [ ] Root layout wraps children with Providers
- [ ] Environment variables set in Vercel
- [ ] Build script uses `--cmd` wrapper pattern
- [ ] No useQuery/useMutation in Server Components
- [ ] Error boundaries around Convex components
- [ ] Loading states for all queries
