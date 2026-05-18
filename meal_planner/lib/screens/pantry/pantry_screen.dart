import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/pantry_item.dart';
import '../../utils/app_theme.dart';
import 'pantry_form_screen.dart';
import 'expiry_management_screen.dart';

class PantryScreen extends StatefulWidget {
  const PantryScreen({super.key});

  @override
  State<PantryScreen> createState() => _PantryScreenState();
}

class _PantryScreenState extends State<PantryScreen> {
  String _searchQuery = '';
  String _selectedCategory = '';
  bool _showAlertsOnly = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    var items = provider.searchPantry(
      query: _searchQuery,
      category: _selectedCategory,
    );
    if (_showAlertsOnly) {
      items = items
          .where((p) => p.isExpired || p.isExpiringSoon || p.isLowStock)
          .toList();
    }

    final expiring = provider.expiringItems.length;
    final lowStock = provider.lowStockItems.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispensa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_busy_outlined),
            tooltip: 'Gestione Scadenze',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ExpiryManagementScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (expiring > 0 || lowStock > 0) _buildAlertBanner(expiring, lowStock),
          _buildSearchBar(),
          _buildCategoryFilter(),
          Expanded(
            child: items.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) => _PantryCard(
                      item: items[i],
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PantryFormScreen(item: items[i])),
                      ),
                      onDelete: () => _confirmDelete(context, items[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PantryFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Aggiungi prodotto'),
      ),
    );
  }

  Widget _buildAlertBanner(int expiring, int lowStock) => InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExpiryManagementScreen()),
        ),
        child: Container(
          color: Colors.orange.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  [
                    if (expiring > 0) '$expiring in scadenza',
                    if (lowStock > 0) '$lowStock in esaurimento',
                  ].join(' · '),
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _showAlertsOnly = !_showAlertsOnly),
                child: Text(_showAlertsOnly ? 'Mostra tutti' : 'Filtra',
                    style: const TextStyle(color: Colors.orange)),
              ),
              const Icon(Icons.chevron_right, color: Colors.orange, size: 18),
            ],
          ),
        ),
      );

  Widget _buildSearchBar() => Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
        child: TextField(
          decoration: const InputDecoration(
            hintText: 'Cerca nella dispensa...',
            prefixIcon: Icon(Icons.search),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _searchQuery = v),
        ),
      );

  Widget _buildCategoryFilter() {
    final cats = ['', ...PantryItem.categories];
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: cats.length,
        itemBuilder: (ctx, i) {
          final cat = cats[i];
          final selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat.isEmpty ? 'Tutte' : cat),
              selected: selected,
              onSelected: (_) => setState(() => _selectedCategory = cat),
              selectedColor: const Color(0xFFC8E6C9),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.kitchen, size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Dispensa vuota',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );

  void _confirmDelete(BuildContext context, PantryItem item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina prodotto'),
        content: Text('Vuoi rimuovere "${item.name}" dalla dispensa?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deletePantryItem(item.id);
              Navigator.pop(context);
            },
            child: const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PantryCard extends StatelessWidget {
  final PantryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _PantryCard(
      {required this.item, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    Color? statusColor;
    String? statusLabel;
    if (item.isExpired) {
      statusColor = Colors.red;
      statusLabel = 'Scaduto';
    } else if (item.isExpiringSoon) {
      statusColor = Colors.orange;
      statusLabel = 'In scadenza';
    } else if (item.isLowStock) {
      statusColor = Colors.amber;
      statusLabel = 'In esaurimento';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor == null
              ? const Color(0xFFE8F5E9)
              : statusColor == Colors.red
                  ? const Color(0xFFFFEBEE)
                  : statusColor == Colors.orange
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFFFFDE7),
          child: Icon(Icons.kitchen,
              color: statusColor ?? AppTheme.primary, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(item.name,
                    style: const TextStyle(fontWeight: FontWeight.w600))),
            if (statusLabel != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor == Colors.red
                      ? const Color(0xFFFFEBEE)
                      : statusColor == Colors.orange
                          ? const Color(0xFFFFF3E0)
                          : const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}  ·  ${item.category}'),
            if (item.expiryDate != null)
              Text(
                'Scadenza: ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}',
                style: TextStyle(
                    fontSize: 12,
                    color: item.isExpired
                        ? Colors.red
                        : item.isExpiringSoon
                            ? Colors.orange
                            : Colors.grey),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: onEdit),
            IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                onPressed: onDelete),
          ],
        ),
      ),
    );
  }
}
