# Expo Decision Guide

> Quick reference for Expo Managed vs Bare Workflow decisions.

---

## Decision Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     EXPO WORKFLOW DECISION TREE                          │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  Do you need custom native code or SDKs not in Expo SDK?                │
│     ├── YES → Need full native control?                                  │
│     │            ├── YES → Bare Workflow (prebuild/eject)               │
│     │            └── NO  → Expo Modules API (stay managed!)             │
│     └── NO  → Expo Managed Workflow ✓                                   │
│                                                                          │
│  Does the team have iOS/Android native experience?                      │
│     ├── YES → Either works, choose based on requirements                │
│     └── NO  → Strongly prefer Expo Managed                              │
│                                                                          │
│  Do you need OTA updates?                                               │
│     ├── YES → Expo Managed (EAS Update built-in)                        │
│     └── NO  → Either works                                              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Expo Managed Workflow

### ✅ When to Use

| Scenario | Reason |
|----------|--------|
| MVP / Prototype | Fastest to production |
| Standard app features | Camera, notifications, auth all covered |
| Team lacks native experience | No Xcode/Android Studio needed |
| Rapid iteration needed | OTA updates, fast dev cycle |
| Cross-platform consistency | Same code, same behavior |
| Solo developer | Less maintenance burden |

### ✅ What You Get

- **EAS Build** — Cloud builds, no local setup
- **EAS Update** — OTA JavaScript updates
- **EAS Submit** — Automated store submission
- **expo-dev-client** — Custom dev client with native modules
- **Expo Go** — Test without building (limited to SDK)
- **Config plugins** — Modify native projects without ejecting

### ❌ Limitations

- Expo SDK version pins native dependencies
- Some native libraries require config plugins
- App size baseline ~20-25MB
- Background tasks limited compared to bare

---

## Expo Bare Workflow (Prebuild)

### ✅ When to Use

| Scenario | Reason |
|----------|--------|
| Custom native modules | Bluetooth LE, hardware sensors |
| Proprietary SDKs | Payment processors, analytics |
| Performance-critical native code | Audio/video processing |
| Brownfield integration | Adding RN to existing native app |
| Specific native library versions | Managed pins incompatible versions |
| Full native control needed | Custom build steps, native configs |

### ✅ What You Get

- Full access to `ios/` and `android/` directories
- Any native library supported
- Custom native code in Swift/Kotlin
- Can still use EAS Build & EAS Update
- Expo modules still work

### ❌ Trade-offs

- Must maintain native projects
- Need native development experience
- Longer build times locally
- More complex CI/CD setup
- Easier to introduce native bugs

---

## Hybrid Approach: Config Plugins

**Before ejecting, try config plugins.** Many native modifications can be done without bare workflow:

```typescript
// app.config.ts
export default {
  expo: {
    plugins: [
      // Built-in plugins
      ['expo-camera', { cameraPermission: 'Allow camera for scanning' }],
      ['expo-notifications', { icon: './assets/notification-icon.png' }],
      
      // Community plugins
      'expo-build-properties',
      '@react-native-firebase/app',
      
      // Custom inline plugin
      [
        './plugins/withCustomEntitlements',
        { associatedDomains: ['applinks:myapp.com'] }
      ],
    ],
  },
};
```

### Common Config Plugin Use Cases

| Need | Solution |
|------|----------|
| Custom permissions text | `expo-camera`, `expo-location` plugin options |
| Firebase | `@react-native-firebase/app` |
| Background modes | `expo-background-task` or custom plugin |
| Associated domains | Custom plugin or `expo-apple-authentication` |
| Build properties | `expo-build-properties` |
| Custom schemes | Built into expo config |

---

## Migration Paths

### Managed → Bare (Prebuild)

```bash
# Generate native projects
npx expo prebuild

# You now have ios/ and android/ directories
# These are managed by Expo, regenerated from app.json/app.config.ts

# To fully eject (not recommended):
npx expo prebuild --clean
# Then manually maintain native directories
```

### Bare → Managed

Not typically possible without starting fresh. If you're on bare and want managed benefits:

1. Use EAS Build (works with bare projects)
2. Use EAS Update (works with bare projects)  
3. Consider starting a new managed project and migrating features

---

## Feature Comparison

| Feature | Managed | Bare |
|---------|---------|------|
| Expo SDK packages | ✅ Full | ✅ Full |
| EAS Build | ✅ Yes | ✅ Yes |
| EAS Update (OTA) | ✅ Yes | ✅ Yes |
| EAS Submit | ✅ Yes | ✅ Yes |
| Expo Go testing | ✅ Yes | ❌ No |
| Custom native code | ⚠️ Config plugins | ✅ Full access |
| Native project access | ❌ Abstracted | ✅ Full access |
| Community libraries | ⚠️ Need config plugin | ✅ All supported |
| Local builds | ⚠️ Requires prebuild | ✅ Native tooling |
| Maintenance burden | 🟢 Low | 🟡 Medium-High |

---

## Expo SDK Coverage Check

Before deciding, verify your requirements against Expo SDK:

### ✅ Fully Supported in SDK 52+

- Camera, Photos, Media Library
- Push Notifications (APNs, FCM)
- Location (foreground & background)
- Biometrics (Face ID, Touch ID, fingerprint)
- In-App Purchases (expo-in-app-purchases)
- Maps (expo-maps, react-native-maps)
- Audio/Video playback (expo-av)
- File System, SQLite, AsyncStorage
- Contacts, Calendar
- Haptics, Sensors (accelerometer, gyroscope)
- WebView, Browser
- Sharing, Clipboard
- Linking, Deep Links
- Background Fetch (limited)
- Task Manager

### ⚠️ Requires Config Plugin or Bare

- Custom Bluetooth LE
- NFC (beyond basic)
- Proprietary SDKs (Twilio, etc.)
- Custom background processing
- HealthKit / Google Fit (complex integration)
- ARKit / ARCore
- Specific native library versions

### ❌ Not in Expo SDK (Bare Required)

- Fully custom native UI components
- Low-level hardware access
- Inline C++/Rust code
- Integration with existing native app

---

## Quick Decision Checklist

```
□ List ALL native features required
□ Check each against Expo SDK (https://docs.expo.dev/versions/latest/)
□ For each unsupported feature, check for config plugin
□ Evaluate team's native development experience
□ Consider maintenance burden over app lifetime
□ Default to Managed unless blocked
```

---

## Resources

- [Expo SDK API Reference](https://docs.expo.dev/versions/latest/)
- [Config Plugins](https://docs.expo.dev/config-plugins/introduction/)
- [EAS Build](https://docs.expo.dev/build/introduction/)
- [Expo Modules API](https://docs.expo.dev/modules/overview/)
- [Community Config Plugins](https://github.com/expo/config-plugins)
