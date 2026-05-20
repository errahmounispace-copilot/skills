# Logic Prototype (Laravel)

A tiny interactive terminal app that lets the user drive a state model by hand. Use when the question is **business logic, state transitions, or data shape** — things that look fine on paper but feel wrong once exercised.

## When this is the right shape

- "Does this state machine handle X then Y?"
- "Can this model represent case Z?"
- "What should the checkout Action API feel like before we wire HTTP?"

If the question is "what should this look like" — use [UI.md](UI.md).

## Process

### 1. State the question

One paragraph at the top of the prototype file or in `NOTES.md` next to it.

### 2. Pick the runtime

**PHP** in the host Laravel app. Match project style (strict types, `readonly` classes, Actions).

Do not add Node/Python runtimes just for a prototype.

### 3. Isolate portable logic

Put the answer behind a **pure PHP module** the real app can adopt:

- **Reducer** — `(State $state, Action $action): State` for discrete events
- **State machine** — explicit states/transitions when legality of actions matters
- **Action / Service** — `handle()` methods on plain classes with no I/O
- **Value objects** — immutable types for money, status enums, etc.

No `echo` in domain code. No Eloquent in the core logic unless persistence *is* the question. The Artisan command or TUI shell imports and calls the module.

### 4. Build the smallest driver

**Preferred: Artisan command** (fits Laravel conventions)

```bash
php artisan prototype:checkout-simulator
```

Each tick:

1. Print current state (field per line, or `json_encode` with pretty print)
2. List shortcuts: `[a] add item  [c] checkout  [q] quit`
3. Read one line / choice, dispatch, repeat

Use Symfony Console helpers (`$this->info`, `$this->line`) or a simple `while` loop in `handle()`.

**Alternative: standalone PHP script** in `prototype/` run via `php prototype/checkout-simulator.php` — only if the repo has no Artisan habit.

State stays **in memory** unless the question is explicitly about persistence.

### 5. One command to run

Document in `docs/agents/laravel-stack.md` or the prototype README:

```bash
php artisan prototype:checkout-simulator
```

### 6. Hand it over

The user drives it; "wait, that shouldn't be possible" is the signal. Add actions as needed.

### 7. Capture the answer

Record what the prototype taught you. Lift the validated Action/state machine into `app/`; delete the Artisan command and `prototype/` shell.

## Anti-patterns

- Pest tests on throwaway code
- Real database unless persistence is the question (`sqlite :memory:` scratch only)
- Generalising for hypothetical futures
- Mixing terminal I/O into the domain class
- Shipping the simulator command to production — register only in `local` or delete after use
