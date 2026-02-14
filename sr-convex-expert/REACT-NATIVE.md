# Convex + React Native Integration

Mobile-specific patterns for React Native with Expo.

---

## Setup

### Installation
```bash
npx expo install convex
# Or with yarn/npm
yarn add convex
```

### Provider Setup
```tsx
// app/_layout.tsx (Expo Router)
import { ConvexProvider, ConvexReactClient } from "convex/react";
import { Stack } from "expo-router";

const convex = new ConvexReactClient(process.env.EXPO_PUBLIC_CONVEX_URL!);

export default function RootLayout() {
  return (
    <ConvexProvider client={convex}>
      <Stack />
    </ConvexProvider>
  );
}
```

### With Auth (Clerk)
```tsx
import { ClerkProvider, useAuth } from "@clerk/clerk-expo";
import { ConvexProviderWithClerk } from "convex/react-clerk";
import { ConvexReactClient } from "convex/react";
import * as SecureStore from "expo-secure-store";

const convex = new ConvexReactClient(process.env.EXPO_PUBLIC_CONVEX_URL!);

// Token cache for Clerk (required on mobile)
const tokenCache = {
  async getToken(key: string) {
    return SecureStore.getItemAsync(key);
  },
  async saveToken(key: string, value: string) {
    return SecureStore.setItemAsync(key, value);
  },
};

export default function RootLayout() {
  return (
    <ClerkProvider
      publishableKey={process.env.EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY!}
      tokenCache={tokenCache}
    >
      <ConvexProviderWithClerk client={convex} useAuth={useAuth}>
        <Stack />
      </ConvexProviderWithClerk>
    </ClerkProvider>
  );
}
```

---

## Environment Variables

```bash
# .env or app.config.js
EXPO_PUBLIC_CONVEX_URL=https://your-project.convex.cloud
EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
```

```typescript
// app.config.ts (Expo config)
export default {
  expo: {
    // ...
    extra: {
      convexUrl: process.env.EXPO_PUBLIC_CONVEX_URL,
      clerkPublishableKey: process.env.EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY,
    },
  },
};
```

---

## React Hooks (Same as Web)

### useQuery
```tsx
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { View, Text, ActivityIndicator } from "react-native";

export function ProfileScreen() {
  const profile = useQuery(api.profiles.getMyProfile);

  if (profile === undefined) {
    return <ActivityIndicator />;
  }

  if (profile === null) {
    return <CreateProfilePrompt />;
  }

  return (
    <View>
      <Text style={styles.name}>{profile.name}</Text>
      <Text style={styles.email}>{profile.email}</Text>
    </View>
  );
}
```

### useMutation
```tsx
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { useState } from "react";
import { Button, Alert } from "react-native";

export function UpdateButton() {
  const updateProfile = useMutation(api.profiles.update);
  const [loading, setLoading] = useState(false);

  const handleUpdate = async () => {
    setLoading(true);
    try {
      await updateProfile({ name: "New Name" });
      Alert.alert("Success", "Profile updated!");
    } catch (error) {
      Alert.alert("Error", "Failed to update profile");
    } finally {
      setLoading(false);
    }
  };

  return (
    <Button
      title={loading ? "Updating..." : "Update Profile"}
      onPress={handleUpdate}
      disabled={loading}
    />
  );
}
```

---

## Mobile Considerations

### Connection State Handling
```tsx
import { useConvex } from "convex/react";
import { useEffect, useState } from "react";
import { AppState, AppStateStatus } from "react-native";

export function ConnectionStatus() {
  const convex = useConvex();
  const [connectionState, setConnectionState] = useState<string>("connected");

  useEffect(() => {
    // Handle app state changes
    const subscription = AppState.addEventListener(
      "change",
      (state: AppStateStatus) => {
        if (state === "active") {
          // App came to foreground - connection will auto-reconnect
          setConnectionState("reconnecting");
        }
      }
    );

    return () => subscription.remove();
  }, []);

  // Connection state is managed automatically by Convex
  // Just show indicator if needed
  if (connectionState === "reconnecting") {
    return <ReconnectingBanner />;
  }

  return null;
}
```

