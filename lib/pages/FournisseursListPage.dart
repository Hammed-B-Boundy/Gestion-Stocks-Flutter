import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'FournisseurDetailPage.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';

class FournisseursListPage extends StatefulWidget {
  const FournisseursListPage({super.key});

  @override
  _FournisseursListPageState createState() => _FournisseursListPageState();
}

class _FournisseursListPageState extends State<FournisseursListPage> {
  late Database _database;
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _filteredSuppliers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
      _filteredSuppliers = supplierMaps;
    });
  }

  void _filterSuppliers(String query) {
    setState(() {
      _filteredSuppliers =
          _suppliers.where((supplier) {
            final name = supplier['name'].toString().toLowerCase();
            return name.contains(query.toLowerCase());
          }).toList();
    });
  }

  Future<void> _refreshData() async {
    await _loadSuppliers();
  }

  Future<void> _deleteSupplier(int id) async {
    await _database.transaction((txn) async {
      await txn.delete('payments', where: 'supplier_id = ?', whereArgs: [id]);
      await txn.delete(
        'payment_history',
        where: 'supplier_id = ?',
        whereArgs: [id],
      );
      await txn.delete('suppliers', where: 'id = ?', whereArgs: [id]);
    });
    _loadSuppliers();
  }

  Future<bool?> _confirmDelete(BuildContext context, int id) async {
    return await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) => AlertDialog(
            title: Text(
              'Confirmation',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 18),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Voulez-vous vraiment supprimer ce fournisseur ? Cette action est irréversible.',
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(
                  'Annuler',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext, true);
                },
                child: Text(
                  'Supprimer',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                    color: Colors.red,
                  ),
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
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un fournisseur...',
                    hintStyle: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(
                        context,
                        16,
                      ),
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 16),
                    color: Colors.black,
                  ),
                  onChanged: _filterSuppliers,
                )
                : Text(
                  'FOURNISSEURS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 20),
                  ),
                ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _filteredSuppliers = _suppliers;
                }
              });
            },
          ),
        ],
      ),
      body: ResponsiveWrapper(
        child:
            _filteredSuppliers.isEmpty
                ? Center(
                  child: Text(
                    _isSearching && _suppliers.isNotEmpty
                        ? 'Aucun résultat trouvé'
                        : 'Aucun fournisseur disponible',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveFontSize(
                        context,
                        16,
                      ),
                      color: Colors.grey,
                    ),
                  ),
                )
                : RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView.builder(
                    itemCount: _filteredSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = _filteredSuppliers[index];
                      return Dismissible(
                        key: Key(supplier['id'].toString()),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                            right:
                                ResponsiveHelper.getAdaptiveSpacing(context) *
                                2,
                          ),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size:
                                ResponsiveHelper.getAdaptiveIconSize(context) *
                                1.5,
                          ),
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
                            final shouldRefresh = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FournisseurDetailPage(
                                      fournisseur: supplier,
                                    ),
                              ),
                            );

                            if (shouldRefresh == true) {
                              _refreshData();
                            }
                          },
                          child: Container(
                            margin: ResponsiveHelper.getAdaptivePadding(
                              context,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                supplier['name'],
                                style: TextStyle(
                                  fontSize:
                                      ResponsiveHelper.getAdaptiveFontSize(
                                        context,
                                        16,
                                      ),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              leading: Icon(
                                Icons.person,
                                color: const Color.fromARGB(255, 35, 189, 255),
                                size:
                                    ResponsiveHelper.getAdaptiveIconSize(
                                      context,
                                    ) *
                                    1.2,
                              ),
                              trailing: Icon(
                                Icons.arrow_forward,
                                size: ResponsiveHelper.getAdaptiveIconSize(
                                  context,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
