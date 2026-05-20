# When to Mock (Laravel)

Mock at **system boundaries** only:

- External HTTP APIs → `Http::fake()` or a bound interface + test double
- Payment providers, webhooks, third-party SDKs
- Time → `Carbon::setTestNow()` / `$this->travelTo()`
- Randomness / UUIDs when determinism matters

Prefer **framework fakes** over Mockery when available:

```php
Http::fake([
    'api.stripe.com/*' => Http::response(['id' => 'ch_123'], 200),
]);

Mail::fake();
Queue::fake();
Event::fake();
Storage::fake('s3');
```

Don't mock:

- Your own Eloquent models (use factories + real DB with `RefreshDatabase`)
- Internal Actions/Services you control
- Laravel facades you could fake at the boundary instead (`Http`, not your `StripeClient` internals)

## Designing for testability

**1. Constructor injection (Laravel container)**

```php
// Easy to test — swap implementation in test via $this->instance()
final readonly class ProcessOrder
{
    public function __construct(private PaymentGateway $payments) {}

    public function handle(Order $order): PaymentResult
    {
        return $this->payments->charge($order->total);
    }
}

// Hard to test — hidden dependency
final readonly class ProcessOrder
{
    public function handle(Order $order): PaymentResult
    {
        return (new StripeGateway(config('services.stripe.secret')))->charge($order->total);
    }
}
```

**2. Narrow interfaces at boundaries**

```php
// GOOD: One method per external concern — easy Http::fake() or mock
interface PaymentGateway
{
    public function charge(Money $amount): PaymentResult;
}

// BAD: One giant fetch() — mocks need conditional branches
interface ExternalApi
{
    public function request(string $method, string $url, array $options = []): array;
}
```

**3. Bind interfaces in a service provider**

```php
// AppServiceProvider or dedicated provider
$this->app->bind(PaymentGateway::class, StripeGateway::class);

// In tests
$this->instance(PaymentGateway::class, new FakePaymentGateway());
```

## Http::fake patterns

```php
Http::fake([
    'api.example.com/users/*' => Http::response(['id' => 1, 'name' => 'Ada']),
]);

// Assert the app called the right endpoint
Http::assertSent(fn ($request) =>
    $request->url() === 'https://api.example.com/users/1'
    && $request->method() === 'GET'
);
```

Prefer asserting **outcomes** (order marked paid, email queued) over asserting **call counts** on internal collaborators.
