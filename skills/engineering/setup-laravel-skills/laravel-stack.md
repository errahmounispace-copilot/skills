# Laravel stack

Commands and conventions for this repo. Engineering skills read this before running tests, formatters, or UI prototypes.

## Test runner

<!-- Pest (default for modern Laravel) or PHPUnit -->

| Task | Command |
|------|---------|
| All tests | `./vendor/bin/pest` |
| Single file | `./vendor/bin/pest tests/Feature/ExampleTest.php` |
| Filter by name | `./vendor/bin/pest --filter="user can checkout"` |
| With coverage | `./vendor/bin/pest --coverage` |

If using PHPUnit instead, replace `pest` with `php artisan test` or `./vendor/bin/phpunit`.

## Quality tools

| Tool | Command | Notes |
|------|---------|-------|
| Pint (format) | `./vendor/bin/pint` | Run on changed files: `./vendor/bin/pint --dirty` |
| PHPStan | `./vendor/bin/phpstan analyse` | Adjust memory: `--memory-limit=2G` |

## UI layer

<!-- One of: Blade | Livewire | Inertia (Vue/React) | Filament | API-only -->

- **Primary UI**: Livewire
- **Prototype UI variants**: Livewire components on an existing route, gated by `?variant=`
- **Do not** add React/Inertia-only patterns unless this row says Inertia

## Local development

<!-- Sail | Herd | Valet | artisan serve -->

- Start app: `./vendor/bin/sail up -d` (or `php artisan serve`)
- Migrate fresh: `php artisan migrate:fresh --seed`
- Queue worker (if used): `php artisan queue:work`

## Conventions skills should follow

- Prefer **Feature tests** through HTTP (`$this->get()`, `actingAs()`) for user-visible behaviour
- **Filament:** use `Pest\Livewire\livewire()` on Resource page classes; follow the `/tdd` skill's `filament.md`. Set `Filament::setCurrentPanel()` when testing non-default panels.
- Prefer **Actions / Services** with constructor injection over fat controllers
- Use framework fakes at boundaries: `Http::fake()`, `Queue::fake()`, `Mail::fake()`, `Event::fake()`
- Use `RefreshDatabase` or `DatabaseTransactions` in feature tests — don't mock Eloquent internals

Edit this file when the stack changes.
