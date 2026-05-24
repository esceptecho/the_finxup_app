import 'package:flutter/material.dart';

class DismissibleListview extends StatefulWidget {
  const DismissibleListview({ super.key });

  @override
  State<DismissibleListview> createState() => _DismissibleListviewState();
}

class _DismissibleListviewState extends State<DismissibleListview> {

  // Initialize items in the initializer list.
  List<int> items = List<int>.generate(100, (int index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Added Scaffold to provide basic Material Design visual structure
      appBar: AppBar(
        title: const Text('Dismissible List Items'), // Added a title for clarity
      ),
      body: ListView.builder(
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (BuildContext context, int index) {
          // Check for index bounds to prevent errors if items are removed quickly
          if (index >= items.length) {
            return const SizedBox.shrink(); // Return an empty widget if index is out of bounds
          }
          return Dismissible(
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft, // Align icon to the left
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.green,
              alignment: Alignment.centerRight, // Align icon to the right
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.archive, color: Colors.white),
            ),
            key: ValueKey<int>(items[index]),
            onDismissed: (DismissDirection direction) {
              // Show a SnackBar to confirm dismissal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Item ${items[index]} dismissed')),
              );
              // Update state to remove the item
              setState(() {
                items.removeAt(index);
              });
            },
            child: Card( // Wrap ListTile in a Card for better visual separation
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(
                  'Item ${items[index]}',
                ),
                subtitle: Text('Swipe to dismiss'),
              ),
            ),
          );
        },
      ),
    );
  }
}
