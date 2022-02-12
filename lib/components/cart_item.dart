import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/cart_item.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;

  const CartItemWidget({Key? key, required this.cartItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartValue = cartItem.price * cartItem.quantity;
    return Dismissible(
      key: ValueKey(cartItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red.shade400,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      ),
      confirmDismiss: (_) {
        return showDialog<bool>(context: context, builder: (ctx) => 
          AlertDialog(
            title: Text('Tem Certeza?'),
            content: Text('Quer remover o item do carrinho?'),
            actions: [
              TextButton(onPressed: () {
                Navigator.of(ctx).pop(false);
              }, child: Text('Não')),
              TextButton(onPressed: () {
                Navigator.of(ctx).pop(true);
              }, child: Text('Sim'))
            ],
          )
        );
      },
      onDismissed: (_) {
        Provider.of<Cart>(context, listen: false).removeItem(cartItem.productId);
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            child: Padding(
              padding: EdgeInsets.all(5),
              child: FittedBox(
                child: Text('${cartItem.price}'),
              ),
            ),
          ),
          title: Text(cartItem.name),
          subtitle: Text('Total: R\$ $cartValue'),
          trailing: Text('${cartItem.quantity}x'),
        ),
      ),
    );
  }
}
