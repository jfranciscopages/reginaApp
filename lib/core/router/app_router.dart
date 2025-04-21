import 'package:go_router/go_router.dart';
import 'package:regina_app/presentation/screens/home_screen.dart';
import 'package:regina_app/presentation/screens/product_detail_screen.dart';
import 'package:regina_app/presentation/screens/product_screen.dart';
import 'package:regina_app/presentation/screens/services_screen.dart';
import 'package:regina_app/presentation/widgets/main_scaffold.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainScaffold(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/products',
          name: 'products',
          builder: (context, state) => ProductScreen(),
        ),
        GoRoute(
          path: '/product_detail/:productId',
          name: 'product detail',
          builder:
              (context, state) => ProductDetailScreen(
                productId: state.pathParameters['productId']!,
              ),
        ),
        GoRoute(
          path: '/services',
          name: 'services',
          builder: (context, state) => ServicesScreen(),
        ),
      ],
    ),
  ],
);
