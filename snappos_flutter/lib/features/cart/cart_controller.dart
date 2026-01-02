class CartItem {
  final int productId;
  final String name;
  final int price;
  int qty;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.qty,
  });

  int get subtotal => price * qty;

  Map<String, dynamic> toApi() => {"product_id": productId, "qty": qty};
}

class CartController {
  final List<CartItem> items = [];

  void add(int id, String name, int price) {
    final idx = items.indexWhere((e) => e.productId == id);
    if (idx >= 0) {
      items[idx].qty += 1;
    } else {
      items.add(CartItem(productId: id, name: name, price: price, qty: 1));
    }
  }

  void inc(CartItem it) => it.qty += 1;
  void dec(CartItem it) {
    it.qty -= 1;
    if (it.qty <= 0) items.remove(it);
  }

  int get total => items.fold(0, (a, b) => a + b.subtotal);

  void clear() => items.clear();
}
