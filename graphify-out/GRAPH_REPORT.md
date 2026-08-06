# Graph Report - .  (2026-08-06)

## Corpus Check
- cluster-only mode — file stats not available

## Summary
- 41 nodes · 46 edges · 7 communities (5 shown, 2 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 1 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `b6c320dc`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- EasyStreamUITestsLaunchTests
- ContentView
- ContentView.swift
- EasyStreamUITests
- EasyStreamApp
- NavigationViewWrapper
- EasyStreamTests.swift

## God Nodes (most connected - your core abstractions)
1. `ContentView` - 7 edges
2. `EasyStreamUITests` - 6 edges
3. `EasyStreamUITestsLaunchTests` - 6 edges
4. `NavigationViewWrapper` - 5 edges
5. `EasyStreamApp` - 5 edges
6. `Item` - 5 edges
7. `SwiftData` - 3 edges
8. `.body` - 2 edges
9. `.body` - 2 edges
10. `EasyStreamTests` - 2 edges

## Surprising Connections (you probably didn't know these)
- `.body` --calls--> `ContentView`  [INFERRED]
  EasyStream/EasyStreamApp.swift → EasyStream/ContentView.swift
- `ContentView` --references--> `Item`  [EXTRACTED]
  EasyStream/ContentView.swift → EasyStream/Item.swift

## Import Cycles
- None detected.

## Communities (7 total, 2 thin omitted)

### Community 0 - "EasyStreamUITestsLaunchTests"
Cohesion: 0.25
Nodes (4): Bool, EasyStreamUITestsLaunchTests, .runsForEachTargetApplicationUIConfiguration, XCTest

### Community 1 - "ContentView"
Cohesion: 0.32
Nodes (5): Date, ContentView, .body, Item, IndexSet

### Community 2 - "ContentView.swift"
Cohesion: 0.40
Nodes (3): Foundation, SwiftData, SwiftUI

### Community 4 - "EasyStreamApp"
Cohesion: 0.40
Nodes (5): App, EasyStreamApp, .body, ModelContainer, Scene

### Community 5 - "NavigationViewWrapper"
Cohesion: 0.50
Nodes (4): Content, NavigationViewWrapper, .body, View

## Knowledge Gaps
- **4 isolated node(s):** `.body`, `Foundation`, `Testing`, `.runsForEachTargetApplicationUIConfiguration`
  These have ≤1 connection - possible missing edges or undocumented components.
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `ContentView` connect `ContentView` to `ContentView.swift`, `EasyStreamApp`, `NavigationViewWrapper`?**
  _High betweenness centrality (0.158) - this node is a cross-community bridge._
- **Why does `EasyStreamApp` connect `EasyStreamApp` to `ContentView.swift`?**
  _High betweenness centrality (0.082) - this node is a cross-community bridge._
- **Why does `Item` connect `ContentView` to `ContentView.swift`?**
  _High betweenness centrality (0.070) - this node is a cross-community bridge._
- **What connects `.body`, `Foundation`, `Testing` to the rest of the system?**
  _4 weakly-connected nodes found - possible documentation gaps or missing edges._