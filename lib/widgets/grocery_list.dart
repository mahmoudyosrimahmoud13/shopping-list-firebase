import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  bool isLoading = true;
  List<GroceryItem> _groceryItems = [];
  String? error;

  @override
  void initState() {
    _loadItems();
    // TODO: implement initState
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-b192e-default-rtdb.firebaseio.com', 'shoping-list.json');
    try {
      final response = await http.get(url);
      if (response.statusCode >= 404) {
        setState(() {
          error = 'Failed to connect with server';
        });
      }
      if (response.body == 'null') {
        setState(() {
          isLoading = false;
        });
        return;
      }
      Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (element) => element.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            category: category,
            quantity: item.value['quantity']));
      }
      setState(() {
        _groceryItems = loadedItems;
        isLoading = false;
      });

      print(listData);
    } catch (_error) {
      setState(() {
        error = 'Something went wrong';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const NewItem(),
    ));
    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  void removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    _groceryItems.remove(item);

    final url = Uri.https('flutter-b192e-default-rtdb.firebaseio.com',
        'shoping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: Center(
        child: error != null
            ? Text(error!)
            : isLoading
                ? Center(child: CircularProgressIndicator())
                : _groceryItems.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('your list is empty'),
                            ],
                          )
                        ],
                      )
                    : ListView.builder(
                        itemCount: _groceryItems.length,
                        itemBuilder: (cxt, index) => Dismissible(
                          onDismissed: (direction) {
                            removeItem(_groceryItems[index]);
                          },
                          key: UniqueKey(),
                          child: ListTile(
                            title: Text(_groceryItems[index].name),
                            leading: Container(
                              height: 24,
                              width: 24,
                              color: _groceryItems[index].category.color,
                            ),
                            trailing:
                                Text(_groceryItems[index].quantity.toString()),
                          ),
                        ),
                      ),
      ),
    );
  }
}
