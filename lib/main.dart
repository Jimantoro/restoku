import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/restaurant_provider.dart';
import 'screens/menu_management_screen.dart';
import 'screens/pos_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/tables_screen.dart';
import 'screens/transactions_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'widgets/payment_modal.dart';
import 'widgets/receipt_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
      ],
      child: const RestoPosApp(),
    ),
  );
}

class RestoPosApp extends StatelessWidget {
  const RestoPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RestoPOS - Kasir Offline Restoran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainAppScaffold(),
    );
  }
}

class MainAppScaffold extends StatefulWidget {
  const MainAppScaffold({super.key});

  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();

    // Listen for notification snackbars
    if (provider.notificationMessage != null) {
      final msg = provider.notificationMessage!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
        provider.clearNotification();
      });
    }

    // Modal Payment Dialog
    if (provider.showPaymentDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => PaymentModal(
            provider: provider,
            activeSettleOrder: provider.activeSettleOrder,
            onDismiss: () {
              provider.closePaymentDialog();
              Navigator.pop(ctx);
            },
          ),
        );
      });
    }

    // Modal Receipt Dialog
    if (provider.showReceiptDialog && provider.lastCompletedOrder != null) {
      final order = provider.lastCompletedOrder!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (ctx) => ReceiptModal(
            orderWithItems: order,
            onDismiss: () {
              provider.closeReceiptDialog();
              Navigator.pop(ctx);
            },
          ),
        );
      });
    }

    return Scaffold(
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : _buildScreen(provider.currentTab),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: provider.currentTab.index,
        onDestinationSelected: (index) {
          provider.setTab(AppNavTab.values[index]);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'Kasir',
          ),
          NavigationDestination(
            icon: Icon(Icons.table_bar_outlined),
            selectedIcon: Icon(Icons.table_bar),
            label: 'Meja',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Riwayat',
          ),
          NavigationDestination(
            icon: Icon(Icons.assessment_outlined),
            selectedIcon: Icon(Icons.assessment),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Menu',
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(AppNavTab tab) {
    switch (tab) {
      case AppNavTab.pos:
        return const PosScreen();
      case AppNavTab.tables:
        return const TablesScreen();
      case AppNavTab.transactions:
        return const TransactionsScreen();
      case AppNavTab.reports:
        return const ReportsScreen();
      case AppNavTab.menuManagement:
        return const MenuManagementScreen();
    }
  }
}
