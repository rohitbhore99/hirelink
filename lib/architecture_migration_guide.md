# HireLink Architecture Migration Guide

## Goal
Move from a single `FirestoreService` to feature-based clean architecture without breaking existing screens.

## New Layers
- `core`: shared state, result, error classes.
- `features/<feature>/domain`: models and repository contracts.
- `features/<feature>/data`: Firebase repository implementations.
- `features/<feature>/presentation`: controllers and UI.

## Step-by-step migration
1. Keep current screens unchanged (safe baseline).
2. Add new models/repositories (done).
3. Migrate one feature at a time:
   - Jobs first
   - Chat second
   - User/Profile third
   - Applications fourth
4. Replace `FirestoreService` calls in one screen:
   - inject repository/controller
   - update loading/error handling via `UiState`
   - test screen
5. Remove duplicated methods from `FirestoreService` only after all usages are migrated.

## Example first migration target
- Replace `HomeScreen -> FirestoreService().getJobs()`
- With `JobsController(FirebaseJobsRepository()).bindJobs()`
- Render `state.isLoading`, `state.errorMessage`, and `state.data`.
