# Good and Bad Tests (Laravel)

## Good Tests

**Integration-style**: Exercise real HTTP routes, jobs, or public service methods — not mocked internals.

```php
// GOOD: Feature test through HTTP — observable behaviour
it('user can checkout with a valid cart', function () {
    $user = User::factory()->create();
    $product = Product::factory()->create(['price' => 1000]);

    $this->actingAs($user)
        ->post(route('cart.items.store'), ['product_id' => $product->id])
        ->assertOk();

    $this->post(route('checkout.store'), ['payment_method' => 'card'])
        ->assertRedirect(route('orders.show', Order::first()));
});
```

```php
// GOOD: Unit test on a public Action/Service method
it('calculates order total including tax', function () {
    $order = Order::factory()->make(['subtotal' => 10000]);

    $total = app(CalculateOrderTotal::class)->handle($order);

    expect($total)->toBe(12000);
});
```

Characteristics:

- Tests behaviour users or callers care about
- Uses public API (routes, form requests, Actions) only
- Survives internal refactors (controller → Action, rename private methods)
- Describes **what**, not **how**
- One logical assertion focus per test (Pest `expect()` chains count as one story)

## Bad Tests

**Implementation-detail tests**: Coupled to framework internals or call order.

```php
// BAD: Asserts a specific internal method was called
it('checkout calls PaymentGateway::charge', function () {
    $gateway = Mockery::mock(PaymentGateway::class);
    $gateway->shouldReceive('charge')->once();
    $this->instance(PaymentGateway::class, $gateway);

    app(CheckoutAction::class)->handle($cart);
});
```

```php
// BAD: Mocks Eloquent model methods you own
$order = Mockery::mock(Order::class);
$order->shouldReceive('save')->once();
```

```php
// BAD: Bypasses interface to assert on database directly
it('createUser saves to database', function () {
    createUser(['name' => 'Alice']);
    expect(DB::table('users')->where('name', 'Alice')->exists())->toBeTrue();
});

// GOOD: Assert through the application's interface
it('createUser makes user retrievable', function () {
    $user = createUser(['name' => 'Alice']);
    $this->actingAs($user)->get(route('profile.show'))
        ->assertOk()
        ->assertSee('Alice');
});
```

## Laravel-specific guidance

| Layer | Prefer | Avoid |
|-------|--------|-------|
| User flows | `tests/Feature/` + `actingAs()` + route helpers | Unit-testing controllers line-by-line |
| **Filament admin** | `livewire(ResourcePage::class)` + `fillForm` / table helpers | Raw POST to `/admin/...` when a page test suffices |
| Domain logic | Pest unit tests on Actions/Services | Mocking `Model::query()` |
| External APIs | `Http::fake()` with assertSent | Mocking your own HTTP client wrapper's private methods |
| Mail / queues | `Mail::fake()`, `Queue::fake()` + `assertPushed` | Asserting raw `DB` or `Log` for side effects |
| Time | `Carbon::setTestNow()` or `travelTo()` | Sleeping in tests |

Use factories (`User::factory()`) and `RefreshDatabase` — they're fast enough and keep tests honest.

**Filament projects:** full patterns, vertical-slice order, and anti-patterns are in [filament.md](filament.md).
