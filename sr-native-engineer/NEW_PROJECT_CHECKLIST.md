# New React Native + Expo Project Checklist

Use this checklist when starting a new React Native project with Expo.

## Initial Setup

### Create Project

```bash
# Create with Expo (latest SDK)
npx create-expo-app@latest my-app --template tabs
cd my-app

# Or with blank template for more control
npx create-expo-app@latest my-app --template blank-typescript
```

### Install Core Dependencies

```bash
# NativeWind v4
npx expo install nativewind tailwindcss react-native-reanimated
npx expo install react-native-safe-area-context

# Create NativeWind config
npx tailwindcss init

# Navigation (if not using tabs template)
npx expo install expo-router expo-linking expo-constants expo-status-bar

# Common utilities
bun add clsx tailwind-merge class-variance-authority
bun add zustand    # State management
bun add zod        # Validation

# Icons
bun add phosphor-react-native react-native-svg

# Images & Media
npx expo install expo-image expo-image-picker

# Storage
npx expo install expo-secure-store
bun add react-native-mmkv

# Haptics
npx expo install expo-haptics

# Animation
bun add moti    # Built on reanimated, declarative API

# Development
bun add -D @types/react @types/react-native
```

### Configure NativeWind

**metro.config.js:**
```javascript
const { getDefaultConfig } = require('expo/metro-config');
const { withNativeWind } = require('nativewind/metro');

const config = getDefaultConfig(__dirname);

module.exports = withNativeWind(config, { input: './global.css' });
```

**tailwind.config.js:**
```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/**/*.{js,jsx,ts,tsx}',
    './components/**/*.{js,jsx,ts,tsx}',
  ],
  presets: [require('nativewind/preset')],
  theme: {
    extend: {
      colors: {
        background: 'rgb(var(--background) / <alpha-value>)',
        foreground: 'rgb(var(--foreground) / <alpha-value>)',
        primary: 'rgb(var(--primary) / <alpha-value>)',
        'primary-foreground': 'rgb(var(--primary-foreground) / <alpha-value>)',
        muted: 'rgb(var(--muted) / <alpha-value>)',
        'muted-foreground': 'rgb(var(--muted-foreground) / <alpha-value>)',
        destructive: 'rgb(var(--destructive) / <alpha-value>)',
        border: 'rgb(var(--border) / <alpha-value>)',
        ring: 'rgb(var(--ring) / <alpha-value>)',
      },
    },
  },
  plugins: [],
};
```

**global.css:**
```css
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --background: 250 250 250;
  --foreground: 10 10 10;
  --primary: 59 130 246;
  --primary-foreground: 255 255 255;
  --muted: 245 245 245;
  --muted-foreground: 115 115 115;
  --destructive: 239 68 68;
  --border: 229 229 229;
  --ring: 59 130 246;
}

.dark {
  --background: 10 10 10;
  --foreground: 250 250 250;
  --primary: 96 165 250;
  --primary-foreground: 10 10 10;
  --muted: 38 38 38;
  --muted-foreground: 163 163 163;
  --destructive: 248 113 113;
  --border: 38 38 38;
  --ring: 96 165 250;
}
```

**babel.config.js:**
```javascript
module.exports = function (api) {
  api.cache(true);
  return {
    presets: [
      ['babel-preset-expo', { jsxImportSource: 'nativewind' }],
      'nativewind/babel',
    ],
    plugins: ['react-native-reanimated/plugin'],
  };
};
```

**nativewind-env.d.ts:**
```typescript
/// <reference types="nativewind/types" />
```

**app/_layout.tsx** (import global.css):
```typescript
import '../global.css';
```

### Configure app.json

