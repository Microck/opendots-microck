# Base UI Composition Examples (render + useRender)

These examples are Base UI patterns. Do not use `asChild`.

Issue trackers are listed in `references/links.md`.

## Render prop on a shadcn/ui Base component
Use `render` to replace the default element.

```tsx
import { Item, ItemContent, ItemTitle, ItemDescription, ItemActions } from "@/components/ui/item";
import { ChevronRightIcon } from "lucide-react";

export function ItemLink() {
  return (
    <Item
      render={
        <a href="/docs" className="group">
          <ItemContent>
            <ItemTitle>Visit docs</ItemTitle>
            <ItemDescription>Read the Base UI docs</ItemDescription>
          </ItemContent>
          <ItemActions>
            <ChevronRightIcon className="size-4" />
          </ItemActions>
        </a>
      }
    />
  );
}
```

## render prop with a custom component (forwardRef)

```tsx
import * as React from "react";
import { Tooltip, TooltipTrigger, TooltipContent } from "@/components/ui/tooltip";

const LinkButton = React.forwardRef<HTMLAnchorElement, React.ComponentProps<"a">>(
  (props, ref) => <a ref={ref} {...props} />
);
LinkButton.displayName = "LinkButton";

export function TooltipLink() {
  return (
    <Tooltip>
      <TooltipTrigger render={<LinkButton href="/pricing" className="btn" />}>
        Pricing
      </TooltipTrigger>
      <TooltipContent>View pricing</TooltipContent>
    </Tooltip>
  );
}
```

## useRender for your own Base UI‑style component
Use `useRender` when you author a custom component that accepts a `render` prop.

```tsx
import * as React from "react";
import { useRender } from "@base-ui/react/use-render";
import { mergeProps } from "@base-ui/react/merge-props";

type CalloutProps = {
  render?: React.ReactElement | ((props: React.HTMLAttributes<HTMLElement>) => React.ReactElement);
} & React.HTMLAttributes<HTMLElement>;

export function Callout({ render, ...props }: CalloutProps) {
  const defaultProps = {
    className: "rounded-md border p-3",
  };

  return useRender({
    defaultTagName: "div",
    render,
    props: mergeProps(defaultProps, props),
  });
}

// Usage
// <Callout render={<section />} />
```

## Complex Component Example: Select with custom trigger
This uses a composed trigger and keeps the popover mounted for smooth transitions.

```tsx
import * as Select from "@/components/ui/select";

export function PriceSelect() {
  return (
    <Select.Root>
      <Select.Trigger render={<button className="btn" />}>
        <Select.Value placeholder="Choose a plan" />
      </Select.Trigger>
      <Select.Portal keepMounted>
        <Select.Positioner sideOffset={8}>
          <Select.Content>
            <Select.Item value="free">Free</Select.Item>
            <Select.Item value="pro">Pro</Select.Item>
            <Select.Item value="team">Team</Select.Item>
          </Select.Content>
        </Select.Positioner>
      </Select.Portal>
    </Select.Root>
  );
}
```

## Complex Component Example: Command + Dialog
Use Command inside Dialog for search or quick actions.

```tsx
import * as Dialog from "@/components/ui/dialog";
import * as Command from "@/components/ui/command";

export function CommandPalette() {
  return (
    <Dialog.Root>
      <Dialog.Trigger>Open</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Positioner>
          <Dialog.Content className="card">
            <Dialog.Title>Search</Dialog.Title>
            <Command.Root>
              <Command.Input placeholder="Type a command..." />
              <Command.List>
                <Command.Item>Profile</Command.Item>
                <Command.Item>Settings</Command.Item>
              </Command.List>
            </Command.Root>
          </Dialog.Content>
        </Dialog.Positioner>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

## Edge Case Example: Tooltip with scroll container
Keep the tooltip portal within the scroll container to avoid clipping.

```tsx
import * as Tooltip from "@/components/ui/tooltip";

export function ScrollTooltip() {
  return (
    <div className="scroll-area" data-base-ui-portal-root>
      <Tooltip.Root>
        <Tooltip.Trigger>Hover</Tooltip.Trigger>
        <Tooltip.Portal>
          <Tooltip.Positioner sideOffset={6}>
            <Tooltip.Content>Inside scroll container</Tooltip.Content>
          </Tooltip.Positioner>
        </Tooltip.Portal>
      </Tooltip.Root>
    </div>
  );
}
```

## Edge Case Example: Portal root isolation
Scope portals to a specific root and isolate stacking contexts.

```tsx
export function PortalRootExample() {
  return (
    <div className="layout-root" data-base-ui-portal-root>
      {/* App content */}
    </div>
  );
}

// CSS
// .layout-root { isolation: isolate; }
```

## Edge Case Example: RSC/SSR boundaries
Wrap client-only UI in a client component when using React Server Components.

```tsx
"use client";
import * as Dialog from "@/components/ui/dialog";

