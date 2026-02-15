---
name: frontend-master
description: >
  Comprehensive frontend development guide covering architecture patterns,
  state management, build tooling, accessibility, and modern CSS.
  Consolidates 4 frontend skills.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task, AskUserQuestion
context: fork
---

# ©2026 Brad Scheller

# Frontend Master

Complete frontend development reference consolidating best practices across architecture, tooling, state management, accessibility, and modern CSS.

## 1. When to Use

Invoke this skill when:

- Building or architecting a new UI application (SPA, SSR, SSG)
- Choosing a frontend framework or build tool
- Designing component APIs and folder structure
- Implementing state management or data fetching
- Styling questions (CSS-in-JS, Tailwind, CSS Modules)
- Accessibility or performance optimization
- Form handling and validation
- Build configuration or bundle optimization
- Migrating legacy frontend code to modern patterns

## 2. Project Setup

### Framework Selection

**Vite + React** — Fast dev server, lightweight SPA, no server required
```bash
npm create vite@latest my-app -- --template react-ts
```

**Next.js** — SSR/SSG, API routes, image optimization, file-based routing
```bash
npx create-next-app@latest my-app --typescript --tailwind --app
```

**Astro** — Content-focused sites, islands architecture, bring-your-own-framework
```bash
npm create astro@latest my-app
```

**Decision Matrix:**
| Need | Choose |
|------|--------|
| Marketing site, blog | Astro |
| Dashboard, admin panel | Vite + React |
| E-commerce, multi-page app with SEO | Next.js |
| Hybrid: static + dynamic | Next.js or Astro |

### TypeScript Configuration

**tsconfig.json (Vite/React):**
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "allowImportingTsExtensions": true,
    "strict": true,
    "skipLibCheck": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "jsx": "react-jsx",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src"]
}
```

**Key strictness flags:**
- `strict: true` — all strict checks
- `noUncheckedIndexedAccess: true` — treats `arr[0]` as `T | undefined`
- `exactOptionalPropertyTypes: true` — `undefined` must be explicit

### ESLint + Prettier

**eslint.config.js (flat config):**
```js
import js from '@eslint/js'
import reactPlugin from 'eslint-plugin-react'
import reactHooks from 'eslint-plugin-react-hooks'
import tseslint from 'typescript-eslint'

export default tseslint.config(
  js.configs.recommended,
  ...tseslint.configs.recommendedTypeChecked,
  {
    plugins: { react: reactPlugin, 'react-hooks': reactHooks },
    rules: {
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/consistent-type-imports': 'error'
    },
    languageOptions: {
      parserOptions: {
        project: true,
        tsconfigRootDir: import.meta.dirname
      }
    }
  }
)
```

**.prettierrc:**
```json
{
  "semi": false,
  "singleQuote": true,
  "trailingComma": "es5",
  "printWidth": 100,
  "plugins": ["prettier-plugin-tailwindcss"]
}
```

## 3. Architecture Patterns

### Feature-Based Folder Structure

**Organize by feature, not by file type:**

```
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   └── AuthGuard.tsx
│   │   ├── hooks/
│   │   │   └── useAuth.ts
│   │   ├── api/
│   │   │   └── auth.api.ts
│   │   ├── types.ts
│   │   └── index.ts          # Public API (barrel export)
│   ├── products/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── types.ts
│   │   └── index.ts
├── shared/
│   ├── components/           # Shared UI (Button, Input, Modal)
│   ├── hooks/                # Shared logic (useLocalStorage, useDebounce)
│   ├── utils/                # Pure functions
│   └── types/                # Global types
├── lib/                      # External integrations (api client, analytics)
├── app/                      # Routes (Next.js) or main App.tsx (Vite)
└── styles/                   # Global CSS, theme tokens
```

**Benefits:**
- Features are self-contained and portable
- Clear ownership boundaries
- Easy to delete or extract to packages

### Barrel Exports (index.ts)

**Pros:**
- Clean import paths: `import { LoginForm } from '@/features/auth'`
- Explicit public API surface

**Cons:**
- Can slow bundlers (re-exports everything)
- Circular dependency risk

**Best practice:**
```ts
// features/auth/index.ts
export { LoginForm } from './components/LoginForm'
export { useAuth } from './hooks/useAuth'
export type { User, AuthState } from './types'
```

**Avoid:**
```ts
// ❌ Don't wildcard re-export from multiple files
export * from './components'
export * from './hooks'
```

### Co-location

Place files next to where they're used:

```
features/products/
├── components/
│   ├── ProductCard.tsx
│   ├── ProductCard.test.tsx        # Test next to component
│   ├── ProductCard.module.css      # Styles next to component
│   └── ProductList.tsx
```

## 4. Component Design

### Atomic Design Principles

**Atoms** — Smallest units (Button, Input, Icon)
**Molecules** — Simple groups (SearchBar = Input + Button)
**Organisms** — Complex sections (ProductCard, Header)
**Templates** — Page layouts
**Pages** — Specific instances with real content

**In practice:**
```
shared/components/
├── Button.tsx          # Atom
├── Input.tsx           # Atom
├── SearchBar.tsx       # Molecule (Input + Button)
features/products/components/
├── ProductCard.tsx     # Organism
├── ProductGrid.tsx     # Template
```

### Composition Over Configuration

**Bad (configuration):**
```tsx
<Button variant="primary" size="lg" icon="check" iconPosition="left" />
```

**Good (composition):**
```tsx
<Button size="lg">
  <Icon name="check" />
  Save Changes
