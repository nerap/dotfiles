# Next.js + Tailwind + Framer Motion Patterns

Stack-specific patterns and conventions for your projects.

## Tech Stack

- **Framework**: Next.js 15+ (App Router, React 19)
- **Styling**: Tailwind CSS v4
- **UI Components**: ShadCN UI
- **Animations**: Framer Motion
- **i18n**: next-intl (en/fr)
- **Package Manager**: Bun

## File Organization

```
apps/web/
├── app/[locale]/           # App Router pages
├── components/             # React components
│   ├── landing/           # Landing page sections
│   └── ui/                # ShadCN components
├── messages/              # i18n translations
│   ├── en/
│   └── fr/
├── public/                # Static assets
└── lib/                   # Utilities
```

## Component Patterns

### Landing Sections

```tsx
// Pattern: Landing section component
import { SectionHeader } from "@/components/section-header"
import { motion } from "framer-motion"

export function MySection() {
  return (
    <section className="py-16 md:py-24">
      <SectionHeader
        title="Section Title"
        description="Section description"
      />
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        whileInView={{ opacity: 1, y: 0 }}
        viewport={{ once: true }}
      >
        {/* Content */}
      </motion.div>
    </section>
  )
}
```

### Internationalization

```tsx
// Use next-intl for translations
import { useTranslations } from "next-intl"

export function Component() {
  const t = useTranslations("landing")

  return <h1>{t("hero.title")}</h1>
}
```

## Styling Guidelines

- Use Tailwind utility classes
- Responsive: `sm:`, `md:`, `lg:` breakpoints
- Dark mode ready (if configured)
- Consistent spacing: `gap-4`, `p-6`, `mb-8`

## Animation Guidelines

- Use Framer Motion for scroll animations
- Pattern: `initial`, `whileInView`, `viewport={{ once: true }}`
- Keep animations subtle and performant
- Typical duration: 0.3s-0.6s

## Quality Standards

- TypeScript strict mode
- Components < 200 lines
- Test coverage: 80%+ (when applicable)
- Accessibility: ARIA labels, semantic HTML