export function ClientDialog() {
  return (
    <Dialog.Root>
      <Dialog.Trigger>Open</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Positioner>
          <Dialog.Content>Client-only dialog</Dialog.Content>
        </Dialog.Positioner>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

## Edge Case Example: Controlled vs uncontrolled state
Use controlled props when state is shared or synchronized.

```tsx
import * as Popover from "@/components/ui/popover";
import * as React from "react";

export function ControlledPopover() {
  const [open, setOpen] = React.useState(false);

  return (
    <Popover.Root open={open} onOpenChange={setOpen}>
      <Popover.Trigger>Toggle</Popover.Trigger>
      <Popover.Portal>
        <Popover.Positioner sideOffset={6}>
          <Popover.Content>Controlled content</Popover.Content>
        </Popover.Positioner>
      </Popover.Portal>
    </Popover.Root>
  );
}
```

## Edge Case Example: Focus trapping in Dialog
Ensure focusable content is inside `Dialog.Content`.

```tsx
import * as Dialog from "@/components/ui/dialog";

export function FocusTrapDialog() {
  return (
    <Dialog.Root>
      <Dialog.Trigger>Open</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Positioner>
          <Dialog.Content>
            <Dialog.Title>Preferences</Dialog.Title>
            <button>First</button>
            <button>Second</button>
          </Dialog.Content>
        </Dialog.Positioner>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

## Edge Case Example: Scroll lock and body styles
Scope portal root to avoid layout shifts when scroll is locked.

```tsx
export function ScrollLockLayout() {
  return (
    <div className="layout-root" data-base-ui-portal-root>
      {/* Dialog/Popover/Sheet components mount portals here */}
    </div>
  );
}

// CSS
// .layout-root { isolation: isolate; }
```

## Edge Case Example: Nested portals
Keep nested overlays within the same portal root to avoid z-index conflicts.

```tsx
import * as Dialog from "@/components/ui/dialog";
import * as Tooltip from "@/components/ui/tooltip";

export function NestedPortals() {
  return (
    <div data-base-ui-portal-root>
      <Dialog.Root>
        <Dialog.Trigger>Open</Dialog.Trigger>
        <Dialog.Portal>
          <Dialog.Positioner>
            <Dialog.Content>
              <Tooltip.Root>
                <Tooltip.Trigger>Hover</Tooltip.Trigger>
                <Tooltip.Portal>
                  <Tooltip.Positioner>
                    <Tooltip.Content>Tooltip inside dialog</Tooltip.Content>
                  </Tooltip.Positioner>
                </Tooltip.Portal>
              </Tooltip.Root>
            </Dialog.Content>
          </Dialog.Positioner>
        </Dialog.Portal>
      </Dialog.Root>
    </div>
  );
}
```

## Edge Case Example: z-index stacking order
When overlays overlap, apply a predictable z-index scale to portals.

```css
/* Example z-index scale */
:root {
  --z-overlay: 50;
  --z-popover: 60;
  --z-tooltip: 70;
}

[data-base-ui-portal-root] .dialog { z-index: var(--z-overlay); }
[data-base-ui-portal-root] .popover { z-index: var(--z-popover); }
[data-base-ui-portal-root] .tooltip { z-index: var(--z-tooltip); }
```

## Edge Case Example: Fixed containers and positioning
Use a Positioner with side offsets and prevent clipping inside fixed parents.

```tsx
import * as Popover from "@/components/ui/popover";

export function FixedContainerPopover() {
  return (
    <div className="fixed top-0 left-0 right-0 p-4">
      <Popover.Root>
        <Popover.Trigger>Open</Popover.Trigger>
        <Popover.Portal>
          <Popover.Positioner sideOffset={8}>
            <Popover.Content>Fixed container content</Popover.Content>
          </Popover.Positioner>
        </Popover.Portal>
      </Popover.Root>
    </div>
  );
}
```

## Edge Case Example: Hydration mismatch (SSR)
Ensure client-only state is initialized consistently to avoid mismatches.

```tsx
"use client";
import * as Popover from "@/components/ui/popover";
import * as React from "react";

export function SafeHydrationPopover() {
  const [open, setOpen] = React.useState(false);

  return (
    <Popover.Root open={open} onOpenChange={setOpen}>
      <Popover.Trigger>Open</Popover.Trigger>
      <Popover.Portal>
        <Popover.Positioner>
          <Popover.Content>SSR-safe content</Popover.Content>
        </Popover.Positioner>
      </Popover.Portal>
    </Popover.Root>
  );
}
```

## Edge Case Example: Focus return on close
Return focus to the trigger when the dialog closes.

```tsx
import * as Dialog from "@/components/ui/dialog";
import * as React from "react";

export function FocusReturnDialog() {
  const triggerRef = React.useRef<HTMLButtonElement>(null);

  return (
    <Dialog.Root onOpenChange={(open) => { if (!open) triggerRef.current?.focus(); }}>
      <Dialog.Trigger ref={triggerRef}>Open</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Positioner>
          <Dialog.Content>
            <Dialog.Title>Settings</Dialog.Title>
          </Dialog.Content>
        </Dialog.Positioner>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

## Edge Case Example: Nested scroll locking
Avoid double-scroll-lock when stacking overlays.

```tsx
import * as Dialog from "@/components/ui/dialog";
import * as Sheet from "@/components/ui/sheet";

export function NestedScrollLock() {
  return (
    <Dialog.Root>
      <Dialog.Trigger>Open dialog</Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Positioner>
          <Dialog.Content>
            <Sheet.Root>
              <Sheet.Trigger>Open sheet</Sheet.Trigger>
              <Sheet.Portal>
                <Sheet.Positioner>
                  <Sheet.Content>Nested sheet</Sheet.Content>
                </Sheet.Positioner>
              </Sheet.Portal>
            </Sheet.Root>
          </Dialog.Content>
        </Dialog.Positioner>
      </Dialog.Portal>
    </Dialog.Root>
  );
}
```

## Edge Case Example: Mobile hover/long-press conflicts
Prefer click/tap triggers for touch devices to avoid stuck hover states.

```tsx
import * as Tooltip from "@/components/ui/tooltip";

export function MobileTooltip() {
  return (
    <Tooltip.Root>
      <Tooltip.Trigger>Tap</Tooltip.Trigger>
      <Tooltip.Portal>
        <Tooltip.Positioner sideOffset={6}>
          <Tooltip.Content>Tap to dismiss</Tooltip.Content>
        </Tooltip.Positioner>
      </Tooltip.Portal>
    </Tooltip.Root>
  );
}
```
