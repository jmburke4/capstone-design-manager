# Test Strategy: Front End + Back End Unit Coverage

## 1) Components/Services to Test

### Front End (Unit + Component Tests)

| Area | Component/Service | Why It Is Tested | Test File(s) |
|---|---|---|---|
| UI Rendering | Core pages and reusable components | Confirms expected render/state behavior and regressions in UI contracts | `/components/*.test.js` |
| Form Handling | Form components + validation utilities | Prevents invalid submissions and broken client-side validation | `/components/EmailForm.test.js`, `/components/ConfirmationModal.test.js` |
| API Integration Layer | Front-end API clients and services | Verifies request mapping, error mapping, and response shaping | `/services/api.test.js` |
| State Management | Store, reducers, actions, hooks | Ensures deterministic state transitions and side-effect handling | `/stores/*.test.js` |
| Routing and Guards | Route wrappers, guards, navigation helpers | Confirms access control and route behavior | `/router/index.js` |

### Back End (Unit + Service Tests)

| Area | Service/Module | Why It Is Tested | Test File(s) |
|---|---|---|---|
| Controllers and Handlers | Request handlers | Confirms status codes, payload shape, and input validation behavior | `/project/tests/test_views.py`, `/user/tests/test_views.py` |
| Business Logic | Domain and application services | Validates core rules and edge-case outcomes | `/project/tests/test_models.py`, `/user/tests/test_models.py` |
| Data Access | Repositories, data mappers | Ensures query behavior and mapping correctness | `/project/tests/test_serializers.py`, `/user/tests/test_serializers.py` |
| AuthN/AuthZ | Auth services, middleware | Protects access boundaries and token/session validation | `/user/tests/test_views.py`, `/user/tests/test_admin.py` |
| Error Handling | Error middleware, helpers | Confirms stable error contracts and fallback behavior | `/project/tests/test_admin.py`, `/user/tests/test_admin.py` |

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

> Run from repository root

### Typical commands

```bash
# Front end unit tests
docker compose run frontend npm run test

# Front end coverage
docker compose run frontend npm run test:coverage

# Back end unit tests
docker compose run backend pytest

# Back end coverage
docker compose run backend pytest --cov

# Run both
docker compose run frontend npm run test && docker compose run backend pytest
```