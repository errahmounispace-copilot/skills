# TDD with Filament

Filament admin pages are **Livewire components**. The public test surface is the **page or relation-manager class** — not individual form field classes or table column definitions.

Requires [Pest's Livewire plugin](https://pestphp.com/docs/plugins#livewire): `composer require pestphp/pest-plugin-livewire --dev`.

Read `docs/agents/laravel-stack.md` — when **UI layer** is Filament, prefer the patterns below over raw HTTP route tests for admin flows.

## Where logic should live (TDD seam)

| Behaviour | Test here | Why |
|-----------|-----------|-----|
| Pricing rules, state transitions, invariants | Pest **unit** test on Action/Service | Survives Filament refactors |
| "Staff can create a post from the resource" | `livewire(CreatePost::class)` | User-facing admin behaviour |
| "Title is required on create" | `fillForm` → `call('create')` → `assertHasFormErrors` | Form contract |
| "User without permission cannot delete" | `assertActionHidden` / policy test | Authorization surface |

**Anti-pattern:** TDD against `TextInput::make('title')` configuration or asserting internal Livewire property names. That breaks when you reorganize the form schema.

**Pattern:** RED on a Filament interaction → GREEN with form/table changes → extract repeated domain logic to an Action when the same rule appears in API + Filament.

## TestCase setup

Authenticate in `setUp()` (or per test) so panel middleware passes:

```php
protected function setUp(): void
{
    parent::setUp();

    $this->actingAs(User::factory()->create());
}
```

**Multiple panels** — Filament does not infer the panel without a request. Set it before `livewire()`:

```php
use Filament\Facades\Filament;

Filament::setCurrentPanel(Filament::getPanel('admin')); // panel ID from config
```

Use a user that can access that panel (role, `canAccessPanel()`, etc.).

## Vertical slices (tracer bullets)

Build Filament features one observable behaviour at a time — same red-green-refactor loop as HTTP TDD:

```
1. can render list page          → get(PostResource::getUrl('index'))->assertSuccessful()
2. can list records in table     → livewire(ListPosts::class)->assertCanSeeTableRecords($posts)
3. can render create page        → get(..., 'create')->assertSuccessful()
4. can create with valid data    → fillForm → call('create') → assertHasNoFormErrors → assertDatabaseHas
5. validates required fields     → fillForm → call('create') → assertHasFormErrors
6. can edit and save             → EditPost + assertFormSet + fillForm + call('save')
7. can delete (authorized)       → callAction(DeleteAction::class) → assertModelMissing
8. hides delete (unauthorized)   → assertActionHidden(DeleteAction::class)
```

Do not write steps 1–8 as tests first, then implement the whole resource — that is horizontal slicing.

## Good tests

### Render (cheap smoke)

```php
it('can render the post list page', function () {
    $this->get(PostResource::getUrl('index'))->assertSuccessful();
});
```

### Create through the page (behaviour)

```php
use function Pest\Livewire\livewire;

it('staff can create a post', function () {
    $newData = Post::factory()->make();

    livewire(PostResource\Pages\CreatePost::class)
        ->fillForm([
            'title' => $newData->title,
            'content' => $newData->content,
        ])
        ->call('create')
        ->assertHasNoFormErrors()
        ->assertNotified(); // when using Filament notifications

    $this->assertDatabaseHas(Post::class, [
        'title' => $newData->title,
    ]);
});
```

### Validation (form contract)

```php
it('requires a title', function () {
    livewire(PostResource\Pages\CreatePost::class)
        ->fillForm(['title' => null])
        ->call('create')
        ->assertHasFormErrors(['title' => 'required']);
});
```

### Table (list behaviour)

Assert on the **List page class** (or relation manager), not the Resource class:

```php
it('can list posts', function () {
    $posts = Post::factory()->count(3)->create();

    livewire(PostResource\Pages\ListPosts::class)
        ->assertCanSeeTableRecords($posts);
});
```

### Edit + save

Pass the record's **route key** (slug/UUID), not always `id`:

```php
it('can update a post', function () {
    $post = Post::factory()->create();
    $newData = Post::factory()->make();

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])
        ->assertFormSet(['title' => $post->title])
        ->fillForm(['title' => $newData->title])
        ->call('save')
        ->assertHasNoFormErrors();

    expect($post->refresh()->title)->toBe($newData->title);
});
```

### Actions and policies

```php
use Filament\Actions\DeleteAction;

it('can delete a post', function () {
    $post = Post::factory()->create();

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])->callAction(DeleteAction::class);

    $this->assertModelMissing($post);
});

it('cannot delete a post without permission', function () {
    $user = User::factory()->create(); // no delete permission
    $post = Post::factory()->create();

    $this->actingAs($user);

    livewire(PostResource\Pages\EditPost::class, [
        'record' => $post->getRouteKey(),
    ])->assertActionHidden(DeleteAction::class);
});
```

Prefer `assertActionHidden` / `assertActionVisible` over reimplementing policy rules in the test.

### Relation managers

Mount with `ownerRecord` and `pageClass`:

```php
it('can list related posts on a category', function () {
    $category = Category::factory()->has(Post::factory()->count(5))->create();

    livewire(CategoryResource\RelationManagers\PostsRelationManager::class, [
        'ownerRecord' => $category,
        'pageClass' => CategoryResource\Pages\EditCategory::class,
    ])->assertCanSeeTableRecords($category->posts);
});
```

### Reactive forms (slug from title)

Use `assertFormSet` after `fillForm` — tests the behaviour, not the `afterStateUpdated` hook name:

```php
it('generates a slug from the title', function () {
    $title = 'Hello World';

    livewire(PostResource\Pages\CreatePost::class)
        ->fillForm(['title' => $title])
        ->assertFormSet(['slug' => 'hello-world']);
});
```

### Multiple forms on one page

Pass the form name as the second argument:

```php
->fillForm([...], 'createPostForm')
->assertHasFormErrors(['title' => 'required'], 'createPostForm');
```

## Bad tests

```php
// BAD: Asserts Filament/Livewire internals
expect($component->get('data.title'))->toBe('x');

// BAD: Tests that a column class exists — not user behaviour
expect(PostResource::getTableColumns())->toHaveCount(8);

// BAD: Duplicates policy logic instead of using Filament assertions
expect($user->cannot('delete', $post))->toBeTrue(); // alone, without assertActionHidden

// BAD: Full HTTP test for what Livewire already covers (slower, flakier)
$this->post('/admin/posts', [...]); // when CreatePost Livewire test exists
```

Use HTTP Feature tests for Filament only when you need the **full stack** (middleware chain, cookies, non-Livewire responses). Otherwise `livewire(Page::class)` is the integration seam.

## Table gotchas

- **Pagination:** `assertCanSeeTableRecords()` only checks the **current page**. Use `->call('gotoPage', 2)` or create fewer records.
- **Deferred loading:** call `->loadTable()` before table assertions.
- **Sorting / search:** `->sortTable('title')->assertCanSeeTableRecords($ordered, inOrder: true)` and `->searchTable('query')` — see [Filament table testing](https://filamentphp.com/docs/3.x/tables/testing).

## Notifications and exports

- After actions that flash notifications: `->assertNotified()` (or assert notification title/body when critical).
- Exports / bulk actions: `->callTableBulkAction('export')` then assert filesystem (`Storage::fake()`) or queued job (`Queue::fake()`), not the export class name.

## When to add a Feature test instead

- Custom **non-Filament** routes (API, public site) in the same app
- Webhook or external callback that never touches a Filament page
- Regression for a bug in **middleware** before Livewire boots

Keep Filament TDD on the page class; keep domain rules on Actions both can call.
