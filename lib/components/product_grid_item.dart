import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/models/auth.dart';
import 'package:shop/models/cart.dart';
import 'package:shop/models/product.dart';
import 'package:shop/utils/app_routes.dart';

class ProductGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final auth = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Hero(
            tag: product.id,
            child: Image.network(
              product.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          onTap: () {
            Navigator.of(context)
                .pushNamed(AppRoutes.PRODUCT_DETAIL, arguments: product);
          },
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              onPressed: () {
                product.toggleFavorite(auth.token ?? '', auth.userId ?? '');
              },
              icon: Icon(
                  product.isFavorite ? Icons.favorite : Icons.favorite_border),
              color: Theme.of(context).accentColor,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              cart.addItem(product);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Produto foi adicionado com sucesso!'),
                  duration: Duration(seconds: 2),
                  action: SnackBarAction(label: 'DESFAZER', onPressed: () {
                    cart.removeSingleItem(product.id);
                  }),
                ),
              );
            },
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
          ),
          title: Text(
            product.name,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
