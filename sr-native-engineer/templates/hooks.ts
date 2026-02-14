/**
 * Common hooks for React Native + Expo projects
 * Copy relevant hooks to lib/hooks/ in new projects
 */

import { useEffect, useState, useCallback, useRef } from 'react';
import {
  Keyboard,
  Dimensions,
  AppState,
  type AppStateStatus,
  type EmitterSubscription,
} from 'react-native';
import { useFocusEffect } from 'expo-router';
import * as Haptics from 'expo-haptics';

/**
 * Track keyboard visibility and height
 */
export function useKeyboard() {
  const [keyboardVisible, setKeyboardVisible] = useState(false);
  const [keyboardHeight, setKeyboardHeight] = useState(0);

  useEffect(() => {
    const showSubscription = Keyboard.addListener('keyboardDidShow', (e) => {
      setKeyboardVisible(true);
      setKeyboardHeight(e.endCoordinates.height);
    });
    const hideSubscription = Keyboard.addListener('keyboardDidHide', () => {
      setKeyboardVisible(false);
      setKeyboardHeight(0);
    });

    return () => {
      showSubscription.remove();
      hideSubscription.remove();
    };
  }, []);

  const dismissKeyboard = useCallback(() => {
    Keyboard.dismiss();
  }, []);

  return { keyboardVisible, keyboardHeight, dismissKeyboard };
}

/**
 * Track screen dimensions (responds to rotation)
 */
export function useDimensions() {
  const [dimensions, setDimensions] = useState(Dimensions.get('window'));

  useEffect(() => {
    const subscription = Dimensions.addEventListener('change', ({ window }) => {
      setDimensions(window);
    });

    return () => subscription.remove();
  }, []);

  return {
    ...dimensions,
    isLandscape: dimensions.width > dimensions.height,
    isPortrait: dimensions.height > dimensions.width,
    isTablet: dimensions.width >= 768,
    isPhone: dimensions.width < 768,
  };
}

/**
 * Track app state (active, background, inactive)
 */
export function useAppState() {
  const [appState, setAppState] = useState<AppStateStatus>(AppState.currentState);
  const previousState = useRef<AppStateStatus>(appState);

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextState) => {
      previousState.current = appState;
      setAppState(nextState);
    });

    return () => subscription.remove();
  }, [appState]);

  return {
    appState,
    previousState: previousState.current,
    isActive: appState === 'active',
    isBackground: appState === 'background',
    isInactive: appState === 'inactive',
  };
}

/**
 * Run effect when screen is focused (Expo Router)
 */
export function useFocusedEffect(effect: () => void | (() => void)) {
  useFocusEffect(
    useCallback(() => {
      const cleanup = effect();
      return () => {
        if (typeof cleanup === 'function') cleanup();
      };
    }, [effect])
  );
}

/**
 * Debounced value
 */
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}

/**
 * Previous value tracker
 */
export function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T>();

  useEffect(() => {
    ref.current = value;
  }, [value]);

  return ref.current;
}

/**
 * Boolean toggle with optional haptics
 */
export function useToggle(
  initialValue = false,
  options?: { haptics?: boolean }
): [boolean, () => void, (value: boolean) => void] {
  const [value, setValue] = useState(initialValue);

  const toggle = useCallback(() => {
    if (options?.haptics) {
      Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    }
    setValue((v) => !v);
  }, [options?.haptics]);

  return [value, toggle, setValue];
}

/**
 * Async operation state manager
 */
export function useAsync<T, E = Error>() {
  const [state, setState] = useState<{
    data: T | null;
    error: E | null;
    loading: boolean;
  }>({
    data: null,
    error: null,
    loading: false,
  });

  const execute = useCallback(async (asyncFn: () => Promise<T>) => {
    setState({ data: null, error: null, loading: true });
    try {
      const data = await asyncFn();
      setState({ data, error: null, loading: false });
      return data;
    } catch (error) {
      setState({ data: null, error: error as E, loading: false });
      throw error;
    }
  }, []);

  const reset = useCallback(() => {
    setState({ data: null, error: null, loading: false });
  }, []);

  return { ...state, execute, reset };
}

/**
 * Interval hook
 */
export function useInterval(callback: () => void, delay: number | null) {
  const savedCallback = useRef(callback);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    if (delay === null) return;

    const id = setInterval(() => savedCallback.current(), delay);
    return () => clearInterval(id);
  }, [delay]);
}

/**
 * Timeout hook
 */
export function useTimeout(callback: () => void, delay: number | null) {
  const savedCallback = useRef(callback);

  useEffect(() => {
    savedCallback.current = callback;
  }, [callback]);

  useEffect(() => {
    if (delay === null) return;

    const id = setTimeout(() => savedCallback.current(), delay);
    return () => clearTimeout(id);
  }, [delay]);
}

/**
 * Mount state tracker
 */
export function useIsMounted() {
  const isMounted = useRef(false);

  useEffect(() => {
    isMounted.current = true;
    return () => {
      isMounted.current = false;
    };
  }, []);

  return useCallback(() => isMounted.current, []);
}

/**
 * Force re-render
 */
export function useForceUpdate() {
  const [, setTick] = useState(0);
  return useCallback(() => setTick((tick) => tick + 1), []);
}

/**
 * Haptic feedback helper
 */
export function useHaptics() {
  const light = useCallback(() => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
  }, []);

  const medium = useCallback(() => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
  }, []);

  const heavy = useCallback(() => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
  }, []);

  const success = useCallback(() => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
  }, []);

  const warning = useCallback(() => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
  }, []);

  const error = useCallback(() => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
  }, []);

  const selection = useCallback(() => {
    Haptics.selectionAsync();
  }, []);

  return { light, medium, heavy, success, warning, error, selection };
}