</Button>
```

### Props API Design

**Naming conventions:**
- Boolean props: `isOpen`, `hasError`, `canEdit`
- Event handlers: `onSubmit`, `onChange`, `onItemClick`
- Render props: `renderItem`, `renderHeader`

**Example:**
```tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary' | 'ghost'
  size?: 'sm' | 'md' | 'lg'
  isLoading?: boolean
  isDisabled?: boolean
  onClick?: (event: MouseEvent<HTMLButtonElement>) => void
  children: ReactNode
  className?: string
  type?: 'button' | 'submit' | 'reset'
}

export function Button({
  variant = 'primary',
  size = 'md',
  isLoading = false,
  isDisabled = false,
  type = 'button',
  onClick,
  children,
  className = '',
}: ButtonProps) {
  return (
    <button
      type={type}
      disabled={isDisabled || isLoading}
      onClick={onClick}
      className={cn(baseStyles, variantStyles[variant], sizeStyles[size], className)}
    >
      {isLoading ? <Spinner /> : children}
    </button>
  )
}
```

### Children Patterns

**Render props:**
```tsx
<DataTable
  data={users}
  renderRow={(user) => (
    <tr key={user.id}>
      <td>{user.name}</td>
      <td>{user.email}</td>
    </tr>
  )}
/>
```

**Compound components:**
```tsx
<Tabs defaultValue="profile">
  <TabsList>
    <TabsTrigger value="profile">Profile</TabsTrigger>
    <TabsTrigger value="settings">Settings</TabsTrigger>
  </TabsList>
  <TabsContent value="profile">Profile content</TabsContent>
  <TabsContent value="settings">Settings content</TabsContent>
</Tabs>
```

**Slots:**
```tsx
<Modal
  header={<ModalHeader>Confirm Delete</ModalHeader>}
  footer={<ModalFooter><Button>Cancel</Button><Button>Delete</Button></ModalFooter>}
>
  Are you sure?
</Modal>
```

## 5. State Management

### Decision Tree

**Use local state (useState) when:**
- State is only needed by one component and its children
- State doesn't need to persist across route changes
- Examples: form inputs, toggle states, local UI flags

**Use URL state when:**
- State should be shareable via URL
- State should survive page refresh
- Examples: filters, pagination, search queries, active tab

**Use Context when:**
- State is needed by many components at different nesting levels
- Updates are infrequent
- Examples: theme, user auth, locale

**Use global store (Zustand, Redux) when:**
- State is needed globally and updates frequently
- Complex state logic or side effects
- Examples: shopping cart, notifications, real-time data

### Context Gotchas

**Problem: Re-renders on every context update**
```tsx
// ❌ Every consumer re-renders when theme OR user changes
const AppContext = createContext({ theme: 'light', user: null })
```

**Solution: Split contexts**
```tsx
const ThemeContext = createContext('light')
const UserContext = createContext(null)
```

**Problem: Context value is recreated on every render**
```tsx
// ❌ New object on every render → all consumers re-render
function App() {
  const [user, setUser] = useState(null)
  return <UserContext.Provider value={{ user, setUser }}>...</UserContext.Provider>
}
```

**Solution: Memoize the value**
```tsx
function App() {
  const [user, setUser] = useState(null)
  const value = useMemo(() => ({ user, setUser }), [user])
  return <UserContext.Provider value={value}>...</UserContext.Provider>
}
```

### Zustand Example

```ts
import { create } from 'zustand'

