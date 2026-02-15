# Convex + Swift Integration

Native iOS/macOS integration via HTTP client.

---

## ⚠️ Key Differences from Web

| Feature | Web (React) | Swift |
|---------|-------------|-------|
| Real-time | ✅ WebSocket subscriptions | ❌ Manual polling |
| Reactive | ✅ useQuery auto-updates | ❌ Manual refresh |
| Type generation | ✅ Automatic | ❌ Manual types |
| Auth | ✅ Token handled | ⚠️ Manual token management |

**When to use Swift directly:**
- Native iOS/macOS app without React Native
- Performance-critical sections
- Deep platform integration

**When to proxy through server:**
- Need real-time updates (use push notifications instead)
- Complex auth flows
- Rate limiting at API level

---

## convex-swift Package

### Installation (SPM)
```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/get-convex/convex-swift.git", from: "0.4.0")
]

// Or in Xcode: File → Add Package Dependencies
// URL: https://github.com/get-convex/convex-swift.git
```

### Basic Setup
```swift
import Convex

let client = ConvexClient(deploymentUrl: "https://your-project.convex.cloud")

// Optional: Set auth token
try await client.setAuth(token: jwtToken)
```

---

## Calling Functions

### Query
```swift
import Convex

struct Profile: Codable {
    let _id: String
    let name: String
    let email: String?
    let _creationTime: Double
}

func getProfile(userId: String) async throws -> Profile? {
    let client = ConvexClient(deploymentUrl: convexUrl)
    
    return try await client.query(
        "profiles:getById",
        args: ["userId": userId]
    )
}

// Usage
Task {
    if let profile = try await getProfile(userId: "user123") {
        print("Found: \(profile.name)")
    }
}
```

### Mutation
```swift
struct CreateProfileArgs: Codable {
    let name: String
    let email: String?
}

struct CreateProfileResult: Codable {
    let _id: String
}

func createProfile(name: String, email: String?) async throws -> String {
    let client = ConvexClient(deploymentUrl: convexUrl)
    try await client.setAuth(token: authToken)
    
    let result: CreateProfileResult = try await client.mutation(
        "profiles:create",
        args: CreateProfileArgs(name: name, email: email)
    )
    
    return result._id
}
```

### Action
```swift
struct SendEmailArgs: Codable {
    let to: String
    let subject: String
    let body: String
}

func sendEmail(to: String, subject: String, body: String) async throws -> Bool {
    let client = ConvexClient(deploymentUrl: convexUrl)
    try await client.setAuth(token: authToken)
    
    return try await client.action(
        "email:send",
        args: SendEmailArgs(to: to, subject: subject, body: body)
    )
}
```

---

## Type Definitions (Manual)

Since Swift doesn't have auto-generated types, define them manually:

```swift
// Models/ConvexTypes.swift

import Foundation

// MARK: - Common Types

typealias ConvexId = String
typealias ConvexTimestamp = Double

// MARK: - Profile

struct Profile: Codable, Identifiable {
    let _id: ConvexId
    let clerkId: String
    let name: String
    let email: String?
    let headline: String?
    let bio: String?
    let location: String?
    let avatarUrl: String?
    let plan: ProfilePlan
    let _creationTime: ConvexTimestamp
    let updatedAt: ConvexTimestamp
    
    var id: ConvexId { _id }
}

enum ProfilePlan: String, Codable {
    case free
    case pro
    case premium
    case enterprise
}

// MARK: - Post

struct Post: Codable, Identifiable {
    let _id: ConvexId
    let authorId: ConvexId
    let title: String
    let content: String
    let status: PostStatus
    let viewCount: Int
    let likeCount: Int
    let _creationTime: ConvexTimestamp
    let updatedAt: ConvexTimestamp
    let publishedAt: ConvexTimestamp?
    
    var id: ConvexId { _id }
}

enum PostStatus: String, Codable {
    case draft
    case published
    case archived
}

// MARK: - Pagination

struct PaginatedResult<T: Codable>: Codable {
    let items: [T]
    let nextCursor: String?
    let hasMore: Bool
}
```

---

## Auth Token Management

