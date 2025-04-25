import 'package:flutter/material.dart';
import 'package:my_store/pages/FournisseursListPage.dart';
import 'package:my_store/pages/PaymentHistoryPage.dart';
import 'package:my_store/pages/StocksListPage.dart';
import 'package:my_store/services/responsive_helper.dart';
import 'package:my_store/widgets/responsive_wrapper.dart';
import 'StockForm.dart'; // Importez le formulaire de gestion de stock
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalAmount = 0.0;
  double totalQuantity = 0.0;
  bool _isLoading = false; // Variable pour gérer l'état du chargement

  Future<void> backupDatabase(BuildContext context) async {
    try {
      // Vérifier et demander la permission d'écriture
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception("Permission de stockage refusée !");
      }

      // Récupérer le chemin de la base de données SQLite
      String dbPath = join(await getDatabasesPath(), 'stock_database.db');
      File dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw Exception("Base de données introuvable !");
      }

      // Définir l'emplacement de sauvegarde (dossier Documents)
      Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        throw Exception("Impossible d'accéder au stockage !");
      }

      String backupPath = join(
        directory.path,
        "stock_backup_${DateTime.now().toIso8601String()}.db",
      );

      // Copier la base de données
      await dbFile.copy(backupPath);

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sauvegarde réussie dans: $backupPath")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Échec de la sauvegarde : $e")));
    }
  }

  // Fonction pour récupérer le montant total des stocks
  Future<void> getTotalAmountAndQuantity() async {
    setState(() {
      _isLoading = true; // Activer le chargement
    });

    final db = await openDatabase(
      join(await getDatabasesPath(), 'stock_database.db'),
    );

    // Calculer la somme des montants des stocks
    final List<Map<String, dynamic>> resultAmount = await db.rawQuery(
      'SELECT SUM(amount) as total FROM stocks',
    );

    // Calculer la somme des quantités des stocks
    final List<Map<String, dynamic>> resultQuantity = await db.rawQuery(
      'SELECT SUM(exact_quantity) as totalQuantity FROM stocks',
    );

    setState(() {
      totalAmount = resultAmount.first['total'] ?? 0.0;
      totalQuantity = (resultQuantity.first["totalQuantity"] ?? 0.0) as double;
      _isLoading = false; // Désactiver le chargement
    });
  }

  String formatNumber(num value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getTotalAmountAndQuantity(); // Initialiser le montant et la quantité lors du chargement de la page
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Empêche le retour en arrière
      child: Scaffold(
        appBar: AppBar(
          leading: null, // Désactiver le bouton de retour
          automaticallyImplyLeading:
              false, // Supprime l'icône de retour par défaut
          title: ResponsiveWrapper(
            child: Row(
              children: [
                Image.asset(
                  "images/man.png",
                  height: ResponsiveHelper.getAdaptiveIconSize(context),
                ),
                SizedBox(width: ResponsiveHelper.getAdaptiveSpacing(context)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hey toi !',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          12,
                        ),
                      ),
                    ),
                    Text(
                      'Bonjour',
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getAdaptiveFontSize(
                          context,
                          16,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        body: RefreshIndicator(
          onRefresh: getTotalAmountAndQuantity, // Pull-to-refresh
          child: ResponsiveWrapper(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  Container(
                    margin: ResponsiveHelper.getAdaptivePadding(context),
                    width:
                        ResponsiveHelper.getScreenWidth(context) *
                        (ResponsiveHelper.isMobile(context) ? 0.95 : 0.9),
                    height: ResponsiveHelper.isMobile(context) ? 180 : 200,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color.fromARGB(255, 31, 113, 255),
                          Color.fromARGB(255, 35, 189, 255),
                          Color.fromARGB(255, 32, 233, 255),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        tileMode: TileMode.mirror,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 109, 177, 255),
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              height: ResponsiveHelper.getAdaptiveSpacing(
                                context,
                              ),
                            ),
                            Image.asset(
                              "images/dollar.png",
                              height:
                                  ResponsiveHelper.getAdaptiveIconSize(
                                    context,
                                  ) *
                                  2,
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Montant Total des Stocks',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  '${formatNumber(totalAmount)} FCFA',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          20,
                                        ),
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width:
                                  ResponsiveHelper.getAdaptiveSpacing(context) *
                                  2,
                            ),
                            Image.asset(
                              "images/boxes.png",
                              height:
                                  ResponsiveHelper.getAdaptiveIconSize(
                                    context,
                                  ) *
                                  2,
                            ),
                            Expanded(
                              child: ListTile(
                                title: Text(
                                  'Quantité Totale des Stocks',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          16,
                                        ),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  '${formatNumber(totalQuantity)} unités',
                                  style: TextStyle(
                                    fontSize:
                                        ResponsiveHelper.getAdaptiveFontSize(
                                          context,
                                          20,
                                        ),
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ResponsiveHelper.getAdaptiveSpacing(context) * 2,
                  ),
                  Container(
                    margin: ResponsiveHelper.getAdaptivePadding(context),
                    child: ResponsiveGrid(
                      children: [
                        _buildMenuCard(
                          context,
                          "Stocks",
                          "images/stock.png",
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StocksListPage(),
                            ),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          "Fournisseurs",
                          "images/contact-book.png",
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const FournisseursListPage(),
                            ),
                          ),
                        ),
                        _buildMenuCard(
                          context,
                          "Paiement",
                          "images/cash-payment.png",
                          () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder:
                                  (context) => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                            );
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const PaymentHistoryPage(),
                              ),
                            );
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(_createCustomPageRoute(const StockForm())).then((_) {
              getTotalAmountAndQuantity();
            });
          },
          backgroundColor: const Color.fromARGB(255, 35, 189, 255),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    String imagePath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 235, 247, 255),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(255, 144, 211, 255),
              blurRadius: 3.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: ResponsiveHelper.getAdaptiveIconSize(context) * 2,
            ),
            SizedBox(height: ResponsiveHelper.getAdaptiveSpacing(context)),
            Text(
              title,
              style: TextStyle(
                fontSize: ResponsiveHelper.getAdaptiveFontSize(context, 15),
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Crée une animation de transition personnalisée
  PageRouteBuilder _createCustomPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