interface CartStore {
  items: CartItem[]
  addItem: (item: CartItem) => void
  removeItem: (id: string) => void
  clearCart: () => void
}

export const useCart = create<CartStore>((set) => ({
  items: [],
  addItem: (item) => set((state) => ({ items: [...state.items, item] })),
  removeItem: (id) => set((state) => ({ items: state.items.filter((i) => i.id !== id) })),
  clearCart: () => set({ items: [] }),
}))
```

**Usage:**
```tsx
function CartButton() {
  const itemCount = useCart((state) => state.items.length) // Only re-renders when length changes
  return <Button>Cart ({itemCount})</Button>
}
```

### URL State (Next.js)

```tsx
'use client'
import { useSearchParams, useRouter } from 'next/navigation'

function ProductFilters() {
  const searchParams = useSearchParams()
  const router = useRouter()
  const category = searchParams.get('category') || 'all'

  function setCategory(newCategory: string) {
    const params = new URLSearchParams(searchParams)
    params.set('category', newCategory)
    router.push(`?${params.toString()}`)
  }

  return <Select value={category} onChange={(e) => setCategory(e.target.value)} />
}
```

## 6. Modern CSS

### CSS Modules

```css
/* Button.module.css */
.button {
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
}

.primary {
  background: var(--color-primary);
  color: white;
}
```

```tsx
import styles from './Button.module.css'

<button className={`${styles.button} ${styles.primary}`}>Click</button>
```

**Using clsx for conditional classes:**
```tsx
import clsx from 'clsx'
import styles from './Button.module.css'

<button className={clsx(styles.button, variant === 'primary' && styles.primary)} />
```

### Tailwind CSS

**Best practices:**
- Extract repeating patterns into components (not `@apply`)
- Use `cn()` helper for conditional classes
- Configure custom colors in `tailwind.config.ts`

```tsx
import { cn } from '@/lib/utils'

function Button({ variant, className, ...props }: ButtonProps) {
  return (
    <button
      className={cn(
        'rounded-md px-4 py-2 font-medium transition-colors',
        variant === 'primary' && 'bg-blue-600 text-white hover:bg-blue-700',
        variant === 'secondary' && 'bg-gray-200 text-gray-900 hover:bg-gray-300',
        className
      )}
      {...props}
    />
  )
}
```

**cn() utility:**
```ts
import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
```

### CSS Variables for Theming

```css
:root {
  --color-primary: 220 90% 56%;
  --color-background: 0 0% 100%;
  --color-foreground: 0 0% 9%;
  --radius: 0.5rem;
}

.dark {
  --color-background: 0 0% 9%;
  --color-foreground: 0 0% 100%;
}
```

**Use HSL values without `hsl()` for opacity:**
```css
.button {
  background: hsl(var(--color-primary));
  border: 1px solid hsl(var(--color-primary) / 0.5);
}
```

### Container Queries

```css
.card {
  container-type: inline-size;
}

.card-content {
  display: flex;
  flex-direction: column;
}

@container (min-width: 400px) {
  .card-content {
    flex-direction: row;
  }
}
```

### Modern Selectors

**:has() — parent selector**
```css
/* Card with a badge */
.card:has(.badge) {
  border: 2px solid var(--color-primary);
}

/* Form with errors */
.form:has(input:invalid) .submit-btn {
  opacity: 0.5;
  pointer-events: none;
}
```

**:is() and :where() — grouping**
```css
/* Old */
.header h1, .header h2, .header h3 { margin: 0; }

/* New */
.header :is(h1, h2, h3) { margin: 0; }
```

## 7. Build & Bundle

### Vite Configuration

**vite.config.ts:**
```ts
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
})
```

### Code Splitting

**Route-based splitting (React Router):**
```tsx
import { lazy, Suspense } from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'

const Home = lazy(() => import('./pages/Home'))
const Dashboard = lazy(() => import('./pages/Dashboard'))

function App() {
  return (
    <BrowserRouter>
      <Suspense fallback={<Spinner />}>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/dashboard" element={<Dashboard />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  )
}
```

**Component-based splitting:**
```tsx
const HeavyChart = lazy(() => import('./components/HeavyChart'))

function Dashboard() {
  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<ChartSkeleton />}>
        <HeavyChart data={data} />
      </Suspense>
    </div>
  )
}
```

### Tree Shaking

**Ensure library supports ESM:**
```json
// package.json
{
  "type": "module",
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "types": "./dist/index.d.ts"
    }
  }
}
```

**Use named imports:**
```tsx
// ✅ Tree-shakeable
import { Button } from '@/components/Button'