### With Clerk
```swift
import ClerkSDK

class ConvexService: ObservableObject {
    private var client: ConvexClient
    private var authToken: String?
    
    init() {
        client = ConvexClient(deploymentUrl: Config.convexUrl)
    }
    
    func updateAuth() async {
        do {
            // Get JWT from Clerk
            if let session = Clerk.shared.session {
                let token = try await session.getToken(template: "convex")
                self.authToken = token
                try await client.setAuth(token: token)
            } else {
                // Clear auth
                self.authToken = nil
                try await client.clearAuth()
            }
        } catch {
            print("Auth update failed: \(error)")
        }
    }
    
    func query<T: Codable>(_ name: String, args: Codable? = nil) async throws -> T {
        // Refresh token before query if needed
        await updateAuth()
        return try await client.query(name, args: args)
    }
    
    func mutation<T: Codable>(_ name: String, args: Codable) async throws -> T {
        await updateAuth()
        return try await client.mutation(name, args: args)
    }
}
```

### Custom Auth
```swift
class AuthManager: ObservableObject {
    @Published var token: String?
    
    private let keychain = KeychainHelper()
    
    func loadToken() {
        token = keychain.get("convex_token")
    }
    
    func saveToken(_ newToken: String) {
        keychain.set(newToken, forKey: "convex_token")
        token = newToken
    }
    
    func clearToken() {
        keychain.delete("convex_token")
        token = nil
    }
}

// Usage with ConvexClient
let client = ConvexClient(deploymentUrl: convexUrl)
if let token = authManager.token {
    try await client.setAuth(token: token)
}
```

---

## Polling Pattern (Simulating Real-Time)

Since Convex Swift doesn't support WebSocket subscriptions:

```swift
import SwiftUI
import Combine

class PostsViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let convex: ConvexService
    private var pollTimer: Timer?
    private let pollInterval: TimeInterval = 10.0  // 10 seconds
    
    init(convex: ConvexService = .shared) {
        self.convex = convex
    }
    
    func startPolling() {
        // Initial fetch
        Task { await fetchPosts() }
        
        // Start polling
        pollTimer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            Task { await self?.fetchPosts() }
        }
    }
    
    func stopPolling() {
        pollTimer?.invalidate()
        pollTimer = nil
    }
    
    @MainActor
    func fetchPosts() async {
        isLoading = posts.isEmpty  // Only show loading on first fetch
        
        do {
            let result: PaginatedResult<Post> = try await convex.query(
                "posts:list",
                args: ["limit": 20, "status": "published"]
            )
            posts = result.items
            error = nil
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func refresh() async {
        await fetchPosts()
    }
}

// Usage in SwiftUI
struct PostsView: View {
    @StateObject private var viewModel = PostsViewModel()
    
    var body: some View {
        List(viewModel.posts) { post in
            PostRow(post: post)
        }
        .refreshable {
            await viewModel.refresh()
        }
        .onAppear {
            viewModel.startPolling()
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }
}
```

---

## Background Fetch

```swift
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.yourapp.sync",
            using: nil
        ) { task in
            self.handleSync(task: task as! BGAppRefreshTask)
        }
        return true
    }
    
    func scheduleSync() {
        let request = BGAppRefreshTaskRequest(identifier: "com.yourapp.sync")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // 15 min
        
        try? BGTaskScheduler.shared.submit(request)
    }
    
    func handleSync(task: BGAppRefreshTask) {
        let syncTask = Task {
            do {
                let convex = ConvexService.shared
                
                // Fetch latest data
                let _: [Post] = try await convex.query("posts:getRecent", args: ["limit": 10])
                
                // Check for new notifications
                let notifications: [Notification] = try await convex.query("notifications:getUnread")
                
                if !notifications.isEmpty {
                    // Show local notification
                    scheduleLocalNotification(count: notifications.count)
                }
                
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
        
        task.expirationHandler = {
            syncTask.cancel()
        }
        
        scheduleSync()  // Reschedule
    }
}
```

---

## Push Notifications (Real-Time Alternative)

Instead of polling, use push notifications:

### Server-Side (Convex)
```typescript
// convex/notifications.ts
import { internalAction } from "./_generated/server";

export const sendPush = internalAction({
  args: {
    profileId: v.id("profiles"),
    title: v.string(),
    body: v.string(),
  },
  handler: async (ctx, args) => {
    // Get user's push token from database
    const profile = await ctx.runQuery(internal.profiles.getById, {
      id: args.profileId,
    });
    
    if (!profile?.pushToken) return;
    
    // Send via APNs
    await sendApnsPush(profile.pushToken, {
      title: args.title,
      body: args.body,
    });
  },
});
```

### Client-Side (Swift)
```swift
import UserNotifications

class PushManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = PushManager()
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func handleToken(_ token: Data) async {
        let tokenString = token.map { String(format: "%02x", $0) }.joined()
        
        // Save to Convex
        try? await ConvexService.shared.mutation(
            "profiles:savePushToken",
            args: ["token": tokenString]
        )
    }
}

// In AppDelegate
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Task {
        await PushManager.shared.handleToken(deviceToken)
    }
}
```

