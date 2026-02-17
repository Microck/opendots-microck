# Registry Schemas (Deep Dive)

## registry.json
Schema: https://ui.shadcn.com/schema/registry.json
Docs: https://ui.shadcn.com/docs/registry/registry-json

Core fields:
- `$schema`: schema URL.
- `name`: registry name.
- `homepage`: registry homepage.
- `items`: array of registry items (must follow registry-item schema).

## registry-item.json
Schema: https://ui.shadcn.com/schema/registry-item.json
Docs: https://ui.shadcn.com/docs/registry/registry-item-json

Core fields:
- `$schema`
- `name`
- `type`
- `title`
- `description`
- `registryDependencies`
- `dependencies`
- `files`
- `cssVars`

Supported `type` values:
- `registry:block`
- `registry:component`
- `registry:lib`
- `registry:hook`
- `registry:ui`
- `registry:page`
- `registry:file`
- `registry:style`
- `registry:theme`
- `registry:item`
