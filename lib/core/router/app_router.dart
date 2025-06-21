import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:regina_app/presentation/providers/quantity_provider.dart';
import 'package:regina_app/presentation/screens/appointment_detail_screen.dart';
import 'package:regina_app/presentation/screens/home_screen.dart';
import 'package:regina_app/presentation/screens/order_summary_screen.dart';
import 'package:regina_app/presentation/screens/product_detail_screen.dart';
import 'package:regina_app/presentation/screens/product_screen.dart';
import 'package:regina_app/presentation/screens/profile_screen.dart';
import 'package:regina_app/presentation/screens/purchase_confirmation_screen.dart';
import 'package:regina_app/presentation/screens/purchase_summary_screen.dart';
import 'package:regina_app/presentation/screens/service_detail_screen.dart';
import 'package:regina_app/presentation/screens/services_screen.dart';
import 'package:regina_app/presentation/screens/login_screen.dart';
import 'package:regina_app/presentation/widgets/main_scaffold.dart';
import 'package:regina_app/presentation/screens/cart_screen.dart';

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
          builder: (context, state) {
            return ProviderScope(
              overrides: [
                quantityProvider.overrideWith((ref) => QuantityNotifier()),
              ],
              child: const ProductScreen(),
            );
          },
        ),
        GoRoute(
          path: '/product_detail/:productId',
          name: 'product_detail',
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
        GoRoute(
          path: '/service_detail/:serviceId',
          name: 'service_detail',
          builder:
              (context, state) => ServiceDetailScreen(
                serviceId: state.pathParameters['serviceId']!,
              ),
        ),
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/cart',
          name: 'cart',
          builder: (context, state) => const CartScreen(),
        ),
        GoRoute(
          path: '/appointment_detail/:appointmentId',
          name: 'appointment_detail',
          builder: (context, state) => AppointmentDetailScreen(
              appointmentId: state.pathParameters['appointmentId']!,
          ),
        ),
        GoRoute(
          path: '/order-summary',
          name: 'order-summary',
          builder: (context, state) => const OrderSummaryScreen(),
        ),
        GoRoute(
          path: '/confirm-order',
          name: 'confirm-order',
          builder: (context, state) => const PurchaseConfirmationScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),

        GoRoute(
          path: '/purchase_detail/:orderId',
          name: 'purchase_detail',
          builder:
              (context, state) => PurchaseDetailScreen(
                orderId: state.pathParameters['orderId']!,
              ),
        ),
      ],
    ),
  ],
);
