import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:shop/models/cart_item.dart';
import 'package:shop/models/product.dart';

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemsCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    final totalPrecision = double.parse(total.toStringAsFixed(2));
    return totalPrecision;
  }

  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
          product.id,
          (existingItem) => CartItem(
                id: existingItem.id,
                name: existingItem.name,
                price: existingItem.price,
                productId: existingItem.productId,
                quantity: existingItem.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
          product.id,
          () => CartItem(
                id: Random().nextDouble().toString(),
                productId: product.id,
                name: product.name,
                quantity: 1,
                price: product.price,
              ));
    }
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    if (_items[productId]?.quantity == 1)
      _items.remove(productId);
    else
      _items.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          name: existingItem.name,
          price: existingItem.price,
          productId: existingItem.productId,
          quantity: existingItem.quantity - 1,
        ),
      );
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
