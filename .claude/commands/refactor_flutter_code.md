Refactor the Flutter codebase using:

• Clean Architecture
• Riverpod for state management
• go_router for navigation
• strict Test Driven Development

Agents:

1 flutter_architect
2 flutter_test_engineer
3 flutter_refactorer
4 flutter_reviewer

---

STEP 1 — ARCHITECTURE ANALYSIS
Agent: flutter_architect

Detect:

• business logic inside Widgets
• improper Riverpod usage
• global mutable state
• navigation inside widgets instead of router
• duplicated providers
• direct repository usage from UI
• legacy Navigator.push code
• non-responsive layouts

Also verify:

Riverpod rules
• ViewModels must be Riverpod Notifiers or AsyncNotifiers
• UI must only read providers
• No business logic inside providers used by UI

go_router rules
• All navigation must go through go_router
• No Navigator.push
• Route definitions centralized

Output:

Architecture report
Refactoring roadmap
File change plan
