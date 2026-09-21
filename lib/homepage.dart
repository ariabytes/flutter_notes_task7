import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'crud_service.dart';
import 'login_page.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  final CrudService service = CrudService();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController qtyCtrl = TextEditingController();

  bool showFavorites = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 231, 237),

      appBar: AppBar(
        title: const Text('Firebase Añora'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 201, 216),

        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                showFavorites = !showFavorites;
              });
            },
            icon: Icon(
              showFavorites
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: Colors.pink,
            ),
          ),

          // LOGOUT
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();

              if (!context.mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),

      // ADD ITEM
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 250, 131, 167),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => openAddDialog(context),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: showFavorites // if pressed kay makita ang fave list
            ? service.getFavoriteItems()
            : service.getItems(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return Center(
              child: Text(
                showFavorites
                    ? "No favorite items!"
                    : "No items found!",
                style: const TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(7),
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final item = docs[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12),
                ),

                margin: const EdgeInsets.symmetric(vertical: 6),

                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    item['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "Quantity ${item['quantity']}",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => addFavorite(
                          item.id,
                          item['isFavorite'] ?? false,
                        ),
                        icon: Icon(
                          item['isFavorite'] ?? false
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: Colors.pink,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.orange,
                        ),
                        onPressed: () =>
                            openEditDialog(context, item),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            _confirmDelete(context, item.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // FAVORITE
  void addFavorite(String id, bool currentFavorite) {
    service.updateFavorite(id, !currentFavorite,
    );
  }

  // DELETE UI
  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),

        content: const Text(
          "Are you sure you want to delete this item?",
        ),

        actions: [
          TextButton(
            onPressed: () {
              service.deleteItems(id);
              Navigator.pop(context);
            },

            child: const Text(
              "Delete",
              style: TextStyle(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ADD UI
  void openAddDialog(BuildContext context) {
    nameCtrl.clear();
    qtyCtrl.clear();

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Add Item"),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: nameCtrl,

              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: qtyCtrl,

              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text('Cancel'),
          ),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink[100],

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            onPressed: () {
              if (nameCtrl.text.isNotEmpty &&
                  qtyCtrl.text.isNotEmpty) {
                service.addItems(
                  nameCtrl.text,
                  int.parse(qtyCtrl.text),
                );

                Navigator.pop(context);
              }
            },

            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // EDIT UI
  void openEditDialog(
    BuildContext context,
    DocumentSnapshot item,
  ) {
    nameCtrl.text = item['name'];
    qtyCtrl.text = item['quantity'].toString();

    showDialog(
      context: context,

      builder: (_) => AlertDialog(
        title: const Text("Edit Item"),

        content: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            TextField(
              controller: nameCtrl,

              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: qtyCtrl,

              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),

            child: const Text('Cancel'),
          ),

          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty &&
                  qtyCtrl.text.isNotEmpty) {
                service.updateItems(
                  item.id,
                  nameCtrl.text,
                  int.parse(qtyCtrl.text),
                );

                Navigator.pop(context);
              }
            },

            style: TextButton.styleFrom(
              backgroundColor: Colors.orange[300],

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
