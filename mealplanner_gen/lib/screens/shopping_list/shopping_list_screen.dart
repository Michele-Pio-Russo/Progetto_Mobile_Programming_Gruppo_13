import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/shopping_item.dart';
import '../../utils/app_theme.dart';
import 'shopping_form_screen.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final items = provider.shoppingItems;
    final pending = items.where((s) => !s.isPurchased).toList();
    final purchased = items.where((s) => s.isPurchased).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista della Spesa'),
        actions: [
          if (purchased.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: 'Rimuovi acquistati',
              onPressed: () => _confirmClearPurchased(context),
            ),
        ],
      ),
      body: items.isEmpty
          ? _buildEmpty(context)
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                if (pending.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'Da acquistare (${pending.length})'),
                  ...pending.map((item) => _ShoppingTile(item: item)),
                ],
                if (purchased.isNotEmpty) ...[
                  _SectionHeader(
                      title: 'Acquistati (${purchased.length})',
                      color: Colors.grey),
                  ...purchased.map((item) => _ShoppingTile(item: item)),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ShoppingFormScreen()),
        ),
        icon: const Icon(Icons.add_shopping_cart),
        label: const Text('Aggiungi'),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined,
                size: 72, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Lista vuota',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Aggiungi articoli manualmente\no genera dal piano pasti',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );

  void _confirmClearPurchased(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rimuovi acquistati'),
        content: const Text(
            'Vuoi rimuovere tutti gli articoli già acquistati dalla lista?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().clearPurchasedItems();
              Navigator.pop(context);
            },
            child: const Text('Rimuovi', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  const _SectionHeader({required this.title, this.color});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color ?? AppTheme.primary,
                fontSize: 14)),
      );
}

class _ShoppingTile extends StatelessWidget {
  final ShoppingItem item;
  const _ShoppingTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        leading: Checkbox(
          value: item.isPurchased,
          activeColor: AppTheme.primary,
          onChanged: (_) =>
              context.read<AppProvider>().toggleShoppingItem(item.id),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration:
                item.isPurchased ? TextDecoration.lineThrough : null,
            color: item.isPurchased ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}'),
            if (item.notes.isNotEmpty)
              Text(item.notes,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.sourceRecipeId != null)
              const Icon(Icons.auto_awesome, size: 16, color: Colors.amber),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShoppingFormScreen(item: item)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.red),
              onPressed: () =>
                  context.read<AppProvider>().deleteShoppingItem(item.id),
            ),
          ],
        ),
      ),
    );
  }
}
