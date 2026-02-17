# Payload CMS Skill

Standalone Payload CMS development skill for AI coding agents.

## Installation

```bash
npx skills add noklip-io/agent-skills --skill payload
```

## Note for Claude Code Users

This is the **standalone version** of the Payload skill. Claude Code users should prefer installing the official [Payload Marketplace plugin](https://github.com/payloadcms/payload) which includes this skill along with MCP tools and additional features.

Install this standalone skill only if you prefer not to use the full plugin.

## What's Covered

This skill includes 11 comprehensive reference files:

| Reference | Topics |
|-----------|--------|
| `COLLECTIONS.md` | Collection config, versioning, drafts, timestamps |
| `FIELDS.md` | All field types, validation, conditional, virtual fields |
| `HOOKS.md` | Collection/field/global hooks, context management |
| `ACCESS-CONTROL.md` | Field-level, collection-level access control |
| `ACCESS-CONTROL-ADVANCED.md` | Row-level security, complex queries, patterns |
| `QUERIES.md` | Local API, filtering, relationships, pagination |
| `ENDPOINTS.md` | Custom endpoints, REST API, middleware |
| `ADAPTERS.md` | Database adapters, storage adapters, transactions |
| `ADVANCED.md` | Jobs queue, localization, custom endpoints |
| `PLUGIN-DEVELOPMENT.md` | Plugin architecture, package structure, hooks |
| `FIELD-TYPE-GUARDS.md` | TypeScript type guards for field types |

## Triggers

This skill activates when you mention:

- Payload CMS, payload.config.ts, Payload API
- Collections, fields, hooks, access control
- beforeChange, afterChange, beforeDelete hooks
- Local API, REST API, GraphQL queries
- Payload plugin development
- Database adapters (MongoDB, Postgres)

## Resources

- [Payload Documentation](https://payloadcms.com/docs)
- [GitHub Repository](https://github.com/payloadcms/payload)
- [Payload Discord](https://discord.com/invite/payload)
