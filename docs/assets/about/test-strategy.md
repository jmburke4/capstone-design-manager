# Test Strategy: Front End + Back End Unit Coverage

## 1) Components/Services to Test

### Front End (Unit + Component Tests)

| Area | Component/Service | Why It Is Tested | Test File(s) |
|---|---|---|---|
| UI Rendering | Core pages and reusable components | Confirms expected render/state behavior and regressions in UI contracts | `frontend/**/**/*.test.*` |
| Form Handling | Form components + validation utilities | Prevents invalid submissions and broken client-side validation | `frontend/**/forms/**/*.test.*` |
| API Integration Layer | Front-end API clients/services | Verifies request mapping, error mapping, and response shaping | `frontend/**/services/**/*.test.*` |
| State Management | Store/reducers/actions/hooks | Ensures deterministic state transitions and side-effect handling | `frontend/**/store/**/*.test.*` |
| Routing/Guards | Route wrappers/guards/navigation helpers | Confirms access control and route behavior | `frontend/**/routing/**/*.test.*` |

### Back End (Unit + Service Tests)

| Area | Service/Module | Why It Is Tested | Test File(s) |
|---|---|---|---|
| Controllers/Handlers | Request handlers | Confirms status codes, payload shape, and input validation behavior | `backend/**/controllers/**/*.test.*` |
| Business Logic | Domain/application services | Validates core rules and edge-case outcomes | `backend/**/services/**/*.test.*` |
| Data Access | Repositories/data mappers | Ensures query behavior and mapping correctness | `backend/**/repositories/**/*.test.*` |
| AuthN/AuthZ | Auth services/middleware | Protects access boundaries and token/session validation | `backend/**/auth/**/*.test.*` |
| Error Handling | Error middleware/helpers | Confirms stable error contracts and fallback behavior | `backend/**/errors/**/*.test.*` |

---

## 2) Significant Test Case Description

### Front End Significant Cases

1. **Component renders expected default state**
   - Verifies initial UI contract and default props/state behavior.
2. **Validation blocks invalid input and shows clear errors**
   - Checks required fields, invalid formats, and boundary values.
3. **Service handles API success + failure paths**
   - Confirms loading/success/error transitions and mapped messages.
4. **State updates are deterministic**
   - Ensures reducer/store logic produces expected immutable outputs.
5. **Protected route behavior**
   - Verifies unauthorized users are redirected/blocked.

### Back End Significant Cases

1. **Controller returns correct response contract**
   - Status code, body shape, and headers for success and bad input.
2. **Service enforces business rules**
   - Valid/invalid scenarios, boundary values, and conflict handling.
3. **Repository handles empty/not-found and normal records**
   - Correct null/empty behavior and entity mapping.
4. **Authentication/authorization checks**
   - Valid token/invalid token/expired token/insufficient role.
5. **Error normalization**
   - Exceptions are converted to consistent API error responses.

---

## 3) Test Scripts

> Run from repository root (`/capstone-design-manager` in Git Bash, or `/capstone-design-manager` in WSL).

### Typical commands (Bash)

````bash
# Front end unit tests
npm --prefix ./frontend run test

# Front end coverage
npm --prefix ./frontend run test:coverage

# Back end unit tests
npm --prefix ./backend run test

# Back end coverage
npm --prefix ./backend run test:coverage

# Run both
npm --prefix ./frontend run test && npm --prefix ./backend run test