import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimatedList Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AnimatedListDemo(),
    );
  }
}

class AnimatedListDemo extends StatefulWidget {
  const AnimatedListDemo({super.key});

  @override
  State<AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<AnimatedListDemo> {
  // Key to control the AnimatedList
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Data backing the list
  final List<String> _items = ['Flutter', 'Dart', 'Widgets'];

  int _counter = 4;

  // Add an item at the top of the list
  void _addItem() {
    final newItem = 'Item $_counter';
    _counter++;

    // Insert into data first
    _items.insert(0, newItem);

    // Tell AnimatedList to animate index 0 into view
    _listKey.currentState?.insertItem(
      0,
      duration: const Duration(milliseconds: 400),
    );
  }

  // Remove an item at the given index
  void _removeItem(int index) {
    final removedItem = _items[index];

    // Tell AnimatedList to animate the item out, then remove from data
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildRemovedItem(removedItem, animation),
      duration: const Duration(milliseconds: 350),
    );

    _items.removeAt(index);
  }

  // Widget shown while an item is sliding out
  Widget _buildRemovedItem(String label, Animation<double> animation) {
    return _ItemTile(
      label: label,
      animation: animation,
      onDelete: null, // no button during removal
      isRemoving: true,
    );
  }

  // Widget shown for a live item
  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    return _ItemTile(
      label: _items[index],
      animation: animation,
      onDelete: () => _removeItem(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AnimatedList Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        initialItemCount: _items.length,
        itemBuilder: _buildItem,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }
}

// ─── Reusable tile ────────────────────────────────────────────────────────────

class _ItemTile extends StatelessWidget {
  final String label;
  final Animation<double> animation;
  final VoidCallback? onDelete;
  final bool isRemoving;

  const _ItemTile({
    required this.label,
    required this.animation,
    required this.onDelete,
    this.isRemoving = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.label_outline, color: colorScheme.onPrimaryContainer),
            ),
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            subtitle: Text(
              isRemoving ? 'Removing…' : 'Tap 🗑 to remove',
              style: TextStyle(color: colorScheme.outline, fontSize: 12),
            ),
            trailing: onDelete != null
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.error,
                    tooltip: 'Remove',
                    onPressed: onDelete,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}