### Offline Detection
```tsx
import NetInfo from "@react-native-community/netinfo";
import { useEffect, useState } from "react";

export function useNetworkStatus() {
  const [isOnline, setIsOnline] = useState(true);

  useEffect(() => {
    return NetInfo.addEventListener((state) => {
      setIsOnline(state.isConnected ?? false);
    });
  }, []);

  return isOnline;
}

// Usage
export function DataScreen() {
  const isOnline = useNetworkStatus();
  const data = useQuery(api.data.get);

  if (!isOnline) {
    return <OfflineBanner />;
  }

  if (data === undefined) {
    return <Loading />;
  }

  return <DataView data={data} />;
}
```

---

## Optimistic Updates (Mobile)

```tsx
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";
import { Pressable, Text, StyleSheet } from "react-native";
import Haptics from "expo-haptics";

export function LikeButton({ postId, initialLiked }: Props) {
  const [optimisticLiked, setOptimisticLiked] = useState(initialLiked);
  const toggleLike = useMutation(api.posts.toggleLike);

  const handlePress = async () => {
    // Immediate haptic feedback
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);

    // Optimistic update
    setOptimisticLiked(!optimisticLiked);

    try {
      const result = await toggleLike({ postId });
      setOptimisticLiked(result.liked);
    } catch (error) {
      // Revert on error
      setOptimisticLiked(optimisticLiked);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
    }
  };

  return (
    <Pressable onPress={handlePress} style={styles.button}>
      <Text style={optimisticLiked ? styles.liked : styles.unliked}>
        {optimisticLiked ? "❤️" : "🤍"}
      </Text>
    </Pressable>
  );
}
```

---

## File Upload (Mobile)

```tsx
import * as ImagePicker from "expo-image-picker";
import { useMutation } from "convex/react";
import { api } from "@/convex/_generated/api";

export function ImageUploader() {
  const generateUploadUrl = useMutation(api.files.generateUploadUrl);
  const saveFile = useMutation(api.files.saveFile);
  const [uploading, setUploading] = useState(false);

  const pickAndUpload = async () => {
    const result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      quality: 0.8,
    });

    if (result.canceled) return;

    const asset = result.assets[0];
    setUploading(true);

    try {
      // Get upload URL
      const uploadUrl = await generateUploadUrl();

      // Upload file
      const response = await fetch(uploadUrl, {
        method: "POST",
        headers: {
          "Content-Type": asset.mimeType ?? "image/jpeg",
        },
        body: await fetch(asset.uri).then((r) => r.blob()),
      });

      const { storageId } = await response.json();

      // Save to database
      await saveFile({
        storageId,
        filename: asset.fileName ?? "image.jpg",
        mimeType: asset.mimeType ?? "image/jpeg",
      });

      Alert.alert("Success", "Image uploaded!");
    } catch (error) {
      Alert.alert("Error", "Upload failed");
    } finally {
      setUploading(false);
    }
  };

  return (
    <Button
      title={uploading ? "Uploading..." : "Upload Image"}
      onPress={pickAndUpload}
      disabled={uploading}
    />
  );
}
```

---

## Auth Flow (Clerk Mobile)

```tsx
// app/sign-in.tsx
import { useSignIn } from "@clerk/clerk-expo";
import { useRouter } from "expo-router";
import { useState } from "react";
import { View, TextInput, Button, Text } from "react-native";

export default function SignInScreen() {
  const { signIn, setActive, isLoaded } = useSignIn();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSignIn = async () => {
    if (!isLoaded) return;

    try {
      const result = await signIn.create({
        identifier: email,
        password,
      });

      if (result.status === "complete") {
        await setActive({ session: result.createdSessionId });
        router.replace("/");
      }
    } catch (err: any) {
      setError(err.errors?.[0]?.message ?? "Sign in failed");
    }
  };

  return (
    <View style={styles.container}>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
      />
      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
      />
      {error && <Text style={styles.error}>{error}</Text>}
      <Button title="Sign In" onPress={handleSignIn} />
    </View>
  );
}
```

