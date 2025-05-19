import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final bool showCartButton;

  const MainScaffold({
    super.key,
    required this.child,
    this.showCartButton = false,
  });

  static const tabs = ['/', '/products', '/services', '/login'];

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    int currentIndex = tabs.indexWhere((t) => location == t);
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regina App'),
        actions: [
          if (showCartButton)
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                context.push('/cart');  // Abre la pantalla carrito
              },
            ),
        ],
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => context.go(tabs[index]),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Turnos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_rounded),
            label: 'Ingresar',
          ),
        ],
      ),
    );
  }
}
