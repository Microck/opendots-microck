# Examples

## Popover (basic composition)
```tsx
"use client";
import * as Popover from "@base-ui/react/popover";

export function DemoPopover() {
  return (
    <Popover.Root>
      <Popover.Trigger>Open</Popover.Trigger>
      <Popover.Portal>
        <Popover.Positioner sideOffset={8}>
          <Popover.Popup className="popover">
            <Popover.Title>Title</Popover.Title>
            <Popover.Description>Content</Popover.Description>
          </Popover.Popup>
        </Popover.Positioner>
      </Popover.Portal>
    </Popover.Root>
  );
}
```

## Render prop with custom button
```tsx
import * as Tooltip from "@base-ui/react/tooltip";

const Button = React.forwardRef<HTMLButtonElement, React.ComponentProps<"button">>(
  (props, ref) => <button ref={ref} {...props} />
);

export function DemoTooltip() {
  return (
    <Tooltip.Root>
      <Tooltip.Trigger render={<Button className="btn" />}>
        Hover me
      </Tooltip.Trigger>
      <Tooltip.Portal>
        <Tooltip.Positioner sideOffset={6}>
          <Tooltip.Popup className="tooltip">Hello</Tooltip.Popup>
        </Tooltip.Positioner>
      </Tooltip.Portal>
    </Tooltip.Root>
  );
}
```