---

## Error Handling

```swift
enum ConvexError: Error {
    case unauthorized
    case notFound
    case validationError(String)
    case rateLimited(retryAfter: Date?)
    case networkError(Error)
    case decodingError(Error)
    case unknown(String)
}

extension ConvexService {
    func query<T: Codable>(_ name: String, args: Codable? = nil) async throws -> T {
        do {
            return try await client.query(name, args: args)
        } catch let error as ConvexClientError {
            throw mapError(error)
        } catch {
            throw ConvexError.networkError(error)
        }
    }
    
    private func mapError(_ error: ConvexClientError) -> ConvexError {
        switch error.code {
        case "UNAUTHORIZED":
            return .unauthorized
        case "NOT_FOUND":
            return .notFound
        case "VALIDATION_ERROR":
            return .validationError(error.message)
        case "RATE_LIMITED":
            return .rateLimited(retryAfter: error.retryAfter)
        default:
            return .unknown(error.message)
        }
    }
}

// Usage
func loadProfile() async {
    do {
        let profile: Profile = try await convex.query("profiles:getMyProfile")
        // Success
    } catch ConvexError.unauthorized {
        // Redirect to login
        await authManager.clearToken()
    } catch ConvexError.rateLimited(let retryAfter) {
        // Show rate limit message
        if let retryAfter {
            showRetryMessage(until: retryAfter)
        }
    } catch {
        // Generic error handling
        showError(error)
    }
}
```

---

## File Upload

```swift
struct FileUploadResult: Codable {
    let storageId: String
}

func uploadImage(_ image: UIImage) async throws -> String {
    guard let data = image.jpegData(compressionQuality: 0.8) else {
        throw ConvexError.validationError("Could not convert image")
    }
    
    // 1. Get upload URL
    let uploadUrl: String = try await convex.mutation("files:generateUploadUrl", args: [:])
    
    // 2. Upload to Convex storage
    var request = URLRequest(url: URL(string: uploadUrl)!)
    request.httpMethod = "POST"
    request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
    request.httpBody = data
    
    let (responseData, _) = try await URLSession.shared.data(for: request)
    let result = try JSONDecoder().decode(FileUploadResult.self, from: responseData)
    
    // 3. Save reference
    let fileId: String = try await convex.mutation(
        "files:saveFile",
        args: [
            "storageId": result.storageId,
            "filename": "photo.jpg",
            "mimeType": "image/jpeg"
        ]
    )
    
    return fileId
}
```

---

## SwiftUI Integration

### Repository Pattern
```swift
protocol ProfileRepository {
    func getProfile() async throws -> Profile?
    func updateProfile(name: String, bio: String?) async throws
}

class ConvexProfileRepository: ProfileRepository {
    private let convex: ConvexService
    
    init(convex: ConvexService = .shared) {
        self.convex = convex
    }
    
    func getProfile() async throws -> Profile? {
        try await convex.query("profiles:getMyProfile")
    }
    
    func updateProfile(name: String, bio: String?) async throws {
        let _: Void = try await convex.mutation(
            "profiles:update",
            args: ["name": name, "bio": bio]
        )
    }
}
```

### ViewModel
```swift
@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: Profile?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let repository: ProfileRepository
    
    init(repository: ProfileRepository = ConvexProfileRepository()) {
        self.repository = repository
    }
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            profile = try await repository.getProfile()
        } catch {
            self.error = error
        }
    }
    
    func save(name: String, bio: String?) async {
        do {
            try await repository.updateProfile(name: name, bio: bio)
            await load()  // Refresh
        } catch {
            self.error = error
        }
    }
}
```

### View
```swift
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let profile = viewModel.profile {
                ProfileContent(profile: profile, onSave: viewModel.save)
            } else {
                CreateProfileView()
            }
        }
        .task {
            await viewModel.load()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}
```

---

## When to Use Server Proxy

For complex operations, create a server endpoint:

```typescript
// Next.js API Route or Express endpoint
export async function POST(request: Request) {
  const { userId, action, data } = await request.json();
  
  // Validate, rate limit, etc.
  // Call Convex with server-side auth
  // Return result
}
```

```swift
// Swift calls your server, not Convex directly
let result = try await apiClient.post("/api/convex-proxy", body: [
    "action": "createPost",
    "data": postData
])
```

**Benefits:**
- Server handles auth token refresh
- Add rate limiting, validation, logging
- Cache responses
- Transform data formats
