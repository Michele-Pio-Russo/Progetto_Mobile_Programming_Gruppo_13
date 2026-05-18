import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/recipes/recipe_list_screen.dart';
import 'screens/recipes/suggestions_screen.dart';
import 'screens/pantry/pantry_screen.dart';
import 'screens/pantry/expiry_management_screen.dart';
import 'screens/meal_plan/meal_plan_screen.dart';
import 'screens/shopping_list/shopping_list_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MealPlannerApp(),
    ),
  );
}

class MealPlannerApp extends StatelessWidget {
  const MealPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner & Smart Pantry',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.suggestions:
            return MaterialPageRoute(builder: (_) => const SuggestionsScreen());
          case AppRoutes.expiryManagement:
            return MaterialPageRoute(
                builder: (_) => const ExpiryManagementScreen());
          default:
            return null;
        }
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    RecipeListScreen(),
    PantryScreen(),
    MealPlanScreen(),
    ShoppingListScreen(),
    StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Caricamento...'),
            ],
          ),
        ),
      );
    }

    final expiredCount = provider.expiredItems.length;
    final expiringCount = provider.expiringItems.length;
    final pantryAlerts = expiringCount + provider.lowStockItems.length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Banner globale per prodotti scaduti (sempre visibile su qualsiasi tab)
      bottomSheet: expiredCount > 0 && _currentIndex != 1
          ? _ExpiredGlobalBanner(count: expiredCount)
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.menu_book_outlined),
            selectedIcon: const Icon(Icons.menu_book),
            label: 'Ricette',
          ),
          NavigationDestination(
            icon: _buildBadgedIcon(
              Icons.kitchen_outlined,
              pantryAlerts,
              color: expiredCount > 0 ? Colors.red : null,
            ),
            selectedIcon: _buildBadgedIcon(
              Icons.kitchen,
              pantryAlerts,
              color: expiredCount > 0 ? Colors.red : null,
            ),
            label: 'Dispensa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Piano Pasti',
          ),
          NavigationDestination(
            icon: _buildBadgedIcon(
              Icons.shopping_cart_outlined,
              provider.shoppingItems.where((s) => !s.isPurchased).length,
            ),
            selectedIcon: _buildBadgedIcon(
              Icons.shopping_cart,
              provider.shoppingItems.where((s) => !s.isPurchased).length,
            ),
            label: 'Spesa',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Statistiche',
          ),
        ],
      ),
    );
  }

  Widget _buildBadgedIcon(IconData icon, int count, {Color? color}) {
    if (count == 0) return Icon(icon);
    return Badge(
      label: Text('$count'),
      backgroundColor: color,
      child: Icon(icon),
    );
  }
}

class _ExpiredGlobalBanner extends StatelessWidget {
  final int count;
  const _ExpiredGlobalBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpiryManagementScreen()),
      ),
      child: Container(
        width: double.infinity,
        color: Colors.red.shade700,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              '$count ${count == 1 ? 'prodotto scaduto' : 'prodotti scaduti'} — tocca per gestire',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

