# Native Architecture Patterns

> Production-ready patterns for React Native and Expo apps.

---

## Table of Contents

1. [State Management](#1-state-management)
2. [Offline-First Architecture](#2-offline-first-architecture)
3. [Navigation Patterns](#3-navigation-patterns)
4. [Platform Abstraction](#4-platform-abstraction)
5. [Performance Patterns](#5-performance-patterns)
6. [Native Module Integration](#6-native-module-integration)
7. [Monorepo Strategies](#7-monorepo-strategies)
8. [Testing Patterns](#8-testing-patterns)

---

## 1. State Management

### Zustand + MMKV (Recommended Stack)

```typescript
// src/stores/authStore.ts
import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

const mmkvStorage = {
  getItem: (name: string) => {
    const value = storage.getString(name);
    return value ?? null;
  },
  setItem: (name: string, value: string) => {
    storage.set(name, value);
  },
  removeItem: (name: string) => {
    storage.delete(name);
  },
};

interface AuthState {
  token: string | null;
  user: User | null;
  isAuthenticated: boolean;
  setAuth: (token: string, user: User) => void;
  clearAuth: () => void;
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      token: null,
      user: null,
      isAuthenticated: false,
      setAuth: (token, user) => 
        set({ token, user, isAuthenticated: true }),
      clearAuth: () => 
        set({ token: null, user: null, isAuthenticated: false }),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => mmkvStorage),
    }
  )
);
```

### Jotai for Atomic State

```typescript
// src/stores/atoms.ts
import { atom } from 'jotai';
import { atomWithStorage, createJSONStorage } from 'jotai/utils';
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

const mmkvStorage = createJSONStorage(() => ({
  getItem: (key: string) => storage.getString(key) ?? null,
  setItem: (key: string, value: string) => storage.set(key, value),
  removeItem: (key: string) => storage.delete(key),
}));

// Persistent atom
export const themeAtom = atomWithStorage<'light' | 'dark'>(
  'theme',
  'light',
  mmkvStorage
);

// Derived atom
export const isDarkModeAtom = atom(
  (get) => get(themeAtom) === 'dark'
);

// Async atom with TanStack Query integration
export const userQueryAtom = atomWithQuery((get) => ({
  queryKey: ['user', get(userIdAtom)],
  queryFn: () => fetchUser(get(userIdAtom)),
}));
```

### TanStack Query for Server State

```typescript
// src/services/api/queries.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { api } from './client';

// Query with offline support
export function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => api.getUser(userId),
    staleTime: 5 * 60 * 1000, // 5 minutes
    gcTime: 24 * 60 * 60 * 1000, // 24 hours (for offline)
    networkMode: 'offlineFirst',
  });
}

// Optimistic mutation
export function useUpdateUser() {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: api.updateUser,
    onMutate: async (newUser) => {
      await queryClient.cancelQueries({ queryKey: ['user', newUser.id] });
      
      const previousUser = queryClient.getQueryData(['user', newUser.id]);
      
      queryClient.setQueryData(['user', newUser.id], newUser);
      
      return { previousUser };
    },
    onError: (err, newUser, context) => {
      queryClient.setQueryData(
        ['user', newUser.id],
        context?.previousUser
      );
    },
    onSettled: (data, error, variables) => {
      queryClient.invalidateQueries({ queryKey: ['user', variables.id] });
    },
  });
}
```

### State Selection Pattern

```
┌─────────────────────────────────────────────────────────────────┐
│                   STATE TYPE DECISION TREE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Is it server data (fetched from API)?                          │
│     ├── YES → TanStack Query                                    │
│     └── NO  → Is it persisted locally?                          │
│                  ├── YES → Zustand + MMKV or Jotai + MMKV       │
│                  └── NO  → Is it shared across components?       │
│                               ├── YES → Zustand or Jotai        │
│                               └── NO  → useState / useReducer   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Offline-First Architecture

### Network Status Hook

```typescript
// src/hooks/useNetworkStatus.ts
import { useEffect, useState } from 'react';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';

interface NetworkStatus {
  isConnected: boolean;
  isInternetReachable: boolean | null;
  type: string;
}

export function useNetworkStatus(): NetworkStatus {
  const [status, setStatus] = useState<NetworkStatus>({
    isConnected: true,
    isInternetReachable: true,
    type: 'unknown',
  });

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener((state: NetInfoState) => {
      setStatus({
        isConnected: state.isConnected ?? false,
        isInternetReachable: state.isInternetReachable,
        type: state.type,
      });
    });

    return unsubscribe;
  }, []);

  return status;
}
```

### Offline Queue Pattern

```typescript
// src/services/offlineQueue.ts
import { MMKV } from 'react-native-mmkv';
import NetInfo from '@react-native-community/netinfo';

const storage = new MMKV();
const QUEUE_KEY = 'offline_queue';

interface QueuedAction {
  id: string;
  type: string;
  payload: unknown;
  timestamp: number;
  retries: number;
}

class OfflineQueue {
  private isProcessing = false;

  async enqueue(action: Omit<QueuedAction, 'id' | 'timestamp' | 'retries'>) {
    const queue = this.getQueue();
    
    const queuedAction: QueuedAction = {
      ...action,
      id: crypto.randomUUID(),
      timestamp: Date.now(),
      retries: 0,
    };
    
    queue.push(queuedAction);
    storage.set(QUEUE_KEY, JSON.stringify(queue));
    
    this.processQueue();
  }

  private getQueue(): QueuedAction[] {
    const data = storage.getString(QUEUE_KEY);
    return data ? JSON.parse(data) : [];
  }

  private saveQueue(queue: QueuedAction[]) {
    storage.set(QUEUE_KEY, JSON.stringify(queue));
  }

  async processQueue() {
    if (this.isProcessing) return;
    
    const state = await NetInfo.fetch();
    if (!state.isConnected) return;

    this.isProcessing = true;
    const queue = this.getQueue();
    
    for (const action of queue) {
      try {
        await this.processAction(action);
        this.removeFromQueue(action.id);
      } catch (error) {
        if (action.retries >= 3) {
          this.removeFromQueue(action.id);
          // Log to error tracking
        } else {
          this.incrementRetry(action.id);
        }
      }
    }
    
    this.isProcessing = false;
  }

  private async processAction(action: QueuedAction) {
    // Route to appropriate handler based on action.type
    const handlers: Record<string, (payload: unknown) => Promise<void>> = {
      CREATE_POST: (p) => api.createPost(p as CreatePostPayload),
      UPDATE_USER: (p) => api.updateUser(p as UpdateUserPayload),
      // Add more handlers
    };
    
    const handler = handlers[action.type];
    if (handler) {
      await handler(action.payload);
    }
  }

  private removeFromQueue(id: string) {
    const queue = this.getQueue().filter(a => a.id !== id);
    this.saveQueue(queue);
  }

  private incrementRetry(id: string) {
    const queue = this.getQueue().map(a => 
      a.id === id ? { ...a, retries: a.retries + 1 } : a
    );
    this.saveQueue(queue);
  }
}

export const offlineQueue = new OfflineQueue();

// Start processing when network comes back
NetInfo.addEventListener((state) => {
  if (state.isConnected) {
    offlineQueue.processQueue();
  }
});
```

### Sync Engine Pattern

```typescript
// src/services/sync/syncEngine.ts
import { MMKV } from 'react-native-mmkv';

const storage = new MMKV();

interface SyncMeta {
  lastSyncAt: number;
  version: number;
}

interface SyncableEntity {
  id: string;
  updatedAt: number;
  _deleted?: boolean;
  _syncStatus?: 'pending' | 'synced' | 'conflict';
}

class SyncEngine<T extends SyncableEntity> {
  constructor(
    private entityName: string,
    private api: {
      fetchChanges: (since: number) => Promise<T[]>;
      pushChanges: (items: T[]) => Promise<T[]>;
    }
  ) {}

  private getStorageKey(key: string) {
    return `sync_${this.entityName}_${key}`;
  }

  private getMeta(): SyncMeta {
    const data = storage.getString(this.getStorageKey('meta'));
    return data ? JSON.parse(data) : { lastSyncAt: 0, version: 0 };
  }

  private saveMeta(meta: SyncMeta) {
    storage.set(this.getStorageKey('meta'), JSON.stringify(meta));
  }

  private getLocalData(): T[] {
    const data = storage.getString(this.getStorageKey('data'));
    return data ? JSON.parse(data) : [];
  }

  private saveLocalData(items: T[]) {
    storage.set(this.getStorageKey('data'), JSON.stringify(items));
  }

  async sync(): Promise<{ pulled: number; pushed: number; conflicts: T[] }> {
    const meta = this.getMeta();
    const localData = this.getLocalData();
    
    // Get pending local changes
    const pendingChanges = localData.filter(
      item => item._syncStatus === 'pending'
    );
    
    // Push local changes first
    let pushedItems: T[] = [];
    if (pendingChanges.length > 0) {
      pushedItems = await this.api.pushChanges(pendingChanges);
    }
    
    // Pull remote changes
    const remoteChanges = await this.api.fetchChanges(meta.lastSyncAt);
    
    // Merge changes with conflict detection
    const { merged, conflicts } = this.mergeChanges(
      localData,
      remoteChanges,
      pushedItems
    );
    
    // Save merged data
    this.saveLocalData(merged);
    this.saveMeta({
      lastSyncAt: Date.now(),
      version: meta.version + 1,
    });
    
    return {
      pulled: remoteChanges.length,
      pushed: pushedItems.length,
      conflicts,
    };
  }

  private mergeChanges(
    local: T[],
    remote: T[],
    pushed: T[]
  ): { merged: T[]; conflicts: T[] } {
    const conflicts: T[] = [];
    const merged = new Map<string, T>();
    
    // Add all local items
    local.forEach(item => merged.set(item.id, item));
    
    // Update with pushed items (now synced)
    pushed.forEach(item => {
      merged.set(item.id, { ...item, _syncStatus: 'synced' as const });
    });
    
    // Merge remote items
    remote.forEach(remoteItem => {
      const localItem = merged.get(remoteItem.id);
      
      if (!localItem) {
        // New remote item
        merged.set(remoteItem.id, { ...remoteItem, _syncStatus: 'synced' as const });
      } else if (localItem._syncStatus === 'pending') {
        // Conflict: local pending change vs remote change
        if (localItem.updatedAt !== remoteItem.updatedAt) {
          conflicts.push(remoteItem);
          merged.set(remoteItem.id, { ...localItem, _syncStatus: 'conflict' as const });
        }
      } else {
        // Take remote version
        merged.set(remoteItem.id, { ...remoteItem, _syncStatus: 'synced' as const });
      }
    });
    
    return {
      merged: Array.from(merged.values()),
      conflicts,
    };
  }
}

export { SyncEngine };
```

---

## 3. Navigation Patterns

### Type-Safe Expo Router

```typescript
// src/types/navigation.ts
export type RootStackParamList = {
  '(tabs)': undefined;
  '(auth)': undefined;
  '(modals)/settings': { section?: 'account' | 'privacy' };
  'profile/[id]': { id: string };
  'post/[id]': { id: string; commentId?: string };
};

// Usage with useLocalSearchParams
import { useLocalSearchParams } from 'expo-router';

export default function ProfileScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  // id is typed as string
}

// Typed navigation
import { router } from 'expo-router';

// Type-safe push
router.push({
  pathname: '/profile/[id]',
  params: { id: '123' },
});

// Type-safe replace
router.replace('/sign-in');
```

### Deep Link Configuration

```typescript
// app.json
{
  "expo": {
    "scheme": "myapp",
    "ios": {
      "associatedDomains": ["applinks:myapp.com"]
    },
    "android": {
      "intentFilters": [
        {
          "action": "VIEW",
          "autoVerify": true,
          "data": [
            {
              "scheme": "https",
              "host": "myapp.com",
              "pathPrefix": "/"
            }
          ],
          "category": ["BROWSABLE", "DEFAULT"]
        }
      ]
    }
  }
}
```

```typescript
// src/lib/linking.ts
import * as Linking from 'expo-linking';
import { router } from 'expo-router';

export function setupDeepLinks() {
  // Handle initial URL
  Linking.getInitialURL().then((url) => {
    if (url) handleDeepLink(url);
  });

  // Handle URLs when app is open
  Linking.addEventListener('url', ({ url }) => {
    handleDeepLink(url);
  });
}

function handleDeepLink(url: string) {
  const parsed = Linking.parse(url);
  
  // Map paths to routes
  const pathMappings: Record<string, string> = {
    '/profile': '/profile/[id]',
    '/post': '/post/[id]',
    '/invite': '/(modals)/invite',
  };
  
  const route = pathMappings[parsed.path ?? ''];
  if (route) {
    router.push({
      pathname: route,
      params: parsed.queryParams,
    });
  }
}
```

### Auth-Protected Routes

```typescript
// app/_layout.tsx
import { Slot, useRouter, useSegments } from 'expo-router';
import { useEffect } from 'react';
import { useAuthStore } from '@/stores/authStore';

export default function RootLayout() {
  const { isAuthenticated, isLoading } = useAuthStore();
  const segments = useSegments();
  const router = useRouter();

  useEffect(() => {
    if (isLoading) return;

    const inAuthGroup = segments[0] === '(auth)';

    if (!isAuthenticated && !inAuthGroup) {
      router.replace('/sign-in');
    } else if (isAuthenticated && inAuthGroup) {
      router.replace('/');
    }
  }, [isAuthenticated, segments, isLoading]);

  if (isLoading) {
    return <SplashScreen />;
  }

  return <Slot />;
}
```

### Tab Bar with Custom Design

```typescript
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { BlurView } from 'expo-blur';
import { Platform, StyleSheet } from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import { Home, Search, User } from 'lucide-react-native';

export default function TabLayout() {
  const insets = useSafeAreaInsets();

  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarStyle: {
          position: 'absolute',
          height: 60 + insets.bottom,
          paddingBottom: insets.bottom,
          ...Platform.select({
            ios: {
              backgroundColor: 'transparent',
            },
            android: {
              backgroundColor: '#000',
            },
          }),
        },
        tabBarBackground: () =>
          Platform.OS === 'ios' ? (
            <BlurView intensity={100} style={StyleSheet.absoluteFill} />
          ) : null,
        tabBarActiveTintColor: '#007AFF',
        tabBarInactiveTintColor: '#8E8E93',
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => <Home size={size} color={color} />,
        }}
      />
      <Tabs.Screen
        name="search"
        options={{
          title: 'Search',
          tabBarIcon: ({ color, size }) => <Search size={size} color={color} />,
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => <User size={size} color={color} />,
        }}
      />
    </Tabs>
  );
}
```

---

## 4. Platform Abstraction

### Platform-Specific Files

```
src/
├── components/
│   ├── DatePicker/
│   │   ├── DatePicker.tsx          # Shared logic/types
│   │   ├── DatePicker.ios.tsx      # iOS implementation
│   │   ├── DatePicker.android.tsx  # Android implementation
│   │   └── index.ts                # Re-export
```

```typescript
// src/components/DatePicker/DatePicker.tsx (shared types)
export interface DatePickerProps {
  value: Date;
  onChange: (date: Date) => void;
  minimumDate?: Date;
  maximumDate?: Date;
  mode?: 'date' | 'time' | 'datetime';
}

// src/components/DatePicker/DatePicker.ios.tsx
import DateTimePicker from '@react-native-community/datetimepicker';
import type { DatePickerProps } from './DatePicker';

export function DatePicker({ value, onChange, ...props }: DatePickerProps) {
  return (
    <DateTimePicker
      value={value}
      onChange={(_, date) => date && onChange(date)}
      display="spinner"
      {...props}
    />
  );
}

// src/components/DatePicker/DatePicker.android.tsx
import { useState } from 'react';
import { Pressable, Text } from 'react-native';
import DateTimePicker from '@react-native-community/datetimepicker';
import type { DatePickerProps } from './DatePicker';

export function DatePicker({ value, onChange, ...props }: DatePickerProps) {
  const [show, setShow] = useState(false);

  return (
    <>
      <Pressable onPress={() => setShow(true)}>
        <Text>{value.toLocaleDateString()}</Text>
      </Pressable>
      {show && (
        <DateTimePicker
          value={value}
          onChange={(_, date) => {
            setShow(false);
            date && onChange(date);
          }}
          {...props}
        />
      )}
    </>
  );
}

// src/components/DatePicker/index.ts
export { DatePicker } from './DatePicker';
export type { DatePickerProps } from './DatePicker';
```

### Platform Utilities

```typescript
// src/lib/platform.ts
import { Platform, Dimensions, StatusBar } from 'react-native';
import Constants from 'expo-constants';

export const isIOS = Platform.OS === 'ios';
export const isAndroid = Platform.OS === 'android';
export const isWeb = Platform.OS === 'web';

export const { width: SCREEN_WIDTH, height: SCREEN_HEIGHT } = 
  Dimensions.get('window');

export const STATUS_BAR_HEIGHT = Platform.select({
  ios: Constants.statusBarHeight,
  android: StatusBar.currentHeight ?? 0,
  default: 0,
});

export const IS_SMALL_DEVICE = SCREEN_WIDTH < 375;
export const IS_TABLET = SCREEN_WIDTH >= 768;

// Platform-specific values
export function select<T>(specifics: {
  ios?: T;
  android?: T;
  web?: T;
  default: T;
}): T {
  return Platform.select({
    ios: specifics.ios ?? specifics.default,
    android: specifics.android ?? specifics.default,
    web: specifics.web ?? specifics.default,
    default: specifics.default,
  }) as T;
}

// Usage
const shadowStyle = select({
  ios: {
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
  },
  android: {
    elevation: 4,
  },
  default: {},
});
```

### Native Feature Detection

```typescript
// src/lib/capabilities.ts
import * as Device from 'expo-device';
import * as LocalAuthentication from 'expo-local-authentication';
import * as Notifications from 'expo-notifications';

interface DeviceCapabilities {
  hasBiometrics: boolean;
  biometricTypes: LocalAuthentication.AuthenticationType[];
  canSendNotifications: boolean;
  isPhysicalDevice: boolean;
  deviceType: 'phone' | 'tablet' | 'unknown';
}

export async function getDeviceCapabilities(): Promise<DeviceCapabilities> {
  const [hasHardware, biometricTypes, notificationStatus] = await Promise.all([
    LocalAuthentication.hasHardwareAsync(),
    LocalAuthentication.supportedAuthenticationTypesAsync(),
    Notifications.getPermissionsAsync(),
  ]);

  return {
    hasBiometrics: hasHardware && biometricTypes.length > 0,
    biometricTypes,
    canSendNotifications: notificationStatus.status === 'granted',
    isPhysicalDevice: Device.isDevice,
    deviceType: Device.deviceType === Device.DeviceType.TABLET 
      ? 'tablet' 
      : Device.deviceType === Device.DeviceType.PHONE 
        ? 'phone' 
        : 'unknown',
  };
}
```

---

## 5. Performance Patterns

### Optimized List Component

```typescript
// src/components/OptimizedList.tsx
import { memo, useCallback, useMemo } from 'react';
import { FlashList, ListRenderItem } from '@shopify/flash-list';
import { View, Text, StyleSheet, RefreshControl } from 'react-native';

interface OptimizedListProps<T> {
  data: T[];
  renderItem: (item: T) => React.ReactElement;
  keyExtractor: (item: T) => string;
  estimatedItemSize: number;
  onEndReached?: () => void;
  onRefresh?: () => void;
  isRefreshing?: boolean;
  isLoadingMore?: boolean;
  ListEmptyComponent?: React.ReactElement;
}

function OptimizedListInner<T>({
  data,
  renderItem,
  keyExtractor,
  estimatedItemSize,
  onEndReached,
  onRefresh,
  isRefreshing = false,
  isLoadingMore = false,
  ListEmptyComponent,
}: OptimizedListProps<T>) {
  // Memoize renderItem wrapper
  const renderItemCallback: ListRenderItem<T> = useCallback(
    ({ item }) => renderItem(item),
    [renderItem]
  );

  // Memoize key extractor
  const keyExtractorCallback = useCallback(
    (item: T) => keyExtractor(item),
    [keyExtractor]
  );

  // Memoize footer
  const ListFooter = useMemo(() => {
    if (!isLoadingMore) return null;
    return (
      <View style={styles.footer}>
        <Text>Loading more...</Text>
      </View>
    );
  }, [isLoadingMore]);

  // Memoize refresh control
  const refreshControl = useMemo(() => {
    if (!onRefresh) return undefined;
    return (
      <RefreshControl refreshing={isRefreshing} onRefresh={onRefresh} />
    );
  }, [onRefresh, isRefreshing]);

  return (
    <FlashList
      data={data}
      renderItem={renderItemCallback}
      keyExtractor={keyExtractorCallback}
      estimatedItemSize={estimatedItemSize}
      onEndReached={onEndReached}
      onEndReachedThreshold={0.5}
      refreshControl={refreshControl}
      ListFooterComponent={ListFooter}
      ListEmptyComponent={ListEmptyComponent}
      // Performance optimizations
      drawDistance={250}
      removeClippedSubviews={true}
    />
  );
}

// Memo wrapper for the generic component
export const OptimizedList = memo(OptimizedListInner) as typeof OptimizedListInner;

const styles = StyleSheet.create({
  footer: {
    padding: 16,
    alignItems: 'center',
  },
});
```

### Heavy Computation Patterns

```typescript
// src/hooks/useExpensiveComputation.ts
import { useMemo, useCallback, useRef, useEffect } from 'react';
import { InteractionManager } from 'react-native';

// Defer heavy work until after animations
export function useDeferredValue<T>(value: T): T {
  const [deferredValue, setDeferredValue] = useState(value);

  useEffect(() => {
    const handle = InteractionManager.runAfterInteractions(() => {
      setDeferredValue(value);
    });

    return () => handle.cancel();
  }, [value]);

  return deferredValue;
}

// Memoize expensive calculations
export function useExpensiveList<T>(
  items: T[],
  filterFn: (item: T) => boolean,
  sortFn: (a: T, b: T) => number
): T[] {
  return useMemo(() => {
    return items.filter(filterFn).sort(sortFn);
  }, [items, filterFn, sortFn]);
}

// Debounced callback for search/input
export function useDebouncedCallback<T extends (...args: any[]) => void>(
  callback: T,
  delay: number
): T {
  const timeoutRef = useRef<NodeJS.Timeout>();
  const callbackRef = useRef(callback);

  useEffect(() => {
    callbackRef.current = callback;
  }, [callback]);

  const debouncedCallback = useCallback(
    (...args: Parameters<T>) => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
      timeoutRef.current = setTimeout(() => {
        callbackRef.current(...args);
      }, delay);
    },
    [delay]
  ) as T;

  useEffect(() => {
    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, []);

  return debouncedCallback;
}
```

### Image Optimization

```typescript
// src/components/OptimizedImage.tsx
import { Image, ImageProps } from 'expo-image';
import { useState, memo } from 'react';
import { View, StyleSheet } from 'react-native';
import Animated, { FadeIn } from 'react-native-reanimated';

interface OptimizedImageProps extends Omit<ImageProps, 'source'> {
  uri: string;
  blurhash?: string;
  fallback?: string;
  width: number;
  height: number;
}

export const OptimizedImage = memo(function OptimizedImage({
  uri,
  blurhash,
  fallback,
  width,
  height,
  style,
  ...props
}: OptimizedImageProps) {
  const [hasError, setHasError] = useState(false);

  const source = hasError && fallback ? { uri: fallback } : { uri };

  return (
    <Animated.View entering={FadeIn.duration(200)}>
      <Image
        source={source}
        style={[{ width, height }, style]}
        placeholder={blurhash}
        contentFit="cover"
        transition={200}
        cachePolicy="memory-disk"
        onError={() => setHasError(true)}
        {...props}
      />
    </Animated.View>
  );
});
```

### Bundle Splitting with Lazy Loading

```typescript
// Lazy load heavy screens
import { lazy, Suspense } from 'react';
import { ActivityIndicator, View } from 'react-native';

const HeavyChartScreen = lazy(() => import('./screens/HeavyChartScreen'));

function LazyScreen() {
  return (
    <Suspense
      fallback={
        <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
          <ActivityIndicator size="large" />
        </View>
      }
    >
      <HeavyChartScreen />
    </Suspense>
  );
}
```

---

## 6. Native Module Integration

### When to Use Native Modules

| Scenario | Solution |
|----------|----------|
| Feature exists in Expo SDK | Use Expo package |
| Feature exists in community | Use community package |
| Custom native behavior needed | Create native module |
| Performance-critical code | Native module or JSI |
| Third-party SDK integration | Native module wrapper |

### Expo Modules API (Modern Approach)

```typescript
// modules/my-module/src/MyModule.ts
import { NativeModule, requireNativeModule } from 'expo-modules-core';

interface MyModuleInterface extends NativeModule {
  hello(name: string): string;
  getDeviceInfo(): Promise<DeviceInfo>;
}

interface DeviceInfo {
  model: string;
  osVersion: string;
}

export const MyModule = requireNativeModule<MyModuleInterface>('MyModule');
```

```swift
// modules/my-module/ios/MyModule.swift
import ExpoModulesCore

public class MyModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MyModule")

    Function("hello") { (name: String) -> String in
      return "Hello, \(name)!"
    }

    AsyncFunction("getDeviceInfo") { () -> [String: Any] in
      return [
        "model": UIDevice.current.model,
        "osVersion": UIDevice.current.systemVersion
      ]
    }
  }
}
```

```kotlin
// modules/my-module/android/src/main/java/expo/modules/mymodule/MyModule.kt
package expo.modules.mymodule

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import android.os.Build

class MyModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("MyModule")

    Function("hello") { name: String ->
      "Hello, $name!"
    }

    AsyncFunction("getDeviceInfo") {
      mapOf(
        "model" to Build.MODEL,
        "osVersion" to Build.VERSION.RELEASE
      )
    }
  }
}
```

### Using Native Modules

```typescript
// src/services/native/myModule.ts
import { MyModule } from '../../modules/my-module/src/MyModule';
import { Platform } from 'react-native';

export async function getDeviceInfo() {
  try {
    return await MyModule.getDeviceInfo();
  } catch (error) {
    console.error('Native module error:', error);
    // Fallback for web or errors
    return {
      model: Platform.OS,
      osVersion: 'unknown',
    };
  }
}

export function greet(name: string): string {
  return MyModule.hello(name);
}
```

---

## 7. Monorepo Strategies

### Turborepo Structure (Recommended)

```
my-app/
├── apps/
│   ├── mobile/              # React Native app
│   │   ├── app/             # Expo Router
│   │   ├── src/
│   │   ├── app.json
│   │   └── package.json
│   ├── web/                 # Next.js web app
│   │   ├── app/
│   │   ├── next.config.js
│   │   └── package.json
│   └── admin/               # Admin dashboard
│       └── package.json
├── packages/
│   ├── ui/                  # Shared UI components
│   │   ├── src/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.native.tsx  # RN-specific
│   │   │   └── index.ts
│   │   └── package.json
│   ├── api/                 # Shared API client
│   │   ├── src/
│   │   │   ├── client.ts
│   │   │   └── types.ts
│   │   └── package.json
│   ├── utils/               # Shared utilities
│   │   └── package.json
│   └── config/              # Shared config (eslint, tsconfig)
│       ├── eslint-preset.js
│       └── tsconfig.base.json
├── turbo.json
├── package.json
└── pnpm-workspace.yaml
```

### Package Configuration

```json
// packages/ui/package.json
{
  "name": "@myapp/ui",
  "version": "0.0.0",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": {
      "react-native": "./src/index.native.ts",
      "default": "./src/index.ts"
    }
  },
  "peerDependencies": {
    "react": "*",
    "react-native": "*"
  }
}
```

```yaml
# pnpm-workspace.yaml
packages:
  - 'apps/*'
  - 'packages/*'
