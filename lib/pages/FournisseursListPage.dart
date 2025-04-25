import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'FournisseurDetailPage.dart'; // Import de la nouvelle page

class FournisseursListPage extends StatefulWidget {
  const FournisseursListPage({super.key});

  @override
  _FournisseursListPageState createState() => _FournisseursListPageState();
}

class _FournisseursListPageState extends State<FournisseursListPage> {
  late Database _database;
  List<Map<String, dynamic>> _suppliers = [];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(join(dbPath, 'stock_database.db'));

    final List<Map<String, dynamic>> supplierMaps = await _database.query(
      'suppliers',
      orderBy: 'date_ajout DESC',
    );

    setState(() {
      _suppliers = supplierMaps;
    });
  }

  Future<void> _refreshData() async {
    await _loadSuppliers();
  }

  Future<void> _deleteSupplier(int id) async {
    await _database.transaction((txn) async {
      // 1. D'abord supprimer les paiements associés
      await txn.delete('payments', where: 'supplier_id = ?', whereArgs: [id]);
      await txn.delete(
        'payment_history',
        where: 'supplier_id = ?',
        whereArgs: [id],
      );

      // 2. Ensuite supprimer le fournisseur
      await txn.delete('suppliers', where: 'id = ?', whereArgs: [id]);
    });
    _loadSuppliers();
  }

  Future<bool?> _confirmDelete(BuildContext context, int id) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text(
              'Voulez-vous vraiment supprimer ce fournisseur ? Cette action est irréversible.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FOURNISSEURS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body:
          _suppliers.isEmpty
              ? const Center(
                child: Text(
                  'Aucun fournisseur disponible',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
              : RefreshIndicator(
                onRefresh:
                    _refreshData, // Rafraîchir les données en glissant vers le bas
                child: ListView.builder(
                  itemCount: _suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = _suppliers[index];
                    return Dismissible(
                      key: Key(supplier['id'].toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        try {
                          final shouldDelete = await _confirmDelete(
                            context,
                            supplier['id'],
                          );
                          if (shouldDelete == true) {
                            await _deleteSupplier(supplier['id']);
                            return true;
                          }
                          return false;
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Erreur: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return false;
                        }
                      },
                      child: InkWell(
                        onTap: () async {
                          // Attendre le retour de la page de détail
                          final shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => FournisseurDetailPage(
                                    fournisseur: supplier,
                                  ),
                            ),
                          );

                          // Si un paiement a été effectué, rafraîchir les données
                          if (shouldRefresh == true) {
                            _refreshData();
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: ListTile(
                            title: Text(supplier['name']),
                            leading: const Icon(
                              Icons.person,
                              color: Color.fromARGB(255, 35, 189, 255),
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
