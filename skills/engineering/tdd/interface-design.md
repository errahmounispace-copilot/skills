# Interface Design for Testability (Laravel)

Good boundaries make Pest tests natural:

1. **Inject dependencies; don't resolve them inside the method**

   ```php
   // Testable
   public function __construct(private PaymentGateway $payments) {}

   public function handle(Order $order): void
   {
       $this->payments->charge($order->total);
   }

   // Hard to test
   public function handle(Order $order): void
   {
       app(StripeGateway::class)->charge($order->total);
   }
   ```

2. **Return results; push side effects to the edges**

   ```php
   // Testable — pure calculation
   public function calculateDiscount(Cart $cart): Money { ... }

   // Harder — mutates in place, must inspect $cart after
   public function applyDiscount(Cart $cart): void { $cart->total -= ...; }
   ```

3. **Small surface area**
   - Thin controllers: validate → delegate to Action → respond
   - Few constructor params on Actions
   - Form Requests own validation; Actions own orchestration

4. **Feature tests for HTTP; unit tests for pure domain**
   - If only a private method would need testing, the seam is probably wrong — extract an Action or value object.
