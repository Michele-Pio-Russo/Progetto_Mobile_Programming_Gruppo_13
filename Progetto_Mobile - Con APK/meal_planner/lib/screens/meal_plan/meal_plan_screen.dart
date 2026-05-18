import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/meal_entry.dart';
import '../../utils/app_theme.dart';
import 'meal_form_screen.dart';
import '../recipes/recipe_detail_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));
  void _nextWeek() =>
      setState(() => _weekStart = _weekStart.add(const Duration(days: 7)));

  @override
  Widget build(BuildContext context) {
    final weekEnd = _weekStart.add(const Duration(days: 6));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Piano Pasti'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'Genera lista spesa dalla settimana',
            onPressed: () {
              context
                  .read<AppProvider>()
                  .generateShoppingListFromMealPlan(_weekStart);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lista della spesa aggiornata!'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Week navigation
          Container(
            color: const Color(0xFFF1F8F1),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: const Icon(Icons.chevron_left), onPressed: _prevWeek),
                Text(
                  '${DateFormat('d MMM', 'it').format(_weekStart)} – ${DateFormat('d MMM yyyy', 'it').format(weekEnd)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextWeek),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 7,
              padding: const EdgeInsets.all(12),
              itemBuilder: (ctx, i) {
                final day = _weekStart.add(Duration(days: i));
                return _DayCard(day: day);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime day;
  const _DayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final meals = provider.mealsForDate(day);
    final isToday = _isToday(day);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isToday
            ? const BorderSide(color: AppTheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: ExpansionTile(
        initiallyExpanded: isToday,
        leading: CircleAvatar(
          backgroundColor:
              isToday ? AppTheme.primary : Colors.grey.shade200,
          child: Text(
            DateFormat('d', 'it').format(day),
            style: TextStyle(
                color: isToday ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          DateFormat('EEEE', 'it').format(day),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isToday ? AppTheme.primary : null),
        ),
        subtitle: meals.isEmpty
            ? const Text('Nessun pasto pianificato',
                style: TextStyle(color: Colors.grey, fontSize: 12))
            : Text('${meals.length} pasti',
                style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: AppTheme.primary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => MealFormScreen(date: day)),
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
        children: [
          ...meals.map((m) => _MealTile(meal: m)),
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MealFormScreen(date: day)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Aggiungi pasto'),
              ),
            ),
        ],
      ),
    );
  }

  bool _isToday(DateTime day) {
    final now = DateTime.now();
    return day.year == now.year &&
        day.month == now.month &&
        day.day == now.day;
  }
}

class _MealTile extends StatelessWidget {
  final MealEntry meal;
  const _MealTile({required this.meal});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final recipe =
        meal.recipeId != null ? provider.recipeById(meal.recipeId!) : null;
    final title = recipe?.name ?? meal.customLabel;

    return ListTile(
      dense: true,
      leading: _mealTypeIcon(meal.mealType),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(meal.mealType,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (recipe != null)
            IconButton(
              icon: const Icon(Icons.info_outline, size: 18),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        RecipeDetailScreen(recipeId: recipe.id)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      MealFormScreen(date: meal.date, meal: meal)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            onPressed: () =>
                context.read<AppProvider>().deleteMealEntry(meal.id),
          ),
        ],
      ),
    );
  }

  Widget _mealTypeIcon(String type) {
    final icons = {
      'Colazione': Icons.free_breakfast,
      'Pranzo': Icons.lunch_dining,
      'Cena': Icons.dinner_dining,
      'Spuntino': Icons.apple,
    };
    return Icon(icons[type] ?? Icons.restaurant,
        color: AppTheme.primary, size: 22);
  }
}
