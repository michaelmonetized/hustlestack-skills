/**
 * Common utilities for React Native + NativeWind projects
 * Copy this to lib/utils.ts in new projects
 */

import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { Platform, Dimensions, PixelRatio } from 'react-native';

/**
 * Merge Tailwind classes with proper precedence
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Platform-specific value selector
 */
export function platformSelect<T>(options: {
  ios?: T;
  android?: T;
  macos?: T;
  web?: T;
  default: T;
}): T {
  const value = Platform.select(options);
  return value ?? options.default;
}

/**
 * Get screen dimensions
 */
export function getScreenDimensions() {
  const { width, height } = Dimensions.get('window');
  return {
    width,
    height,
    isSmall: width < 375,
    isMedium: width >= 375 && width < 768,
    isLarge: width >= 768 && width < 1024,
    isXLarge: width >= 1024,
    isTablet: width >= 768,
    isPhone: width < 768,
    isLandscape: width > height,
    isPortrait: height > width,
  };
}

/**
 * Normalize size across different pixel densities
 * Useful for consistent sizing across devices
 */
export function normalize(size: number): number {
  const { width } = Dimensions.get('window');
  const scale = width / 375; // Based on iPhone 8/SE width
  const newSize = size * scale;
  
  if (Platform.OS === 'ios') {
    return Math.round(PixelRatio.roundToNearestPixel(newSize));
  }
  
  return Math.round(PixelRatio.roundToNearestPixel(newSize)) - 2;
}

/**
 * Format relative time
 */
export function formatRelativeTime(date: Date): string {
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffSecs = Math.floor(diffMs / 1000);
  const diffMins = Math.floor(diffSecs / 60);
  const diffHours = Math.floor(diffMins / 60);
  const diffDays = Math.floor(diffHours / 24);

  if (diffSecs < 60) return 'just now';
  if (diffMins < 60) return `${diffMins}m ago`;
  if (diffHours < 24) return `${diffHours}h ago`;
  if (diffDays < 7) return `${diffDays}d ago`;
  
  return date.toLocaleDateString();
}

/**
 * Debounce function for search inputs, etc.
 */
export function debounce<T extends (...args: unknown[]) => unknown>(
  fn: T,
  delay: number
): (...args: Parameters<T>) => void {
  let timeoutId: NodeJS.Timeout;
  
  return (...args: Parameters<T>) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
}

/**
 * Generate a unique ID
 */
export function generateId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Capitalize first letter
 */
export function capitalize(str: string): string {
  return str.charAt(0).toUpperCase() + str.slice(1);
}

/**
 * Truncate text with ellipsis
 */
export function truncate(str: string, length: number): string {
  if (str.length <= length) return str;
  return `${str.slice(0, length)}...`;
}

/**
 * Sleep utility for async operations
 */
export function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Safe JSON parse with fallback
 */
export function safeJsonParse<T>(json: string, fallback: T): T {
  try {
    return JSON.parse(json) as T;
  } catch {
    return fallback;
  }
}
