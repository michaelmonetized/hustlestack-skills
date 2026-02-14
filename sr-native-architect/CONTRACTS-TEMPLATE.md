# Mobile API Contracts

> Define all data shapes BEFORE implementation. Screen components and stores reference this document.

---

## Users

### Local Schema (Zustand + MMKV)

```typescript
// src/stores/userStore.ts
interface User {
  id: string;
  email: string;
  name: string;
  avatarUrl?: string;
  tier: 'free' | 'pro' | 'premium';
  preferences: UserPreferences;
  createdAt: number;
  _syncedAt?: number;
  _pendingChanges?: boolean;
}

interface UserPreferences {
  theme: 'light' | 'dark' | 'system';
  notifications: boolean;
  haptics: boolean;
  biometricAuth: boolean;
}
```

### API Endpoints

#### GET /users/:id
- **Response:** `User`
- **Offline:** Return from local store
- **Used by:** Profile screen, settings

#### PATCH /users/:id
- **Request:** `Partial<Pick<User, 'name' | 'avatarUrl' | 'preferences'>>`
- **Response:** `User`
- **Offline:** Queue mutation, update optimistically
- **Used by:** Settings form, profile edit

#### POST /users/:id/avatar
- **Request:** `FormData { file: Blob }`
- **Response:** `{ avatarUrl: string }`
- **Offline:** Queue with file reference
- **Used by:** Avatar picker

---

## [Entity Name]

### Local Schema

```typescript
// src/types/[entity].ts
interface EntityName {
  id: string;
  // fields
  createdAt: number;
  updatedAt: number;
  // Sync metadata
  _syncStatus: 'synced' | 'pending' | 'conflict';
  _localId?: string; // For items created offline
}
```

### API Endpoints

#### GET /entities
- **Query params:** `{ limit?: number, cursor?: string, filter?: string }`
- **Response:** `{ items: EntityName[], nextCursor: string | null }`
- **Offline:** Return cached list, mark stale
- **Used by:** List screen

#### GET /entities/:id
- **Response:** `EntityName`
- **Offline:** Return from cache or error
- **Used by:** Detail screen

#### POST /entities
- **Request:** `CreateEntityInput`
- **Response:** `EntityName`
- **Offline:** Create with local ID, queue sync
- **Used by:** Create form

#### PATCH /entities/:id
- **Request:** `Partial<EntityName>`
- **Response:** `EntityName`
- **Offline:** Update local, queue sync
- **Used by:** Edit form

#### DELETE /entities/:id
- **Response:** `void`
- **Offline:** Mark as deleted, queue sync
- **Used by:** Delete action

---

## Sync Strategy

### Priority Levels

| Priority | Sync Behavior | Examples |
|----------|--------------|----------|
| Critical | Sync immediately when online | Payments, auth |
| High | Sync within 30s of connectivity | User data, important actions |
| Normal | Sync in background batch | Content updates, preferences |
| Low | Sync on app foreground only | Analytics, read markers |

### Conflict Resolution

| Scenario | Resolution |
|----------|-----------|
| Server newer | Server wins, notify user |
| Local newer | Local wins, push to server |
| Both changed | Show conflict UI, user decides |
| Delete vs Edit | Delete wins (can be configured) |

---

## Screen → API Mapping

| Screen | Queries | Mutations | Offline Behavior |
|--------|---------|-----------|-----------------|
| HomeScreen | entities.list | - | Show cached, refresh badge |
| DetailScreen | entities.get | entities.update | Show cached or error |
| CreateScreen | - | entities.create | Create local, queue sync |
| ProfileScreen | users.get | users.update | Show cached, queue changes |
| SettingsScreen | users.get | users.update | Immediate local update |

---

## Store Structure

```typescript
// src/stores/index.ts

// Authentication (always persisted)
export { useAuthStore } from './authStore';

// User data (persisted with sync)
export { useUserStore } from './userStore';

// Entity stores (persisted with sync)
export { useEntityStore } from './entityStore';

// UI state (not persisted)
export { useUIStore } from './uiStore';

// Network/sync state (not persisted)
export { useSyncStore } from './syncStore';
```

---

## Type Exports

```typescript
// src/types/index.ts

// API types
export type { User, UserPreferences } from './user';
export type { EntityName, CreateEntityInput } from './entity';

// Navigation types
export type { RootStackParamList } from './navigation';

// Store types
export type { AuthState } from '../stores/authStore';

// API response wrappers
export interface ApiResponse<T> {
  data: T;
  error: null;
}

export interface ApiError {
  data: null;
  error: {
    code: string;
    message: string;
  };
}

export type ApiResult<T> = ApiResponse<T> | ApiError;

// Pagination
export interface PaginatedResponse<T> {
  items: T[];
  nextCursor: string | null;
  total?: number;
}
```

---

## Validation Schemas

```typescript
// src/lib/validations/user.ts
import { z } from 'zod';

export const userPreferencesSchema = z.object({
  theme: z.enum(['light', 'dark', 'system']),
  notifications: z.boolean(),
  haptics: z.boolean(),
  biometricAuth: z.boolean(),
});

export const updateUserSchema = z.object({
  name: z.string().min(2).max(50).optional(),
  avatarUrl: z.string().url().optional(),
  preferences: userPreferencesSchema.partial().optional(),
});

export type UpdateUserInput = z.infer<typeof updateUserSchema>;
```

---

## Notes

- All timestamps are Unix milliseconds (`Date.now()`)
- IDs are UUIDs unless specified otherwise
- Offline-first: every query has a cache-first strategy
- Optimistic updates for all mutations
- Sync metadata (`_syncStatus`, `_localId`) stripped before API calls
- Local IDs prefixed with `local_` until synced
