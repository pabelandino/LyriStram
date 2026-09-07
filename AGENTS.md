# EasyStream — Agent context

## Skills (project-local)

| Skill | Path | When to use |
|-------|------|-------------|
| **SwiftUI Pro** | `.cursor/skills/swiftui-pro/` | Any SwiftUI view, modifier, navigation, or performance work |
| **Graphify** | `graphify-out/` + `graphify query` | Architecture / cross-file questions before grep |

Install or update SwiftUI Pro from upstream:

```bash
git clone --depth 1 https://github.com/twostraws/swiftui-agent-skill.git /tmp/swiftui-agent-skill
cp -R /tmp/swiftui-agent-skill/swiftui-pro .cursor/skills/
```

Or: `npx skills add https://github.com/twostraws/swiftui-agent-skill --skill swiftui-pro`

## Cursor rules

- `.cursor/rules/graphify.mdc` — run graphify before codebase exploration
- `.cursor/rules/swiftui-pro.mdc` — SwiftUI conventions for this repo

## Conventions

- User-facing UI strings: Spanish. Code comments & commits: English.
- macOS Director studio: forced dark appearance (`broadcastStudioWindowStyle()`).
- Program bus: stable WebRTC surface; tiles use fixed 148×84 slots; PROG uses 16:9 layout without letterbox jumps.