// ❌ Not tree-shakeable
import * as Components from '@/components'
const { Button } = Components
```

### Analyzing Bundle Size

```bash
# Vite
npm run build
npx vite-bundle-visualizer

# Next.js (add to next.config.js)
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
})
module.exports = withBundleAnalyzer({})

# Then run
ANALYZE=true npm run build
```

### Import Maps (for library CDN)

```html
<script type="importmap">
{
  "imports": {
    "react": "https://esm.sh/react@18",
    "react-dom": "https://esm.sh/react-dom@18"
  }
}
</script>
<script type="module">
  import React from 'react'
  import { createRoot } from 'react-dom'
</script>
```

## 8. Forms & Validation

### Controlled vs Uncontrolled

**Controlled (React state):**
```tsx
function SearchForm() {
  const [query, setQuery] = useState('')
  return <input value={query} onChange={(e) => setQuery(e.target.value)} />
}
```

**Uncontrolled (form state):**
```tsx
function SearchForm() {
  const inputRef = useRef<HTMLInputElement>(null)
  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    console.log(inputRef.current?.value)
  }
  return (
    <form onSubmit={handleSubmit}>
      <input ref={inputRef} name="query" />
    </form>
  )
}
```

**Use controlled when:**
- Need to validate or transform input on every keystroke
- Need to disable submit button based on input

**Use uncontrolled when:**
- Simple forms with no dynamic validation
- Working with native form features (FormData, form actions)

### React Hook Form + Zod

```tsx
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  email: z.string().email('Invalid email'),
  password: z.string().min(8, 'Must be at least 8 characters'),
  age: z.number().min(18, 'Must be 18 or older'),
})

type FormData = z.infer<typeof schema>

function SignupForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<FormData>({
    resolver: zodResolver(schema),
  })

  async function onSubmit(data: FormData) {
    await fetch('/api/signup', { method: 'POST', body: JSON.stringify(data) })
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input {...register('email')} />
      {errors.email && <span className="error">{errors.email.message}</span>}

      <input type="password" {...register('password')} />
      {errors.password && <span className="error">{errors.password.message}</span>}

      <input type="number" {...register('age', { valueAsNumber: true })} />
      {errors.age && <span className="error">{errors.age.message}</span>}

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Signing up...' : 'Sign Up'}
      </button>
    </form>
  )
}
```

### Error Display Patterns

**Inline errors:**
```tsx
<div className="field">
  <label htmlFor="email">Email</label>
  <input id="email" {...register('email')} aria-invalid={!!errors.email} />
  {errors.email && (
    <span className="error" role="alert">
      {errors.email.message}
    </span>
  )}
</div>
```

**Toast notifications:**
```tsx
import { toast } from 'sonner'

async function onSubmit(data: FormData) {
  try {
    await fetch('/api/signup', { method: 'POST', body: JSON.stringify(data) })
    toast.success('Account created!')
  } catch (error) {
    toast.error('Failed to create account')
  }
}
```

## 9. Accessibility Quick Reference

### Semantic HTML

Use the right element for the job:

| Instead of | Use |
|------------|-----|
| `<div onClick={...}>` | `<button>` |
| `<div className="heading">` | `<h1>`, `<h2>`, etc. |
| `<div className="list">` | `<ul>` or `<ol>` |
| `<span className="link">` | `<a href="...">` |

### Keyboard Navigation

**All interactive elements must be keyboard-accessible:**
```tsx
// ✅ Button is focusable by default
<button onClick={handleClick}>Click me</button>

// ❌ Div is not focusable
<div onClick={handleClick}>Click me</div>

// ✅ If you must use div, add role and tabIndex
<div role="button" tabIndex={0} onClick={handleClick} onKeyDown={handleKeyDown}>
  Click me