```json
{
  "expo": {
    "name": "My App",
    "slug": "my-app",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/images/icon.png",
    "scheme": "myapp",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/images/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#0a0a0a"
    },
    "ios": {
      "supportsTablet": true,
      "bundleIdentifier": "com.yourcompany.myapp",
      "infoPlist": {
        "NSCameraUsageDescription": "Camera access for taking photos",
        "NSPhotoLibraryUsageDescription": "Photo library access for selecting images"
      }
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/images/adaptive-icon.png",
        "backgroundColor": "#0a0a0a"
      },
      "package": "com.yourcompany.myapp",
      "permissions": ["CAMERA", "READ_EXTERNAL_STORAGE"]
    },
    "web": {
      "bundler": "metro",
      "output": "static",
      "favicon": "./assets/images/favicon.png"
    },
    "plugins": [
      "expo-router"
    ],
    "experiments": {
      "typedRoutes": true
    }
  }
}
```

### Configure EAS

```bash
# Install EAS CLI globally
npm install -g eas-cli

# Login to Expo
eas login

# Configure EAS for the project
eas build:configure
```

**eas.json:**
```json
{
  "cli": {
    "version": ">= 5.0.0"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      }
    },
    "preview": {
      "distribution": "internal"
    },
    "production": {
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
```

## Project Structure

```bash
# Create directory structure
mkdir -p components/ui
mkdir -p lib/{api,hooks,stores,utils}
mkdir -p constants
mkdir -p assets/{fonts,images}
```

### Copy Templates

Copy from sr-native-engineer/templates/:
- `utils.ts` → `lib/utils.ts`
- `hooks.ts` → `lib/hooks/` (split into separate files as needed)

### Create Base Components

Create these in `components/ui/`:
- [ ] Button.tsx
- [ ] Input.tsx
- [ ] Card.tsx (Card, CardHeader, CardTitle, CardContent)
- [ ] Text.tsx (Typography variants)
- [ ] Screen.tsx (SafeAreaView wrapper)

## Development Workflow

### Start Development

```bash
# Start Expo dev server
npx expo start

# Run on specific platform
npx expo start --ios
npx expo start --android
```

### Build Dev Client

For native modules not in Expo Go:

```bash
# iOS simulator
eas build --profile development --platform ios

# Android emulator
eas build --profile development --platform android

# Install on simulator/emulator
eas build:run -p ios --latest
eas build:run -p android --latest
```

### Testing

```bash
# Run tests
bun test

# Run with coverage
bun test --coverage
```

## Pre-Release Checklist

- [ ] All features working on iOS
- [ ] All features working on Android
- [ ] Tested on physical devices
- [ ] Dark mode working
- [ ] App icon and splash screen set
- [ ] Bundle identifier/package name configured
- [ ] Version number updated
- [ ] CHANGELOG.md updated
- [ ] Privacy policy URL set (if needed)
- [ ] App store metadata prepared

## Build & Submit

```bash
# Preview build (internal testing)
eas build --profile preview --platform all

# Production build
eas build --profile production --platform all

# Submit to stores
eas submit --platform ios
eas submit --platform android
```

## Environment Variables

For API keys and secrets:

```bash
# Create .env file (gitignored)
echo "EXPO_PUBLIC_API_URL=https://api.example.com" > .env

# Create .env.example (tracked)
echo "EXPO_PUBLIC_API_URL=your_api_url_here" > .env.example
```

Access in code:
```typescript
const apiUrl = process.env.EXPO_PUBLIC_API_URL;
```

For build-time secrets (EAS):
```bash
eas secret:create --scope project --name API_KEY --value "xxx"
```

## Common Issues

### NativeWind not working
- Clear Metro cache: `npx expo start --clear`
- Rebuild native code: `eas build --profile development`

### Reanimated errors
- Ensure babel plugin is last in plugins array
- Reset packager: `npx expo start -c`

### TypeScript errors with NativeWind
- Ensure `nativewind-env.d.ts` exists and is included in `tsconfig.json`

### iOS build fails
- Check bundle identifier in app.json matches Apple Developer account
- Run `eas credentials` to set up provisioning

### Android build fails
- Check package name in app.json
- Verify keystore with `eas credentials`
