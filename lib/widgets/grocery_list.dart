import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  bool _isLoading = true;
  List<GroceryItem> _groceryItems = [];
  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https('shopping-list-c4554-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final res = await http.get(url);
    final Map<String, dynamic> listItem = json.decode(res.body);
    final List<GroceryItem> loadedItems = [];
    for (var item in listItem.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _groceryItems.isNotEmpty
              ? ListView.builder(
                  itemCount: _groceryItems.length,
                  itemBuilder: (context, index) {
                    final item = _groceryItems[index];
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      key: ValueKey(item.id),
                      onDismissed: (direction) {
                        _removeItem(item);
                      },
                      child: ListTile(
                        leading: Container(
                          width: 24,
                          height: 24,
                          color: item.category.color,
                        ),
                        title: Text(item.name),
                        trailing: Text(
                          item.quantity.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('No items added yet.'),
                ),
    );
  }
}