</div>
```

**Common keyboard patterns:**
- Enter/Space → activate button
- Escape → close modal/dropdown
- Arrow keys → navigate lists/menus
- Tab → move forward, Shift+Tab → move backward

### ARIA Essentials

**Labels:**
```tsx
<button aria-label="Close modal">×</button>
<input aria-label="Search products" />
```

**States:**
```tsx
<button aria-pressed={isActive}>Toggle</button>
<button aria-expanded={isOpen}>Menu</button>
<div aria-live="polite">{statusMessage}</div>
```

**Relationships:**
```tsx
<label htmlFor="email">Email</label>
<input id="email" aria-describedby="email-hint" />
<span id="email-hint">We'll never share your email</span>
```

**Landmarks:**
```tsx
<nav aria-label="Main navigation">...</nav>
<main>...</main>
<aside aria-label="Related articles">...</aside>
```

### Color Contrast

**WCAG AA requirements:**
- Normal text: 4.5:1 minimum
- Large text (18pt+ or 14pt+ bold): 3:1 minimum

**Check contrast:**
- Chrome DevTools: Inspect element → Styles → color picker shows contrast ratio
- Online: https://contrast-ratio.com

### Skip Links

```tsx
// Add at top of page
<a href="#main-content" className="skip-link">
  Skip to main content
</a>

// Target
<main id="main-content">...</main>
```

```css
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
```

## 10. Performance

### Lazy Loading Images

**Native lazy loading:**
```tsx
<img src="/large-image.jpg" loading="lazy" alt="Description" />
```

**Next.js Image component:**
```tsx
import Image from 'next/image'

<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // For above-the-fold images
/>

<Image
  src="/product.jpg"
  alt="Product"
  width={400}
  height={400}
  loading="lazy" // Default for non-priority images
/>
```

### Font Loading

**Prevent layout shift with font-display:**
```css
@font-face {
  font-family: 'Inter';
  src: url('/fonts/inter.woff2') format('woff2');
  font-display: swap; /* Show fallback immediately, swap when loaded */
}
```

**Next.js font optimization:**
```tsx
import { Inter } from 'next/font/google'

const inter = Inter({ subsets: ['latin'], display: 'swap' })

export default function Layout({ children }) {
  return <div className={inter.className}>{children}</div>
}
```

### Prefetching

**Next.js Link prefetching:**
```tsx
// Prefetches on hover (default)
<Link href="/dashboard">Dashboard</Link>

// Disable prefetch
<Link href="/settings" prefetch={false}>Settings</Link>
```

**Manual prefetch:**
```tsx
import { useRouter } from 'next/navigation'

function ProductCard({ id }) {
  const router = useRouter()
  return (
    <div onMouseEnter={() => router.prefetch(`/products/${id}`)}>
      <Link href={`/products/${id}`}>View Product</Link>
    </div>
  )
}
```

### Component Optimization

**React.memo for expensive renders:**
```tsx
import { memo } from 'react'

const ExpensiveList = memo(function ExpensiveList({ items }: { items: Item[] }) {
  return items.map((item) => <ExpensiveItem key={item.id} item={item} />)
})
```

**useMemo for expensive calculations:**
```tsx
const sortedItems = useMemo(() => {
  return items.sort((a, b) => a.name.localeCompare(b.name))
}, [items])
```

**useCallback for stable function references:**
```tsx
const handleClick = useCallback(() => {
  console.log(userId)
}, [userId])
```

### Measuring Performance

**Lighthouse CI:**
```bash
npm install -g @lhci/cli

# Run audit
lhci autorun --config=lighthouserc.json
```

**lighthouserc.json:**
```json
{
  "ci": {
    "collect": {
      "url": ["http://localhost:3000"],
      "numberOfRuns": 3
    },
    "assert": {
      "assertions": {
        "categories:performance": ["error", { "minScore": 0.9 }],
        "categories:accessibility": ["error", { "minScore": 0.95 }]
      }
    }
  }
}
```

**React DevTools Profiler:**
1. Open React DevTools
2. Profiler tab → Record
3. Interact with app
4. Stop recording → analyze flame graph for slow renders

**Web Vitals:**
```tsx
import { onCLS, onFID, onLCP } from 'web-vitals'

onCLS(console.log)
onFID(console.log)
onLCP(console.log)
```

---

## Summary

This skill consolidates frontend best practices into a single reference:

1. **Setup** — Choose the right framework (Vite, Next.js, Astro) and configure TypeScript + ESLint
2. **Architecture** — Feature-based folders, barrel exports, co-location
3. **Components** — Atomic design, composition, props API conventions
4. **State** — Decision tree (local → URL → Context → global store)
5. **CSS** — Modules, Tailwind, variables, container queries, :has()
6. **Build** — Code splitting, tree shaking, bundle analysis
7. **Forms** — React Hook Form + Zod validation patterns
8. **A11y** — Semantic HTML, keyboard nav, ARIA, skip links
9. **Performance** — Lazy loading, font optimization, prefetching, measurement

Use this as a checklist when starting new projects or reviewing existing code.
