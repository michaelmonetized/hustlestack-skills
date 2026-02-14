/**
 * Base UI Component Templates for React Native + NativeWind
 * Copy and adapt these to components/ui/ in new projects
 */

import { forwardRef, type ReactNode } from 'react';
import {
  View,
  Text,
  Pressable,
  TextInput,
  ActivityIndicator,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import Animated, { FadeIn, FadeOut } from 'react-native-reanimated';
import { cva, type VariantProps } from 'class-variance-authority';

// Assume this exists in lib/utils.ts
// import { cn } from '@/lib/utils';
function cn(...classes: (string | undefined | false)[]) {
  return classes.filter(Boolean).join(' ');
}

// =============================================================================
// SCREEN - Safe area wrapper for screens
// =============================================================================

interface ScreenProps {
  children: ReactNode;
  scroll?: boolean;
  keyboard?: boolean;
  className?: string;
  contentClassName?: string;
}

export function Screen({
  children,
  scroll = false,
  keyboard = false,
  className,
  contentClassName,
}: ScreenProps) {
  const content = scroll ? (
    <ScrollView
      className={cn('flex-1', contentClassName)}
      contentContainerClassName="flex-grow"
      showsVerticalScrollIndicator={false}
      keyboardShouldPersistTaps="handled"
    >
      {children}
    </ScrollView>
  ) : (
    <View className={cn('flex-1', contentClassName)}>{children}</View>
  );

  const wrapped = keyboard ? (
    <KeyboardAvoidingView
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
      className="flex-1"
    >
      {content}
    </KeyboardAvoidingView>
  ) : (
    content
  );

  return (
    <SafeAreaView className={cn('flex-1 bg-background', className)}>
      {wrapped}
    </SafeAreaView>
  );
}

// =============================================================================
// BUTTON - Primary interactive element
// =============================================================================

const buttonVariants = cva(
  'flex-row items-center justify-center rounded-xl active:opacity-80',
  {
    variants: {
      variant: {
        default: 'bg-primary',
        secondary: 'bg-muted',
        destructive: 'bg-destructive',
        outline: 'border border-border bg-transparent',
        ghost: 'bg-transparent',
      },
      size: {
        sm: 'h-9 px-3 gap-1.5',
        md: 'h-11 px-4 gap-2',
        lg: 'h-14 px-6 gap-2.5',
        icon: 'h-11 w-11',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'md',
    },
  }
);

const buttonTextVariants = cva('font-semibold', {
  variants: {
    variant: {
      default: 'text-primary-foreground',
      secondary: 'text-foreground',
      destructive: 'text-white',
      outline: 'text-foreground',
      ghost: 'text-foreground',
    },
    size: {
      sm: 'text-sm',
      md: 'text-base',
      lg: 'text-lg',
      icon: 'text-base',
    },
  },
  defaultVariants: {
    variant: 'default',
    size: 'md',
  },
});

interface ButtonProps extends VariantProps<typeof buttonVariants> {
  children: ReactNode;
  onPress?: () => void;
  disabled?: boolean;
  loading?: boolean;
  className?: string;
  textClassName?: string;
}

export function Button({
  children,
  variant,
  size,
  onPress,
  disabled,
  loading,
  className,
  textClassName,
}: ButtonProps) {
  const isDisabled = disabled || loading;

  return (
    <Pressable
      onPress={onPress}
      disabled={isDisabled}
      className={cn(buttonVariants({ variant, size }), isDisabled && 'opacity-50', className)}
    >
      {loading ? (
        <ActivityIndicator
          color={variant === 'default' || variant === 'destructive' ? '#fff' : '#000'}
          size="small"
        />
      ) : typeof children === 'string' ? (
        <Text className={cn(buttonTextVariants({ variant, size }), textClassName)}>
          {children}
        </Text>
      ) : (
        children
      )}
    </Pressable>
  );
}

// =============================================================================
// INPUT - Text input with label and error states
// =============================================================================

interface InputProps extends React.ComponentProps<typeof TextInput> {
  label?: string;
  error?: string;
  containerClassName?: string;
}

export const Input = forwardRef<TextInput, InputProps>(
  ({ label, error, className, containerClassName, ...props }, ref) => {
    return (
      <View className={cn('gap-1.5', containerClassName)}>
        {label && (
          <Text className="text-sm font-medium text-foreground">{label}</Text>
        )}
        <TextInput
          ref={ref}
          className={cn(
            'h-12 px-4 rounded-xl bg-muted text-foreground',
            'border border-transparent',
            error && 'border-destructive',
            className
          )}
          placeholderTextColor="rgb(115, 115, 115)"
          {...props}
        />
        {error && <Text className="text-sm text-destructive">{error}</Text>}
      </View>
    );
  }
);

Input.displayName = 'Input';

// =============================================================================
// CARD - Content container
// =============================================================================

interface CardProps {
  children: ReactNode;
  className?: string;
  onPress?: () => void;
}

export function Card({ children, className, onPress }: CardProps) {
  const content = (
    <View
      className={cn(
        'bg-background rounded-2xl border border-border overflow-hidden',
        className
      )}
    >
      {children}
    </View>
  );

  if (onPress) {
    return (
      <Pressable onPress={onPress} className="active:opacity-90">
        {content}
      </Pressable>
    );
  }

  return content;
}

export function CardHeader({ children, className }: CardProps) {
  return <View className={cn('p-4 pb-2', className)}>{children}</View>;
}

export function CardTitle({
  children,
  className,
}: {
  children: string;
  className?: string;
}) {
  return (
    <Text className={cn('text-lg font-semibold text-foreground', className)}>
      {children}
    </Text>
  );
}

export function CardDescription({
  children,
  className,
}: {
  children: string;
  className?: string;
}) {
  return (
    <Text className={cn('text-sm text-muted-foreground', className)}>
      {children}
    </Text>
  );
}

export function CardContent({ children, className }: CardProps) {
  return <View className={cn('p-4 pt-0', className)}>{children}</View>;
}

export function CardFooter({ children, className }: CardProps) {
  return (
    <View className={cn('flex-row items-center p-4 pt-0', className)}>
      {children}
    </View>
  );
}

// =============================================================================
// TYPOGRAPHY - Consistent text styles
// =============================================================================

const textVariants = cva('text-foreground', {
  variants: {
    variant: {
      h1: 'text-4xl font-bold',
      h2: 'text-3xl font-bold',
      h3: 'text-2xl font-semibold',
      h4: 'text-xl font-semibold',
      body: 'text-base',
      small: 'text-sm',
      muted: 'text-sm text-muted-foreground',
      label: 'text-sm font-medium',
    },
  },
  defaultVariants: {
    variant: 'body',
  },
});

interface TypographyProps extends VariantProps<typeof textVariants> {
  children: ReactNode;
  className?: string;
}

export function Typography({ children, variant, className }: TypographyProps) {
  return <Text className={cn(textVariants({ variant }), className)}>{children}</Text>;
}

// =============================================================================
// SEPARATOR - Visual divider
// =============================================================================

export function Separator({ className }: { className?: string }) {
  return <View className={cn('h-px bg-border', className)} />;
}

// =============================================================================
// SPINNER - Loading indicator
// =============================================================================

interface SpinnerProps {
  size?: 'small' | 'large';
  color?: string;
  className?: string;
}

export function Spinner({ size = 'small', color, className }: SpinnerProps) {
  return (
    <View className={cn('items-center justify-center', className)}>
      <ActivityIndicator size={size} color={color} />
    </View>
  );
}

// =============================================================================
// EMPTY STATE - When there's no content
// =============================================================================

interface EmptyStateProps {
  icon?: ReactNode;
  title: string;
  description?: string;
  action?: ReactNode;
  className?: string;
}

export function EmptyState({
  icon,
  title,
  description,
  action,
  className,
}: EmptyStateProps) {
  return (
    <View className={cn('flex-1 items-center justify-center p-8', className)}>
      {icon && <View className="mb-4">{icon}</View>}
      <Text className="text-lg font-semibold text-foreground text-center mb-2">
        {title}
      </Text>
      {description && (
        <Text className="text-muted-foreground text-center mb-6">{description}</Text>
      )}
      {action}
    </View>
  );
}

// =============================================================================
// SKELETON - Loading placeholder
// =============================================================================

interface SkeletonProps {
  className?: string;
}

export function Skeleton({ className }: SkeletonProps) {
  return (
    <Animated.View
      entering={FadeIn.duration(200)}
      exiting={FadeOut.duration(200)}
      className={cn('bg-muted rounded-lg animate-pulse', className)}
    />
  );
}

// =============================================================================
// BADGE - Status indicator
// =============================================================================

const badgeVariants = cva('px-2.5 py-0.5 rounded-full', {
  variants: {
    variant: {
      default: 'bg-primary',
      secondary: 'bg-muted',
      destructive: 'bg-destructive',
      outline: 'border border-border bg-transparent',
    },
  },
  defaultVariants: {
    variant: 'default',
  },
});

const badgeTextVariants = cva('text-xs font-medium', {
  variants: {
    variant: {
      default: 'text-primary-foreground',
      secondary: 'text-foreground',
      destructive: 'text-white',
      outline: 'text-foreground',
    },
  },
  defaultVariants: {
    variant: 'default',
  },
});

interface BadgeProps extends VariantProps<typeof badgeVariants> {
  children: string;
  className?: string;
}

export function Badge({ children, variant, className }: BadgeProps) {
  return (
    <View className={cn(badgeVariants({ variant }), className)}>
      <Text className={badgeTextVariants({ variant })}>{children}</Text>
    </View>
  );
}
