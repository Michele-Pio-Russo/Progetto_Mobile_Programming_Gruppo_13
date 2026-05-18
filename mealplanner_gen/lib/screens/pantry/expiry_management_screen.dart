import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/pantry_item.dart';
import '../../utils/app_theme.dart';
import '../pantry/pantry_form_screen.dart';

class ExpiryManagementScreen extends StatefulWidget {
  const ExpiryManagementScreen({super.key});

  @override
  State<ExpiryManagementScreen> createState() => _ExpiryManagementScreenState();
}

class _ExpiryManagementScreenState extends State<ExpiryManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final expired = provider.expiredItems;
    final expiring = provider.pantryItems
        .where((p) =>
            !p.isExpired && p.isExpiringSoonWithin(provider.expiryWarningDays))
        .toList()
      ..sort((a, b) => (a.daysUntilExpiry ?? 999).compareTo(b.daysUntilExpiry ?? 999));
    final ok = provider.pantryItems
        .where((p) =>
            !p.isExpired &&
            !p.isExpiringSoonWithin(provider.expiryWarningDays) &&
            p.expiryDate != null)
        .toList()
      ..sort((a, b) => a.expiryDate!.compareTo(b.expiryDate!));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestione Scadenze'),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Impostazioni soglia',
            onPressed: () => _showThresholdDialog(context, provider),
          ),
          if (expired.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Elimina tutti i prodotti scaduti',
              onPressed: () => _confirmDeleteAll(context, expired.length),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              child: _TabLabel(
                label: 'Scaduti',
                count: expired.length,
                color: Colors.red.shade200,
              ),
            ),
            Tab(
              child: _TabLabel(
                label: 'In scadenza',
                count: expiring.length,
                color: Colors.orange.shade200,
              ),
            ),
            Tab(
              child: _TabLabel(
                label: 'OK',
                count: ok.length,
                color: Colors.green.shade200,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildThresholdBanner(provider.expiryWarningDays),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ExpiryList(
                  items: expired,
                  emptyMessage: 'Nessun prodotto scaduto',
                  emptyIcon: Icons.check_circle_outline,
                  emptyColor: Colors.green,
                  statusColor: Colors.red,
                  showDeleteAction: true,
                ),
                _ExpiryList(
                  items: expiring,
                  emptyMessage: 'Nessun prodotto in scadenza',
                  emptyIcon: Icons.thumb_up_outlined,
                  emptyColor: Colors.orange,
                  statusColor: Colors.orange,
                  showDeleteAction: false,
                  warningDays: provider.expiryWarningDays,
                ),
                _ExpiryList(
                  items: ok,
                  emptyMessage: 'Nessun prodotto con scadenza registrata',
                  emptyIcon: Icons.info_outline,
                  emptyColor: Colors.grey,
                  statusColor: Colors.green,
                  showDeleteAction: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThresholdBanner(int days) => Container(
        color: const Color(0xFFFBE9E7),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text(
              'Avviso anticipato: $days giorni prima della scadenza',
              style: const TextStyle(fontSize: 13, color: Colors.deepOrange),
            ),
          ],
        ),
      );

  void _showThresholdDialog(BuildContext context, AppProvider provider) {
    int selected = provider.expiryWarningDays;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Soglia avviso scadenza'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Quanti giorni prima della scadenza vuoi essere avvisato?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: selected > 1
                        ? () => setS(() => selected--)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE9E7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$selected giorni',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: selected < 30
                        ? () => setS(() => selected++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [1, 3, 5, 7, 14].map((d) {
                  return ActionChip(
                    label: Text('$d g'),
                    onPressed: () => setS(() => selected = d),
                    backgroundColor: selected == d
                        ? const Color(0xFFFFCCBC)
                        : null,
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annulla')),
            TextButton(
              onPressed: () {
                provider.setExpiryWarningDays(selected);
                Navigator.pop(ctx);
              },
              child: const Text('Salva',
                  style: TextStyle(color: Colors.deepOrange)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elimina prodotti scaduti'),
        content: Text(
            'Vuoi rimuovere dalla dispensa tutti i $count prodotti scaduti?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla')),
          TextButton(
            onPressed: () {
              context.read<AppProvider>().deleteExpiredItems();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Prodotti scaduti rimossi.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Elimina tutti',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TabLabel extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _TabLabel(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ],
        ],
      );
}

class _ExpiryList extends StatelessWidget {
  final List<PantryItem> items;
  final String emptyMessage;
  final IconData emptyIcon;
  final Color emptyColor;
  final Color statusColor;
  final bool showDeleteAction;
  final int? warningDays;

  const _ExpiryList({
    required this.items,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.emptyColor,
    required this.statusColor,
    required this.showDeleteAction,
    this.warningDays,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 64, color: emptyColor),
            const SizedBox(height: 12),
            Text(emptyMessage,
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _ExpiryCard(
        item: items[i],
        statusColor: statusColor,
        showDeleteAction: showDeleteAction,
      ),
    );
  }
}

class _ExpiryCard extends StatelessWidget {
  final PantryItem item;
  final Color statusColor;
  final bool showDeleteAction;

  const _ExpiryCard({
    required this.item,
    required this.statusColor,
    required this.showDeleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final days = item.daysUntilExpiry;
    String statusText;
    if (item.isExpired) {
      final overdueDays = DateTime.now().difference(item.expiryDate!).inDays;
      statusText = 'Scaduto da $overdueDays ${overdueDays == 1 ? 'giorno' : 'giorni'}';
    } else if (days == 0) {
      statusText = 'Scade oggi!';
    } else if (days == 1) {
      statusText = 'Scade domani';
    } else if (days != null) {
      statusText = 'Scade tra $days giorni';
    } else {
      statusText = 'Scade il ${DateFormat('dd/MM/yyyy').format(item.expiryDate!)}';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: statusColor, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // urgency indicator
            Container(
              width: 6,
              height: 56,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}  ·  ${item.category}',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        item.isExpired
                            ? Icons.error_outline
                            : Icons.schedule,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PantryFormScreen(item: item)),
                  ),
                ),
                if (showDeleteAction)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: Colors.red),
                    onPressed: () => _confirmDelete(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
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
            child:
                const Text('Elimina', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