---

## Pull-to-Refresh Pattern

```tsx
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";
import { FlatList, RefreshControl } from "react-native";
import { useState, useCallback } from "react";

export function PostList() {
  const posts = useQuery(api.posts.list);
  const [refreshing, setRefreshing] = useState(false);

  // Convex queries are real-time, so data is always fresh
  // Pull-to-refresh is just for user feedback
  const onRefresh = useCallback(() => {
    setRefreshing(true);
    // Data refreshes automatically, just show spinner briefly
    setTimeout(() => setRefreshing(false), 500);
  }, []);

  if (posts === undefined) {
    return <Loading />;
  }

  return (
    <FlatList
      data={posts}
      renderItem={({ item }) => <PostCard post={item} />}
      keyExtractor={(item) => item._id}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    />
  );
}
```

---

## Background Sync Considerations

Convex handles sync automatically, but on mobile you may want to:

### Prefetch on App Resume
```tsx
import { useEffect } from "react";
import { AppState } from "react-native";
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function usePrefetchOnResume() {
  // These queries will auto-sync when component mounts
  const profile = useQuery(api.profiles.getMyProfile);
  const notifications = useQuery(api.notifications.getUnread);

  useEffect(() => {
    const subscription = AppState.addEventListener("change", (state) => {
      if (state === "active") {
        // Convex reconnects automatically
        // Queries will update with fresh data
        console.log("App resumed, data syncing...");
      }
    });

    return () => subscription.remove();
  }, []);

  return { profile, notifications };
}
```

### Local Cache (AsyncStorage)
```tsx
import AsyncStorage from "@react-native-async-storage/async-storage";
import { useEffect, useState } from "react";
import { useQuery } from "convex/react";
import { api } from "@/convex/_generated/api";

export function useCachedData() {
  const [cachedData, setCachedData] = useState<Data | null>(null);
  const serverData = useQuery(api.data.get);

  // Load cached data immediately
  useEffect(() => {
    AsyncStorage.getItem("cached_data").then((data) => {
      if (data) setCachedData(JSON.parse(data));
    });
  }, []);

  // Update cache when server data arrives
  useEffect(() => {
    if (serverData) {
      AsyncStorage.setItem("cached_data", JSON.stringify(serverData));
      setCachedData(serverData);
    }
  }, [serverData]);

  // Return cached data if server hasn't responded yet
  return serverData ?? cachedData;
}
```

---

## Performance Tips

1. **Memoize the ConvexReactClient** — Create once at app startup
2. **Use `skip` for conditional queries** — Avoid unnecessary subscriptions
3. **Batch related data** — Fetch in single query when possible
4. **Limit real-time subscriptions** — Only subscribe to what's visible
5. **Use pagination** — Don't load entire collections on mobile

```tsx
// Only subscribe when screen is focused
import { useIsFocused } from "@react-navigation/native";

export function NotificationsScreen() {
  const isFocused = useIsFocused();
  
  // Skip subscription when screen is not visible
  const notifications = useQuery(
    api.notifications.getRecent,
    isFocused ? { limit: 20 } : "skip"
  );

  // ...
}
```

---

## Testing

```typescript
// __tests__/Profile.test.tsx
import { render, waitFor } from "@testing-library/react-native";
import { ConvexProvider, ConvexReactClient } from "convex/react";
import { ProfileScreen } from "../ProfileScreen";

// Mock the Convex client
const mockClient = {
  // ... mock implementation
};

test("shows profile data", async () => {
  const { getByText } = render(
    <ConvexProvider client={mockClient as any}>
      <ProfileScreen />
    </ConvexProvider>
  );

  await waitFor(() => {
    expect(getByText("John Doe")).toBeTruthy();
  });
});
```
