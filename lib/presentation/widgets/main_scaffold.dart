import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:regina_app/presentation/providers/appointment_provider.dart';
import 'package:regina_app/presentation/widgets/cart_icon_button.dart';
import 'package:regina_app/presentation/widgets/theme_button.dart';
import 'package:regina_app/presentation/providers/user_provider.dart';
import 'package:regina_app/presentation/providers/auth_controller_provider.dart';

class MainScaffold extends ConsumerWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  static const allTabs = ['/', '/products', '/services', '/login'];
  static const primaryColor = Color(0xFF007AFF);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) {
        final userLoggedIn = user != null;

        final tabs = userLoggedIn
            ? allTabs.where((tab) => tab != '/login').toList() + ['/profile']
            : allTabs;

        final String location = GoRouterState.of(context).uri.toString();
        int currentIndex = tabs.indexWhere((t) => location == t);
        if (currentIndex == -1) currentIndex = 0;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            centerTitle: false,
            title: Text(
              'Regina App',
              style: TextStyle(
                fontFamily: 'PlayfairDisplay',
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
            ),
            actions: [
              ThemeToggleButton(),
              const SizedBox(width: 8),
              const CartIconButton(),
              if (userLoggedIn)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Cerrar sesión',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text('¿Cerrar sesión?'),
                          content: const Text(
                            '¿Estás seguro de que querés cerrar sesión?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('Cerrar sesión'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await ref.read(authControllerProvider.notifier).logout();
                        ref.invalidate(appointmentProvider);
                        context.go('/login');
                      }
                    },
                  ),
                ),
            ],
          ),
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: currentIndex,
              selectedItemColor: primaryColor,
              unselectedItemColor: Colors.grey.shade500,
              onTap: (index) => context.go(tabs[index]),
              items: tabs.map((tab) {
                switch (tab) {
                  case '/':
                    return const BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      label: 'Inicio',
                    );
                  case '/products':
                    return const BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_bag_outlined),
                      label: 'Productos',
                    );
                  case '/services':
                    return const BottomNavigationBarItem(
                      icon: Icon(Icons.calendar_today_outlined),
                      label: 'Servicios',
                    );
                  case '/login':
                    return const BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline),
                      label: 'Ingresar',
                    );
                  case '/profile':
                    return const BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Perfil',
                    );
                  default:
                    return const BottomNavigationBarItem(
                      icon: Icon(Icons.error_outline),
                      label: 'Error',
                    );
                }
              }).toList(),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