```

```json
// turbo.json
{
  "$schema": "https://turbo.build/schema.json",
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**", ".expo/**"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "outputs": []
    },
    "typecheck": {
      "outputs": []
    }
  }
}
```

### Cross-Platform Component Pattern

```typescript
// packages/ui/src/Button.tsx (web)
import { forwardRef, ButtonHTMLAttributes } from 'react';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
}

export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'primary', size = 'md', children, ...props }, ref) => {
    return (
      <button
        ref={ref}
        className={`btn btn-${variant} btn-${size}`}
        {...props}
      >
        {children}
      </button>
    );
  }
);
```

```typescript
// packages/ui/src/Button.native.tsx (React Native)
import { forwardRef } from 'react';
import { 
  Pressable, 
  Text, 
  StyleSheet, 
  PressableProps,
  ViewStyle,
  TextStyle,
} from 'react-native';

export interface ButtonProps extends Omit<PressableProps, 'children'> {
  variant?: 'primary' | 'secondary';
  size?: 'sm' | 'md' | 'lg';
  children: string;
}

export const Button = forwardRef<any, ButtonProps>(
  ({ variant = 'primary', size = 'md', children, style, ...props }, ref) => {
    return (
      <Pressable
        ref={ref}
        style={({ pressed }) => [
          styles.base,
          styles[variant],
          styles[size],
          pressed && styles.pressed,
          style as ViewStyle,
        ]}
        {...props}
      >
        <Text style={[styles.text, styles[`${variant}Text`]]}>
          {children}
        </Text>
      </Pressable>
    );
  }
);

const styles = StyleSheet.create({
  base: {
    borderRadius: 8,
    alignItems: 'center',
    justifyContent: 'center',
  },
  primary: {
    backgroundColor: '#007AFF',
  },
  secondary: {
    backgroundColor: '#E5E5EA',
  },
  sm: {
    paddingVertical: 8,
    paddingHorizontal: 12,
  },
  md: {
    paddingVertical: 12,
    paddingHorizontal: 16,
  },
  lg: {
    paddingVertical: 16,
    paddingHorizontal: 24,
  },
  pressed: {
    opacity: 0.8,
  },
  text: {
    fontWeight: '600',
  },
  primaryText: {
    color: '#FFFFFF',
  },
  secondaryText: {
    color: '#000000',
  },
});
```

---

## 8. Testing Patterns

### Unit Testing with Jest

```typescript
// src/stores/__tests__/authStore.test.ts
import { renderHook, act } from '@testing-library/react-hooks';
import { useAuthStore } from '../authStore';

// Reset store between tests
beforeEach(() => {
  useAuthStore.setState({
    token: null,
    user: null,
    isAuthenticated: false,
  });
});

describe('authStore', () => {
  it('sets authentication state', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.setAuth('token123', { id: '1', name: 'Test' });
    });

    expect(result.current.isAuthenticated).toBe(true);
    expect(result.current.token).toBe('token123');
    expect(result.current.user?.name).toBe('Test');
  });

  it('clears authentication state', () => {
    const { result } = renderHook(() => useAuthStore());

    act(() => {
      result.current.setAuth('token123', { id: '1', name: 'Test' });
      result.current.clearAuth();
    });

    expect(result.current.isAuthenticated).toBe(false);
    expect(result.current.token).toBeNull();
  });
});
```

### Component Testing

```typescript
// src/components/__tests__/Button.test.tsx
import { render, fireEvent } from '@testing-library/react-native';
import { Button } from '../Button';

describe('Button', () => {
  it('renders correctly', () => {
    const { getByText } = render(<Button>Press me</Button>);
    expect(getByText('Press me')).toBeTruthy();
  });

  it('calls onPress when pressed', () => {
    const onPress = jest.fn();
    const { getByText } = render(
      <Button onPress={onPress}>Press me</Button>
    );

    fireEvent.press(getByText('Press me'));
    expect(onPress).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    const onPress = jest.fn();
    const { getByText } = render(
      <Button onPress={onPress} disabled>Press me</Button>
    );

    fireEvent.press(getByText('Press me'));
    expect(onPress).not.toHaveBeenCalled();
  });
});
```

### E2E Testing with Maestro

```yaml
# .maestro/flows/auth-flow.yaml
appId: com.myapp
---
- launchApp
- assertVisible: "Sign In"

# Sign in flow
- tapOn: "Email"
- inputText: "test@example.com"
- tapOn: "Password"
- inputText: "password123"
- tapOn: "Sign In"

# Verify navigation to home
- assertVisible: "Welcome"
- assertVisible: "Home"

# Sign out
- tapOn: "Profile"
- scrollUntilVisible: "Sign Out"
- tapOn: "Sign Out"
- assertVisible: "Sign In"
```

```yaml
# .maestro/flows/offline-flow.yaml
appId: com.myapp
---
- launchApp
- assertVisible: "Home"

# Create item while online
- tapOn: "Add Item"
- inputText: "Test Item"
- tapOn: "Save"
- assertVisible: "Test Item"

# Go offline and verify item persists
- setAirplaneMode: true
- stopApp
- launchApp
- assertVisible: "Test Item"
- assertVisible: "Offline"

# Make changes offline
- tapOn: "Test Item"
- tapOn: "Edit"
- clearText
- inputText: "Updated Item"
- tapOn: "Save"

# Go online and verify sync
- setAirplaneMode: false
- waitForAnimationToEnd
- assertNotVisible: "Offline"
- assertVisible: "Updated Item"
```

### Testing Hooks

```typescript
// src/hooks/__tests__/useNetworkStatus.test.ts
import { renderHook, waitFor } from '@testing-library/react-hooks';
import NetInfo from '@react-native-community/netinfo';
import { useNetworkStatus } from '../useNetworkStatus';

jest.mock('@react-native-community/netinfo');

describe('useNetworkStatus', () => {
  it('returns initial connected state', () => {
    (NetInfo.addEventListener as jest.Mock).mockImplementation((callback) => {
      callback({
        isConnected: true,
        isInternetReachable: true,
        type: 'wifi',
      });
      return () => {};
    });

    const { result } = renderHook(() => useNetworkStatus());

    expect(result.current.isConnected).toBe(true);
    expect(result.current.type).toBe('wifi');
  });

  it('updates when network changes', async () => {
    let listener: (state: any) => void;
    
    (NetInfo.addEventListener as jest.Mock).mockImplementation((callback) => {
      listener = callback;
      callback({ isConnected: true, isInternetReachable: true, type: 'wifi' });
      return () => {};
    });

    const { result } = renderHook(() => useNetworkStatus());

    // Simulate going offline
    listener({ isConnected: false, isInternetReachable: false, type: 'none' });

    await waitFor(() => {
      expect(result.current.isConnected).toBe(false);
    });
  });
});
```

---

## Quick Reference

### Commands

```bash
# Development
npx expo start                    # Start dev server
npx expo start --ios             # Start with iOS simulator
npx expo start --android         # Start with Android emulator
npx expo start --clear           # Clear cache and start

# Testing
bun test                         # Run unit tests
bun test --watch                 # Watch mode
maestro test .maestro/flows/     # Run E2E tests

# Building
eas build --profile development  # Dev build
eas build --profile preview      # TestFlight/Internal
eas build --profile production   # App Store/Play Store

# Submitting
eas submit --platform ios        # Submit to App Store
eas submit --platform android    # Submit to Play Store

# Updates
eas update --branch production   # OTA update
eas update --branch preview      # Preview update
```

### Performance Debugging

```bash
# Enable Hermes debugger
npx expo start --no-dev

# Profile with Flipper
# Install Flipper, add react-native-flipper

# Memory profiling
# Use Xcode Instruments / Android Studio Profiler
```
