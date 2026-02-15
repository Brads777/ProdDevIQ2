---
name: shadcn-ui
description: >
  shadcn/ui component library patterns for Next.js and React projects.
  Installation, customization, theming, and best practices. Includes Docker
  dev environment for isolated component development. Trigger on /shadcn.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---
# ©2026 Brad Scheller

# shadcn/ui — Component Library Patterns

**Source:** [ui.shadcn.com](https://ui.shadcn.com/) | [github.com/shadcn-ui/ui](https://github.com/shadcn-ui/ui)

**Purpose:** Best practices for using shadcn/ui — a collection of reusable, accessible components built with Radix UI and Tailwind CSS. Components are copied into your project (not installed as a dependency), giving you full ownership and customization control.

## Trigger Commands

- `/shadcn` — Show quick reference and available components
- `/shadcn init` — Initialize shadcn/ui in current project
- `/shadcn add <component>` — Add a component with best practices
- `/shadcn theme` — Configure or switch themes
- `/shadcn docker` — Start the Docker dev environment

## Quick Setup

### In Existing Next.js Project

```bash
npx shadcn@latest init
```

Configuration prompts:
- **Style:** New York (recommended) or Default
- **Base color:** Zinc, Slate, Stone, Gray, or Neutral
- **CSS variables:** Yes (recommended for theming)

### Adding Components

```bash
# Individual components
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add dialog
npx shadcn@latest add form

# Multiple at once
npx shadcn@latest add button card dialog form input label

# All components
npx shadcn@latest add --all
```

## Docker Dev Environment

Start an isolated environment for shadcn component development:

```bash
docker compose -f docker/compose.yaml --profile shadcn up -d
```

Then access at `http://localhost:3333`.

## Component Architecture

### File Structure (after init)

```
project/
├── components/
│   └── ui/                 # shadcn components live here
│       ├── button.tsx
│       ├── card.tsx
│       ├── dialog.tsx
│       └── ...
├── lib/
│   └── utils.ts            # cn() helper for className merging
├── components.json          # shadcn config
└── tailwind.config.ts       # Tailwind with shadcn presets
```

### The cn() Utility

```typescript
// lib/utils.ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

### Component Customization Pattern

Since components are in YOUR codebase, customize freely:

```typescript
// components/ui/button.tsx — your copy, modify as needed
const buttonVariants = cva(
  "inline-flex items-center justify-center ...",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground ...",
        destructive: "bg-destructive text-destructive-foreground ...",
        outline: "border border-input bg-background ...",
        // Add your own variants:
        brand: "bg-brand-500 text-white hover:bg-brand-600",
        gradient: "bg-gradient-to-r from-purple-500 to-pink-500 text-white",
      },
      size: {
        default: "h-10 px-4 py-2",
        sm: "h-9 rounded-md px-3",
        lg: "h-11 rounded-md px-8",
        // Custom sizes:
        xl: "h-14 rounded-lg px-10 text-lg",
        icon: "h-10 w-10",
      },
    },
  }
);
```

## Theming

### CSS Variables (recommended)

```css
/* globals.css */
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;
    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;
    /* ... */
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;
    /* ... */
  }
}
```

### Theme Switching

```typescript
import { ThemeProvider } from "next-themes";

export default function RootLayout({ children }) {
  return (
    <ThemeProvider attribute="class" defaultTheme="system" enableSystem>
      {children}
    </ThemeProvider>
  );
}
```

## Common Patterns

### Form with Validation (React Hook Form + Zod)

```typescript
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { Form, FormField, FormItem, FormLabel, FormControl, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});

export function LoginForm() {
  const form = useForm({
    resolver: zodResolver(schema),
  });

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)}>
        <FormField control={form.control} name="email" render={({ field }) => (
          <FormItem>
            <FormLabel>Email</FormLabel>
            <FormControl><Input {...field} /></FormControl>
            <FormMessage />
          </FormItem>
        )} />
        <Button type="submit">Log in</Button>
      </form>
    </Form>
  );
}
```

### Data Table (TanStack Table + shadcn)

```bash
npx shadcn@latest add table
npm install @tanstack/react-table
```

### Command Palette (cmdk)

```bash
npx shadcn@latest add command
```

## Best Practices

1. **Don't wrap shadcn components** — Use them directly, customize the source
2. **Use CSS variables** for theming — Not Tailwind color classes
3. **Keep ui/ directory clean** — Only shadcn components, custom components go elsewhere
4. **Update selectively** — `npx shadcn@latest diff` shows what changed upstream
5. **Accessibility first** — Radix primitives handle ARIA, don't override unless needed
6. **Use the Form component** for any form with validation — it wires React Hook Form + Zod seamlessly

## Component Reference

| Category | Components |
|----------|-----------|
| Layout | Card, Separator, Sheet, Tabs, Resizable |
| Forms | Button, Input, Textarea, Select, Checkbox, Radio, Switch, Slider, Form |
| Feedback | Alert, AlertDialog, Dialog, Drawer, Popover, Tooltip, Toast, Sonner |
| Data | Table, DataTable, Badge, Avatar, Calendar |
| Navigation | Breadcrumb, Command, DropdownMenu, Menubar, NavigationMenu, Pagination |
| Typography | Accordion, Collapsible, HoverCard, ScrollArea |
