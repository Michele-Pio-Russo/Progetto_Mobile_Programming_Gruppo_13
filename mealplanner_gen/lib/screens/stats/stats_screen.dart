import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final catMap = provider.recipesByCategory;
    final ingMap = provider.ingredientUsageCount;
    final topIngredients = ingMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = topIngredients.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiche')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary cards
            Row(
              children: [
                _StatCard(
                  icon: Icons.menu_book,
                  label: 'Ricette',
                  value: '${provider.recipes.length}',
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.kitchen,
                  label: 'Prodotti',
                  value: '${provider.pantryItems.length}',
                  color: AppTheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatCard(
                  icon: Icons.calendar_today,
                  label: 'Pasti questa settimana',
                  value: '${provider.weeklyMealsCount}',
                  color: Colors.purple,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.access_time,
                  label: 'Tempo medio prep.',
                  value: '${provider.avgPrepTime.toStringAsFixed(0)} min',
                  color: Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _StatCard(
                  icon: Icons.warning_amber,
                  label: 'In scadenza',
                  value: '${provider.expiringItems.length}',
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.trending_down,
                  label: 'In esaurimento',
                  value: '${provider.lowStockItems.length}',
                  color: Colors.amber,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pie chart - recipes by category
            if (catMap.isNotEmpty) ...[
              const Text('Ricette per categoria',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(catMap),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: catMap.entries.map((e) {
                        final idx = catMap.keys.toList().indexOf(e.key);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                color: _chartColors[idx % _chartColors.length],
                              ),
                              const SizedBox(width: 6),
                              Text('${e.key} (${e.value})',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Top ingredients
            if (top5.isNotEmpty) ...[
              const Text('Ingredienti più usati',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary)),
              const SizedBox(height: 12),
              ...top5.asMap().entries.map((e) {
                final maxVal = top5.first.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e.value.key),
                          Text('${e.value.value} ricette',
                              style: const TextStyle(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: maxVal > 0 ? e.value.value / maxVal : 0,
                        color: _chartColors[e.key % _chartColors.length],
                        backgroundColor: Colors.grey.shade200,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                );
              }),
            ],

            // Expiring items section
            if (provider.expiringItems.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Prodotti in scadenza',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange)),
              const SizedBox(height: 8),
              ...provider.expiringItems.map((item) => ListTile(
                    dense: true,
                    leading:
                        const Icon(Icons.warning_amber, color: Colors.orange),
                    title: Text(item.name),
                    subtitle: item.expiryDate != null
                        ? Text(
                            item.isExpired
                                ? 'SCADUTO'
                                : 'Scade tra ${item.expiryDate!.difference(DateTime.now()).inDays} giorni',
                            style: TextStyle(
                                color: item.isExpired
                                    ? Colors.red
                                    : Colors.orange))
                        : null,
                  )),
            ],
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> map) {
    final total = map.values.fold(0, (a, b) => a + b);
    return map.entries.toList().asMap().entries.map((e) {
      final idx = e.key;
      final entry = e.value;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: total > 0
            ? '${(entry.value / total * 100).toStringAsFixed(0)}%'
            : '',
        color: _chartColors[idx % _chartColors.length],
        radius: 70,
        titleStyle: const TextStyle(
            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      );
    }).toList();
  }

  static const List<Color> _chartColors = [
    AppTheme.primary,
    AppTheme.secondary,
    Colors.blue,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
  ];
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.8))),
            ],
          ),
        ),
      );
}
