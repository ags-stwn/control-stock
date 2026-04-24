import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://vqhsrrlofnyccjxkgmmn.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxaHNycmxvZm55Y2NqeGtnbW1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NzA1MzcsImV4cCI6MjA5MjA0NjUzN30.4OQ_8ZybM6DcwaTd3jMHH5BXv5hbwFtLEESBbFOQ7ag',
    );
  } catch (e) {
    print('Error initializing Supabase: $e');
    rethrow;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Stock Tyre',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ==============================================
// UTILITY FUNCTIONS
// ==============================================
class Utils {
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  static String getFormattedDateTime() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final dayName = days[now.weekday % 7];
    return "$dayName, ${now.day}/${now.month}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  static String getDayName() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return days[now.weekday % 7];
  }

  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ==============================================
// HOME PAGE
// ==============================================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _showCekActualDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "PILIH METODE CEK ACTUAL",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.search),
                      label: const Text("CEK BY CODE", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CekByCodePage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.location_on),
                      label: const Text("CEK BY AREA", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CekByAreaPage()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("BATAL", style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const String urlFotoBackground = "https://69dbf2b2c534e6001cd5c84a.imgix.net/nki/ef03e464-01f3-4760-80c8-8bda16d638d4.jpeg?w=1600&h=1600&fm=png";
    const String urlLogoNki = "https://69dbf2b2c534e6001cd5c84a.imgix.net/nki2/Firefly.png";

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.network(
              urlFotoBackground,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
            ),
          ),
          SizedBox.expand(
            child: Container(color: Colors.black.withOpacity(0.6)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        urlLogoNki,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.business, size: 80, color: Colors.white);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text("MONITORING STOCK", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const Text("TYRE WH-5", style: TextStyle(fontSize: 22, color: Colors.yellowAccent)),
                      const SizedBox(height: 50),
                      _buildMenuButton(context, "STOCK ADMIN", Colors.green, Icons.inventory_2, const StockAdminPage()),
                      const SizedBox(height: 20),
                      _buildMenuButton(context, "DATA NON GWS", Colors.orange, Icons.history, const NonGwsTablePage()),
                      const SizedBox(height: 20),
                      _buildMenuButtonWithSubmenu(context, "CEK ACTUAL", Colors.purple, Icons.check_circle),
                      const SizedBox(height: 40),
                      const Text("PT. NIPPON KONPO INDONESIA", style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Color color, IconData icon, Widget targetPage) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => targetPage)),
      ),
    );
  }

  Widget _buildMenuButtonWithSubmenu(BuildContext context, String title, Color color, IconData icon) {
    return SizedBox(
      width: 280,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 24),
        label: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () => _showCekActualDialog(context),
      ),
    );
  }
}

// ==============================================
// STOCK ADMIN PAGE
// ==============================================
class StockAdminPage extends StatefulWidget {
  const StockAdminPage({super.key});

  @override
  State<StockAdminPage> createState() => _StockAdminPageState();
}

class _StockAdminPageState extends State<StockAdminPage> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> allData = [];
  bool isLoading = true;
  String? errorMessage;
  
  int totalStock = 0;
  int totalGws = 0;
  int totalNonGws = 0;
  String lastUpdate = "";
  int totalVarian = 0;
  int variantNotInData = 0;
  
  final String adminName = "Ujang Cahyono Nurpiqih";
  bool isSummaryExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      List<Map<String, dynamic>> allDataList = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      
      while (hasMore) {
        final response = await Supabase.instance.client
            .from('stock_master')
            .select()
            .range(start, start + batchSize - 1);
        allDataList.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) {
          hasMore = false;
        } else {
          start += batchSize;
        }
      }
      
      totalStock = 0;
      totalGws = 0;
      totalNonGws = 0;
      totalVarian = allDataList.length;
      
      for (var item in allDataList) {
        totalStock += (item['stock'] ?? 0) as int;
        totalGws += (item['gws'] ?? 0) as int;
        totalNonGws += (item['non_gws'] ?? 0) as int;
      }
      
      variantNotInData = totalStock - (totalGws + totalNonGws);
      lastUpdate = Utils.getFormattedDateTime();
      
      setState(() {
        allData = allDataList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredData {
    if (searchQuery.isEmpty) {
      return allData;
    }
    final query = searchQuery.toLowerCase().trim();
    return allData.where((item) {
      final code = (item['code'] ?? '').toString().toLowerCase();
      return code.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> getProblematicVariants() {
    List<Map<String, dynamic>> problematic = [];
    for (var item in allData) {
      int stock = item['stock'] ?? 0;
      int gws = item['gws'] ?? 0;
      int nonGws = item['non_gws'] ?? 0;
      int selisih = stock - (gws + nonGws);
      if (selisih != 0) {
        problematic.add({
          'code': item['code'],
          'stock': stock,
          'gws': gws,
          'non_gws': nonGws,
          'selisih': selisih,
          'status': selisih > 0 ? 'KELEBIHAN' : 'KEKURANGAN',
        });
      }
    }
    problematic.sort((a, b) => (b['selisih'] as int).abs().compareTo((a['selisih'] as int).abs()));
    return problematic;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STOCK ADMIN"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Code...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => searchQuery = "");
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => searchQuery = value.toLowerCase().trim()),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadInitialData,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));
    if (allData.isEmpty) return const Center(child: Text("Tidak ada data"));

    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ExpansionTile(
            leading: Icon(Icons.summarize, color: Colors.blue.shade700, size: 28),
            title: const Text("RINGKASAN STOCK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            initiallyExpanded: isSummaryExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                isSummaryExpanded = expanded;
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Icon(Icons.person, size: 16, color: Colors.blue.shade700), const SizedBox(width: 8), Text("Update Stock by: $adminName", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700))]),
                          const SizedBox(height: 8),
                          Row(children: [Icon(Icons.update, size: 16, color: Colors.grey.shade600), const SizedBox(width: 8), Text("Update Terakhir: $lastUpdate", style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("ENDING STOCK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("${Utils.formatNumber(totalStock)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                const Text("GWS", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("${Utils.formatNumber(totalGws)} PCS", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                const Text("NON GWS", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text("${Utils.formatNumber(totalNonGws)} PCS", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        if (variantNotInData != 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailVarianPage(
                                problematicVariants: getProblematicVariants(),
                                totalStock: totalStock,
                                totalGws: totalGws,
                                totalNonGws: totalNonGws,
                                variantNotInData: variantNotInData,
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: variantNotInData != 0 ? Colors.red.shade50 : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(variantNotInData != 0 ? Icons.warning : Icons.check_circle, color: variantNotInData != 0 ? Colors.red : Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text("VARIAN TIDAK ADA DI DATA", style: TextStyle(fontWeight: FontWeight.bold, color: variantNotInData != 0 ? Colors.red : Colors.green)),
                                if (variantNotInData != 0) const Icon(Icons.chevron_right, size: 20, color: Colors.red),
                              ],
                            ),
                            Text(variantNotInData != 0 ? "${Utils.formatNumber(variantNotInData)} PCS" : "0 PCS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: variantNotInData != 0 ? Colors.red : Colors.green)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Total Varian: ${Utils.formatNumber(totalVarian)} item", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final item = filteredData[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text("${item['code']}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  subtitle: Text("Stock: ${item['stock']} | Balance: ${item['balance']}"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _rowInfo("GWS", item['gws']),
                          _rowInfo("NON GWS", item['non_gws']),
                          _rowInfo("STOCK", item['stock']),
                          const Divider(),
                          _rowInfo("BALANCE", item['balance'], isBold: true, color: Colors.red),
                          const SizedBox(height: 8),
                          _rowInfo("Wait Loading", item['wait_loading']),
                          _rowInfo("End Loading", item['end_loading']),
                          _rowInfo("Transport End", item['transport_end']),
                          if (item['noted'] != null && item['noted'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text("📝 ${item['noted']}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _rowInfo(String label, dynamic value, {bool isBold = false, Color color = Colors.black87}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text("${value ?? 0}", style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color)),
      ],
    );
  }
}

// ==============================================
// DETAIL VARIAN PAGE
// ==============================================
class DetailVarianPage extends StatelessWidget {
  final List<Map<String, dynamic>> problematicVariants;
  final int totalStock;
  final int totalGws;
  final int totalNonGws;
  final int variantNotInData;

  const DetailVarianPage({
    super.key,
    required this.problematicVariants,
    required this.totalStock,
    required this.totalGws,
    required this.totalNonGws,
    required this.variantNotInData,
  });

  @override
  Widget build(BuildContext context) {
    int totalKelebihan = problematicVariants
        .where((v) => v['selisih'] > 0)
        .fold(0, (sum, v) => sum + (v['selisih'] as int));
    int totalKekurangan = problematicVariants
        .where((v) => v['selisih'] < 0)
        .fold(0, (sum, v) => sum + (v['selisih'] as int).abs());

    return Scaffold(
      appBar: AppBar(
        title: const Text("DETAIL VARIAN BERMASALAH"),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red.shade50,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("TOTAL SELISIH", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("${Utils.formatNumber(variantNotInData)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            const Text("KELEBIHAN", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${Utils.formatNumber(totalKelebihan)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Column(
                          children: [
                            const Text("KEKURANGAN", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${Utils.formatNumber(totalKekurangan)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Total ${problematicVariants.length} code bermasalah", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Container(
            color: Colors.red.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                _buildHeaderCell("No", flex: 1),
                _buildHeaderCell("CODE", flex: 2),
                _buildHeaderCell("STOCK", flex: 2),
                _buildHeaderCell("GWS", flex: 2),
                _buildHeaderCell("NON GWS", flex: 2),
                _buildHeaderCell("SELISIH", flex: 2),
                _buildHeaderCell("STATUS", flex: 2),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: problematicVariants.length,
              itemBuilder: (context, index) {
                final item = problematicVariants[index];
                final bool isEven = index % 2 == 0;
                final bool isKelebihan = item['selisih'] > 0;
                return Container(
                  color: isEven ? Colors.grey.shade50 : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      _buildCell("${index + 1}", flex: 1),
                      _buildCell(item['code'].toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold),
                      _buildCell("${item['stock']}", flex: 2),
                      _buildCell("${item['gws']}", flex: 2),
                      _buildCell("${item['non_gws']}", flex: 2),
                      _buildCell("${item['selisih'] > 0 ? '+' : ''}${item['selisih']}", flex: 2, fontWeight: FontWeight.bold, color: isKelebihan ? Colors.red : Colors.orange),
                      _buildCell(item['status'], flex: 2, fontWeight: FontWeight.bold, color: isKelebihan ? Colors.red : Colors.orange),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(flex: flex, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center));
  }

  Widget _buildCell(String text, {int flex = 1, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black87, double fontSize = 13}) {
    return Expanded(flex: flex, child: Text(text, style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis));
  }
}

// ==============================================
// DETAIL BY YEAR PAGE
// ==============================================
class DetailByYearPage extends StatelessWidget {
  final int year;
  final List<Map<String, dynamic>> data;
  final int totalQty;

  const DetailByYearPage({
    super.key,
    required this.year,
    required this.data,
    required this.totalQty,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("DETAIL TAHUN $year"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.orange.shade50,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("TAHUN $year", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Text("TOTAL: $totalQty PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.orange.shade700,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                _buildHeaderCell("No", flex: 1),
                _buildHeaderCell("CODE", flex: 2),
                _buildHeaderCell("LOKASI", flex: 3),
                _buildHeaderCell("WEEKLY", flex: 2),
                _buildHeaderCell("QTY", flex: 1),
                _buildHeaderCell("STATUS", flex: 2),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final bool isEven = index % 2 == 0;
                return Container(
                  color: isEven ? Colors.grey.shade50 : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      _buildCell("${index + 1}", flex: 1),
                      _buildCell((item['code'] ?? '-').toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold),
                      _buildCell((item['lokasi'] ?? '-').toString().toUpperCase(), flex: 3, fontSize: 11),
                      _buildCell(item['weekly'] ?? '-', flex: 2),
                      _buildCell("${item['qty'] ?? 0}", flex: 1, fontWeight: FontWeight.bold, color: Colors.red),
                      _buildCell((item['status'] ?? '-').toString().toUpperCase(), flex: 2, fontSize: 11),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(flex: flex, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center));
  }

  Widget _buildCell(String text, {int flex = 1, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black87, double fontSize = 13}) {
    return Expanded(flex: flex, child: Text(text, style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis));
  }
}

// ==============================================
// NON GWS TABLE PAGE - FULL SCRIPT (TANPA ERROR HIT TEST)
// ==============================================
class NonGwsTablePage extends StatefulWidget {
  const NonGwsTablePage({super.key});

  @override
  State<NonGwsTablePage> createState() => _NonGwsTablePageState();
}

class _NonGwsTablePageState extends State<NonGwsTablePage> {
  String searchQuery = "";
  bool hasSearched = false;
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> allData = [];
  List<Map<String, dynamic>> allHistory = [];
  bool isLoading = true;
  bool isLoadingHistory = false;
  String? errorMessage;
  bool showHistory = false;
  List<String> codeList = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      List<Map<String, dynamic>> allDataList = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      
      while (hasMore) {
        final response = await Supabase.instance.client
            .from('inventory_non_gws')
            .select()
            .order('weekly', ascending: false)
            .range(start, start + batchSize - 1);
        allDataList.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) {
          hasMore = false;
        } else {
          start += batchSize;
        }
      }
      
      final normalizedData = allDataList.map((item) {
        return {
          ...item,
          'code': (item['code'] ?? '').toString().toLowerCase(),
          'lokasi': (item['lokasi'] ?? '').toString().toLowerCase(),
        };
      }).toList();
      
      codeList = normalizedData.map((e) => (e['code'] ?? '').toString().toUpperCase()).toSet().toList();
      codeList.sort();
      
      setState(() {
        allData = normalizedData;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        isLoadingHistory = true;
      });
      
      List<Map<String, dynamic>> allHistoryList = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      
      while (hasMore) {
        final response = await Supabase.instance.client
            .from('take_history')
            .select()
            .order('taken_at', ascending: false)
            .range(start, start + batchSize - 1);
        allHistoryList.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) {
          hasMore = false;
        } else {
          start += batchSize;
        }
      }
      
      setState(() {
        allHistory = allHistoryList;
        isLoadingHistory = false;
      });
    } catch (e) {
      print("Error loading history: $e");
      setState(() {
        isLoadingHistory = false;
      });
    }
  }

  List<Map<String, dynamic>> get filteredData {
    if (!hasSearched || searchQuery.isEmpty) return [];
    final query = searchQuery.toLowerCase().trim();
    return allData.where((item) {
      final code = (item['code'] ?? '').toString();
      final lokasi = (item['lokasi'] ?? '').toString();
      return code.contains(query) || lokasi.contains(query);
    }).toList();
  }

  int get totalQty => filteredData.fold(0, (sum, item) => sum + ((item['qty'] ?? 0) as int));

  Map<int, int> getSummaryByYear() {
    Map<int, int> summary = {};
    for (var item in allData) {
      String weekly = (item['weekly'] ?? '').toString();
      int year = _extractYearFromWeekly(weekly);
      int qty = (item['qty'] ?? 0) as int;
      summary[year] = (summary[year] ?? 0) + qty;
    }
    return summary;
  }
  
  int _extractYearFromWeekly(String weekly) {
    if (weekly.isEmpty || weekly == 'null' || weekly == 'N/A') return 0;
    try {
      String clean = weekly.replaceAll(RegExp(r'[^0-9]'), '');
      if (clean.length >= 4) {
        if (clean.length == 4) {
          String yearStr = clean.substring(2, 4);
          return 2000 + int.parse(yearStr);
        } else {
          String yearStr = clean.substring(clean.length - 4);
          return int.parse(yearStr);
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
  
  String getFormattedDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}";
  }

  bool _hasZeroQtyData() {
    return filteredData.any((item) => (item['qty'] ?? 0) == 0);
  }

  void _exportToCSV() {
    if (allData.isEmpty) {
      Utils.showErrorSnackbar(context, "Tidak ada data untuk di export");
      return;
    }
    
    String csvContent = "No,Code,Lokasi,Weekly,Qty,Noted,Date Time\n";
    for (int i = 0; i < allData.length; i++) {
      var item = allData[i];
      csvContent += "${i + 1},\"${item['code'] ?? ''}\",\"${item['lokasi'] ?? ''}\",\"${item['weekly'] ?? ''}\",${item['qty'] ?? 0},\"${item['noted'] ?? ''}\",\"${item['date_time'] ?? ''}\"\n";
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.download, color: Colors.green), SizedBox(width: 8), Text("Export CSV")]),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(8), color: Colors.green.shade50, child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text("${allData.length} baris data siap di-copy")])),
              const SizedBox(height: 12),
              const Text("Copy teks CSV di bawah ini, lalu paste ke Excel:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(height: 300, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(8.0), child: SelectableText(csvContent, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')))))),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(8), color: Colors.blue.shade50, child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text("Tips: Select All (Ctrl+A) lalu Copy (Ctrl+C), paste ke Excel", style: TextStyle(fontSize: 11)))])),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  void _exportHistoryToCSV() {
    if (allHistory.isEmpty) {
      Utils.showErrorSnackbar(context, "Tidak ada riwayat untuk di export");
      return;
    }
    
    String csvContent = "No,Code,Qty,From Location,To Location,Note,Taken At,Restored At,Status\n";
    for (int i = 0; i < allHistory.length; i++) {
      var item = allHistory[i];
      csvContent += "${i + 1},\"${item['code'] ?? ''}\",${item['qty'] ?? 0},\"${item['from_location'] ?? ''}\",\"${item['to_location'] ?? ''}\",\"${item['note'] ?? ''}\",\"${item['taken_at'] ?? ''}\",\"${item['restored_at'] ?? ''}\",\"${item['status'] ?? ''}\"\n";
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.download, color: Colors.green), SizedBox(width: 8), Text("Export Riwayat CSV")]),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(8), color: Colors.green.shade50, child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text("${allHistory.length} baris riwayat siap di-copy")])),
              const SizedBox(height: 12),
              const Text("Copy teks CSV di bawah ini, lalu paste ke Excel:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(height: 300, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(8.0), child: SelectableText(csvContent, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')))))),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(8), color: Colors.blue.shade50, child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text("Tips: Select All (Ctrl+A) lalu Copy (Ctrl+C), paste ke Excel", style: TextStyle(fontSize: 11)))])),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(showHistory ? "RIWAYAT TRANSAKSI" : "DATA NON GWS"),
        backgroundColor: showHistory ? Colors.purple : Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          if (!showHistory) ...[
            if (_hasZeroQtyData())
              IconButton(
                icon: const Icon(Icons.cleaning_services), 
                onPressed: _cleanAllZeroQty, 
                tooltip: "Bersihkan semua data QTY 0 di halaman ini",
              ),
            IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog, tooltip: "Tambah Data"),
            IconButton(icon: const Icon(Icons.download), onPressed: _exportToCSV, tooltip: "Export CSV"),
            IconButton(icon: const Icon(Icons.history), onPressed: () {
              setState(() { showHistory = true; _loadHistory(); });
            }, tooltip: "Lihat Riwayat"),
          ],
          if (showHistory) ...[
            IconButton(icon: const Icon(Icons.download), onPressed: _exportHistoryToCSV, tooltip: "Export Riwayat CSV"),
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () {
              setState(() { showHistory = false; });
            }, tooltip: "Kembali ke Data"),
          ],
        ],
        bottom: !showHistory ? PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari Code atau Lokasi...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchController.clear();
                        setState(() { searchQuery = ""; hasSearched = false; });
                      })
                    : null,
              ),
              onChanged: (value) { setState(() { searchQuery = value.toLowerCase().trim(); hasSearched = value.isNotEmpty; }); },
            ),
          ),
        ) : null,
      ),
      body: showHistory ? _buildHistoryBody() : _buildBody(),
    );
  }

  Widget _buildHistoryBody() {
    if (isLoadingHistory) return const Center(child: CircularProgressIndicator());
    if (allHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Belum ada riwayat transaksi"),
            SizedBox(height: 8),
            Text("Ambil barang untuk memulai riwayat", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        Container(
          color: Colors.purple.shade50,
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("RIWAYAT PENGAMBILAN BARANG", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${allHistory.length} transaksi", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
            ],
          ),
        ),
        Container(
          color: Colors.purple.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              _buildHeaderCell("No", flex: 1),
              _buildHeaderCell("CODE", flex: 2),
              _buildHeaderCell("QTY", flex: 1),
              _buildHeaderCell("DARI", flex: 2),
              _buildHeaderCell("TUJUAN", flex: 2),
              _buildHeaderCell("STATUS", flex: 1),
              _buildHeaderCell("AKSI", flex: 2),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: allHistory.length,
            itemBuilder: (context, index) {
              final item = allHistory[index];
              final bool isRestored = (item['status'] ?? '') == 'RESTORED';
              final bool isEven = index % 2 == 0;
              
              return Container(
                color: isEven ? Colors.grey.shade50 : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(
                  children: [
                    _buildCell("${index + 1}", flex: 1),
                    _buildCell((item['code'] ?? '-').toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                    _buildCell("${item['qty'] ?? 0}", flex: 1, fontWeight: FontWeight.bold, color: Colors.red),
                    _buildCell((item['from_location'] ?? '-').toString().toUpperCase(), flex: 2, fontSize: 11),
                    _buildCell((item['to_location'] ?? '-').toString().toUpperCase(), flex: 2, fontSize: 11),
                    _buildCell(isRestored ? "RESTORED" : "ACTIVE", flex: 1, fontWeight: FontWeight.bold, color: isRestored ? Colors.green : Colors.orange),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isRestored)
                          IconButton(icon: const Icon(Icons.restore, color: Colors.green, size: 20), onPressed: () => _showRestoreDialog(item), tooltip: "Restore"),
                        IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red, size: 20), onPressed: () => _showPermanentDeleteDialog(item), tooltip: "Hapus Permanen"),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));
    if (allData.isEmpty) return const Center(child: Text("Tidak ada data"));

    var summary = getSummaryByYear();
    int totalAll = summary.values.fold(0, (sum, qty) => sum + qty);
    String lastUpdate = getFormattedDate();

    if (!hasSearched) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(children: [Icon(Icons.summarize, color: Colors.orange, size: 28), SizedBox(width: 10), Text("RINGKASAN DATA NON GWS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
                      const Divider(height: 24),
                      Text("📅 Update Terakhir: $lastUpdate", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: summary.entries.map((entry) {
                          int year = entry.key;
                          int qty = entry.value;
                          if (year == 0) return const SizedBox.shrink();
                          List<Map<String, dynamic>> yearData = allData.where((item) {
                            return _extractYearFromWeekly(item['weekly'] ?? '') == year;
                          }).toList();
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DetailByYearPage(year: year, data: yearData, totalQty: qty)));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: year == 2025 ? Colors.blue.shade50 : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: year == 2025 ? Colors.blue.shade200 : Colors.green.shade200),
                              ),
                              child: Column(
                                children: [
                                  Text("TAHUN $year", style: TextStyle(fontWeight: FontWeight.bold, color: year == 2025 ? Colors.blue.shade700 : Colors.green.shade700)),
                                  const SizedBox(height: 4),
                                  Text("$qty PCS", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: year == 2025 ? Colors.blue.shade900 : Colors.green.shade900)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [const Text("TOTAL SEMUA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("$totalAll PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red))],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => hasSearched = true),
                          icon: const Icon(Icons.search),
                          label: const Text("MULAI PENCARIAN"),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Row(children: [Icon(Icons.lightbulb, color: Colors.orange), SizedBox(width: 8), Text("Tips Pencarian", style: TextStyle(fontWeight: FontWeight.bold))]),
                      const SizedBox(height: 8),
                      const Text("• Ketik kode barang (contoh: C45830)"),
                      const Text("• Ketik lokasi (contoh: NK01-2U-10)"),
                      const Divider(),
                      const Text("📋 Fitur:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const Text("• Ambil barang - pindahkan ke lokasi lain"),
                      const Text("• Input cepat - dengan konsep PALLET, FULL, ODD"),
                      const Text("• Riwayat transaksi - lihat semua pengambilan"),
                      const Text("• Restore - kembalikan barang"),
                      const Text("• Hapus Permanen - hapus data riwayat"),
                      const Text("• Hapus QTY 0 - hapus data stok habis di halaman ini"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Tidak ditemukan"),
            const SizedBox(height: 16),
            TextButton.icon(onPressed: () { _searchController.clear(); setState(() { searchQuery = ""; hasSearched = false; }); }, icon: const Icon(Icons.arrow_back), label: const Text("Kembali ke Ringkasan")),
          ],
        ),
      );
    }

    return Column(
      children: [
        Container(
          color: Colors.orange.shade50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("🔍 Hasil: \"${_searchController.text}\""),
              Text("${filteredData.length} baris"),
            ],
          ),
        ),
        Container(
          color: Colors.orange.shade700,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              _buildHeaderCell("No", flex: 1),
              _buildHeaderCell("CODE", flex: 2),
              _buildHeaderCell("LOKASI", flex: 2),
              _buildHeaderCell("WEEKLY", flex: 2),
              _buildHeaderCell("QTY", flex: 1),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final item = filteredData[index];
              final int qty = item['qty'] ?? 0;
              final bool isZeroQty = qty == 0;
              
              return GestureDetector(
                onTap: () {
                  if (isZeroQty) {
                    _showDeleteZeroQtyDialog(context, item, item['uniq_id']);
                  } else {
                    _showAmbilDialog(context, item, item['uniq_id']);
                  }
                },
                child: Container(
                  color: isZeroQty 
                      ? Colors.red.shade50 
                      : (index % 2 == 0 ? Colors.grey.shade50 : Colors.white),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(
                    children: [
                      _buildCell("${index + 1}", flex: 1),
                      _buildCell((item['code'] ?? "-").toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                      _buildCell((item['lokasi'] ?? "-").toString().toUpperCase(), flex: 2),
                      _buildCell(item['weekly'] ?? "-", flex: 2),
                      _buildCell("$qty", flex: 1, fontWeight: FontWeight.bold, color: isZeroQty ? Colors.red : Colors.black87),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          color: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("TOTAL QTY: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("$totalQty Pcs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(String text, {int flex = 1, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black87, double fontSize = 13}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showAddDialog() {
    TextEditingController codeController = TextEditingController();
    TextEditingController palletController = TextEditingController();
    TextEditingController fullQtyController = TextEditingController();
    TextEditingController oddQtyController = TextEditingController();
    TextEditingController lokasiController = TextEditingController();
    TextEditingController weeklyController = TextEditingController();

    int pallet = 0, fullQty = 0, oddQty = 0, totalQtyPreview = 0, totalBarisPreview = 0;
    List<String> suggestionCodes = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            void updatePreview() {
              pallet = int.tryParse(palletController.text) ?? 0;
              fullQty = int.tryParse(fullQtyController.text) ?? 0;
              oddQty = int.tryParse(oddQtyController.text) ?? 0;
              totalBarisPreview = pallet;
              if (oddQty > 0) totalBarisPreview++;
              totalQtyPreview = (pallet * fullQty) + oddQty;
              setStateDialog(() {});
            }

            void updateSuggestions(String input) {
              if (input.isEmpty) {
                suggestionCodes = [];
              } else {
                suggestionCodes = codeList
                    .where((code) => code.toLowerCase().contains(input.toLowerCase()))
                    .take(10)
                    .toList();
              }
              setStateDialog(() {});
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(children: [Icon(Icons.inventory, color: Colors.orange, size: 28), const SizedBox(width: 10), const Text("Tambah Data Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                      const Divider(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("CODE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                controller: codeController,
                                decoration: InputDecoration(
                                  hintText: "Ketik Code... (bisa baru atau pilih dari saran)",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  prefixIcon: const Icon(Icons.qr_code, size: 20, color: Colors.grey),
                                  suffixIcon: codeController.text.isNotEmpty
                                      ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { codeController.clear(); updateSuggestions(''); })
                                      : null,
                                ),
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                textCapitalization: TextCapitalization.characters,
                                onChanged: (value) => updateSuggestions(value),
                              ),
                              if (suggestionCodes.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                                  child: Column(
                                    children: suggestionCodes.map((suggestion) {
                                      return InkWell(
                                        onTap: () { codeController.text = suggestion; updateSuggestions(''); },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
                                          child: Row(children: [const Icon(Icons.history, size: 16, color: Colors.grey), const SizedBox(width: 8), Expanded(child: Text(suggestion, style: const TextStyle(fontSize: 13)))]),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text("💡 Tips: Ketik untuk mencari code yang sudah ada, atau ketik code baru", style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                        child: Column(
                          children: [
                            const Text("INPUT MULTI BARIS", style: TextStyle(fontWeight: FontWeight.bold)),
                            const Text("(Membuat banyak baris sekaligus)", style: TextStyle(fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("PALLET", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: palletController,
                                        decoration: InputDecoration(hintText: "Jumlah", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => updatePreview(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("QTY FULL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: fullQtyController,
                                        decoration: InputDecoration(hintText: "Per Pallet", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => updatePreview(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text("ODD", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                      const SizedBox(height: 4),
                                      TextFormField(
                                        controller: oddQtyController,
                                        decoration: InputDecoration(hintText: "Sisa", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
                                        keyboardType: TextInputType.number,
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => updatePreview(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                        child: Column(
                          children: [
                            const Row(children: [Icon(Icons.preview, size: 16, color: Colors.green), SizedBox(width: 8), Text("PREVIEW", style: TextStyle(fontWeight: FontWeight.bold))]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(children: [Text("$totalBarisPreview", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)), const Text("Baris", style: TextStyle(fontSize: 10))]),
                                Container(width: 1, height: 30, color: Colors.grey.shade300),
                                Column(children: [Text("$totalQtyPreview", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)), const Text("Total Qty", style: TextStyle(fontSize: 10))]),
                                Container(width: 1, height: 30, color: Colors.grey.shade300),
                                Column(children: [Text("$pallet", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)), const Text("Pallet", style: TextStyle(fontSize: 10))]),
                                if (oddQty > 0) ...[
                                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                                  Column(children: [Text("$oddQty", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)), const Text("Odd", style: TextStyle(fontSize: 10))]),
                                ],
                              ],
                            ),
                            if (totalBarisPreview > 0 && totalBarisPreview <= 50)
                              const SizedBox(height: 6),
                            if (totalBarisPreview > 0 && totalBarisPreview <= 50)
                              Text("📋 $totalBarisPreview baris: ${fullQty > 0 ? '$fullQty Pcs' : ''}${fullQty > 0 && pallet > 0 ? ' x $pallet pallet' : ''}${fullQty > 0 && oddQty > 0 ? ' + ' : ''}${oddQty > 0 ? '$oddQty Pcs' : ''}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            if (totalBarisPreview > 50)
                              const Text("⚠️ Maksimal 50 baris!", style: TextStyle(fontSize: 11, color: Colors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("LOKASI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: lokasiController,
                            decoration: InputDecoration(hintText: "Contoh: DO PREPARE, 1A-31", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("WEEKLY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: weeklyController,
                            decoration: InputDecoration(hintText: "Contoh: 1526", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.grey.shade100),
                              child: const Text("BATAL", style: TextStyle(fontSize: 14, color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                String code = codeController.text.trim().toUpperCase();
                                pallet = int.tryParse(palletController.text) ?? 0;
                                fullQty = int.tryParse(fullQtyController.text) ?? 0;
                                oddQty = int.tryParse(oddQtyController.text) ?? 0;
                                String lokasi = lokasiController.text.trim().toUpperCase();
                                String weekly = weeklyController.text.trim();
                                
                                if (code.isEmpty) { Utils.showErrorSnackbar(context, "⚠️ CODE harus diisi"); return; }
                                if (pallet <= 0 && oddQty <= 0) { Utils.showErrorSnackbar(context, "⚠️ PALLET atau ODD harus diisi (minimal 1)"); return; }
                                if (fullQty <= 0 && pallet > 0) { Utils.showErrorSnackbar(context, "⚠️ QTY FULL harus diisi jika PALLET lebih dari 0"); return; }
                                if (lokasi.isEmpty) { Utils.showErrorSnackbar(context, "⚠️ LOKASI harus diisi"); return; }
                                
                                int totalBaris = pallet;
                                if (oddQty > 0) totalBaris++;
                                if (totalBaris > 50) { Utils.showErrorSnackbar(context, "⚠️ Maksimal 50 baris dalam satu kali input"); return; }
                                
                                showDialog(context: context, barrierDismissible: false, builder: (context) => const AlertDialog(content: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 16), Text("Menyimpan data...")])));
                                
                                try {
                                  List<Map<String, dynamic>> itemsToInsert = [];
                                  String baseUniqId = 'UID-${DateTime.now().millisecondsSinceEpoch}';
                                  String currentDateTime = DateTime.now().toIso8601String();
                                  
                                  for (int i = 0; i < pallet; i++) {
                                    itemsToInsert.add({"code": code, "qty": fullQty, "lokasi": lokasi, "weekly": weekly, "noted": "Pallet ${i + 1} dari $pallet", "date_time": currentDateTime, "uniq_id": '${baseUniqId}_P${i + 1}'});
                                  }
                                  if (oddQty > 0) {
                                    itemsToInsert.add({"code": code, "qty": oddQty, "lokasi": lokasi, "weekly": weekly, "noted": "ODD (sisa)", "date_time": currentDateTime, "uniq_id": '${baseUniqId}_ODD'});
                                  }
                                  
                                  await Supabase.instance.client.from('inventory_non_gws').insert(itemsToInsert);
                                  Navigator.pop(context); Navigator.pop(context);
                                  Utils.showSuccessSnackbar(context, "✅ Berhasil menyimpan ${itemsToInsert.length} baris data\nTotal Qty: ${(pallet * fullQty) + oddQty} Pcs\nCode: $code");
                                  _loadInitialData();
                                } catch (e) { Navigator.pop(context); Utils.showErrorSnackbar(context, "❌ Gagal menyimpan: ${e.toString().substring(0, e.toString().length > 100 ? 100 : e.toString().length)}"); }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              child: const Text("SIMPAN", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteZeroQtyDialog(BuildContext context, Map<String, dynamic> item, String uniqId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text("Hapus Data?", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Data ini memiliki QTY = 0", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📦 Code: ${(item['code'] ?? '').toString().toUpperCase()}"),
                  Text("📍 Lokasi: ${item['lokasi'] ?? ''}"),
                  Text("📅 Weekly: ${item['weekly'] ?? ''}"),
                  Text("🔢 Qty: 0 Pcs"),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text("Apakah Anda yakin ingin menghapus data ini?", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
              try {
                await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', uniqId);
                if (mounted) {
                  Navigator.pop(context);
                  Utils.showSuccessSnackbar(context, "✅ Data dengan QTY 0 berhasil dihapus");
                  _loadInitialData();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  Utils.showErrorSnackbar(context, "❌ Gagal menghapus: $e");
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanAllZeroQty() async {
    List<Map<String, dynamic>> zeroQtyData = filteredData.where((item) => (item['qty'] ?? 0) == 0).toList();
    
    if (zeroQtyData.isEmpty) {
      Utils.showErrorSnackbar(context, "Tidak ada data dengan QTY 0 pada hasil pencarian ini");
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cleaning_services, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text("Bersihkan Data QTY 0", style: TextStyle(color: Colors.red)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ditemukan ${zeroQtyData.length} data dengan QTY = 0 pada halaman ini", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: zeroQtyData.take(10).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text("• ${item['code']} - ${item['lokasi']} (${item['weekly']})"),
                  );
                }).toList(),
              ),
            ),
            if (zeroQtyData.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text("... dan ${zeroQtyData.length - 10} data lainnya", 
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "⚠️ PERINGATAN: Data akan dihapus dari database!",
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ),
            const SizedBox(height: 12),
            Text("Apakah Anda yakin ingin menghapus ${zeroQtyData.length} data ini?", 
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Hapus ${zeroQtyData.length} data"),
          ),
        ],
      ),
    );
    
    if (confirm != true) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      int deletedCount = 0;
      for (var item in zeroQtyData) {
        await Supabase.instance.client
            .from('inventory_non_gws')
            .delete()
            .eq('uniq_id', item['uniq_id']);
        deletedCount++;
      }
      
      if (mounted) {
        Navigator.pop(context);
        Utils.showSuccessSnackbar(context, 
            "✅ Berhasil menghapus $deletedCount data dengan QTY 0\n"
            "Dari halaman: ${searchQuery.isEmpty ? 'Semua data' : searchQuery}");
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        Utils.showErrorSnackbar(context, "❌ Gagal menghapus: $e");
      }
    }
  }

  void _showAmbilDialog(BuildContext context, Map<String, dynamic> item, String uniqId) {
    int maxQty = (item['qty'] ?? 0) as int;
    String currentLokasi = (item['lokasi'] ?? '').toString().toUpperCase();
    TextEditingController qtyController = TextEditingController(text: maxQty.toString());
    String destination = 'OUT LINE TO PREPARE';
    bool isAll = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Icon(Icons.inventory_2, color: Colors.orange.shade700, size: 28), const SizedBox(width: 10), Expanded(child: Text("AMBIL BARANG: ${(item['code'] ?? '').toString().toUpperCase()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
                  const Divider(height: 24),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Stok Saat Ini:", style: TextStyle(fontWeight: FontWeight.bold)), Text("$maxQty Pcs", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue))]),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Lokasi:", style: TextStyle(fontWeight: FontWeight.bold)), Text(currentLokasi, style: const TextStyle(fontWeight: FontWeight.w500))]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  const Text("JUMLAH YANG DIAMBIL:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: TextFormField(controller: qtyController, decoration: InputDecoration(hintText: "Jumlah", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, suffixText: "Pcs"), keyboardType: TextInputType.number, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), enabled: !isAll, onChanged: (value) { int val = int.tryParse(value) ?? 0; if (val > maxQty) qtyController.text = maxQty.toString(); setStateDialog(() {}); })),
                    const SizedBox(width: 12),
                    FilterChip(label: const Text("ALL"), selected: isAll, onSelected: (selected) { setStateDialog(() { isAll = selected; if (isAll) qtyController.text = maxQty.toString(); }); }, backgroundColor: Colors.grey.shade200, selectedColor: Colors.red.shade100, checkmarkColor: Colors.red),
                  ]),
                  const SizedBox(height: 20),
                  const Text("PILIHAN TUJUAN:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                    child: Column(children: [
                      RadioListTile<String>(title: const Text("OUT LINE TO PREPARE", style: TextStyle(fontWeight: FontWeight.w500)), value: "OUT LINE TO PREPARE", groupValue: destination, onChanged: (value) { setStateDialog(() { destination = value!; }); }, activeColor: Colors.orange),
                      RadioListTile<String>(title: const Text("OUT LINE TO REQUEST", style: TextStyle(fontWeight: FontWeight.w500)), value: "OUT LINE TO REQUEST", groupValue: destination, onChanged: (value) { setStateDialog(() { destination = value!; }); }, activeColor: Colors.green),
                    ]),
                  ),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: Colors.grey.shade100), child: const Text("BATAL", style: TextStyle(fontSize: 16, color: Colors.grey)))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: () async {
                      int takeQty = int.tryParse(qtyController.text) ?? 0;
                      if (takeQty <= 0) { Utils.showErrorSnackbar(context, "Jumlah yang diambil harus lebih dari 0"); return; }
                      if (takeQty > maxQty) { Utils.showErrorSnackbar(context, "Jumlah yang diambil melebihi stok"); return; }
                      int newQty = maxQty - takeQty;
                      showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
                      try {
                        await Supabase.instance.client.from('inventory_non_gws').update({'qty': newQty}).eq('uniq_id', uniqId);
                        String newUniqId = 'UID-${DateTime.now().millisecondsSinceEpoch}';
                        await Supabase.instance.client.from('inventory_non_gws').insert({"code": item['code'], "qty": takeQty, "lokasi": destination, "weekly": item['weekly'] ?? '', "noted": "Diambil dari $currentLokasi pada ${DateTime.now().toString().split('.')[0]}", "date_time": DateTime.now().toString(), "uniq_id": newUniqId});
                        await Supabase.instance.client.from('take_history').insert({"code": item['code'], "qty": takeQty, "from_location": currentLokasi, "to_location": destination, "note": "Pengambilan barang", "taken_at": DateTime.now().toIso8601String(), "status": "ACTIVE", "original_uniq_id": uniqId, "new_uniq_id": newUniqId});
                        if (mounted) {
                          Navigator.pop(context); Navigator.pop(context);
                          Utils.showSuccessSnackbar(context, "✅ Berhasil mengambil $takeQty Pcs\nSisa: $newQty Pcs di $currentLokasi\nBerpindah ke: $destination");
                          _loadInitialData(); _loadHistory();
                        }
                      } catch (e) { if (mounted) { Navigator.pop(context); Utils.showErrorSnackbar(context, "Gagal mengambil barang: $e"); } }
                    }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("AMBIL", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                  ]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showRestoreDialog(Map<String, dynamic> historyItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kembalikan Barang?"),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Kode: ${(historyItem['code'] ?? '').toString().toUpperCase()}"),
          Text("Jumlah: ${historyItem['qty']} Pcs"),
          Text("Dari: ${historyItem['to_location']}"),
          Text("Kembalikan ke: ${historyItem['from_location']}"),
          const SizedBox(height: 16),
          const Text("Apakah Anda yakin ingin mengembalikan barang ini?", style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.green), child: const Text("Kembalikan")),
        ],
      ),
    );
    if (confirm != true) return;
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      String originalUniqId = historyItem['original_uniq_id'];
      String newUniqId = historyItem['new_uniq_id'];
      int qty = historyItem['qty'] as int;
      String fromLocation = historyItem['from_location'];
      final originalResponse = await Supabase.instance.client.from('inventory_non_gws').select().eq('uniq_id', originalUniqId).maybeSingle();
      if (originalResponse != null) {
        int currentQty = originalResponse['qty'] ?? 0;
        await Supabase.instance.client.from('inventory_non_gws').update({'qty': currentQty + qty}).eq('uniq_id', originalUniqId);
      } else {
        await Supabase.instance.client.from('inventory_non_gws').insert({"code": historyItem['code'], "qty": qty, "lokasi": fromLocation, "weekly": "", "noted": "Dikembalikan dari ${historyItem['to_location']} pada ${DateTime.now().toString().split('.')[0]}", "date_time": DateTime.now().toString(), "uniq_id": 'RESTORE-${DateTime.now().millisecondsSinceEpoch}'});
      }
      await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', newUniqId);
      await Supabase.instance.client.from('take_history').update({'status': 'RESTORED', 'restored_at': DateTime.now().toIso8601String()}).eq('id', historyItem['id']);
      if (mounted) {
        Navigator.pop(context);
        Utils.showSuccessSnackbar(context, "✅ Berhasil mengembalikan $qty Pcs ke $fromLocation");
        _loadInitialData(); _loadHistory();
      }
    } catch (e) { if (mounted) { Navigator.pop(context); Utils.showErrorSnackbar(context, "Gagal mengembalikan barang: $e"); } }
  }

  void _showPermanentDeleteDialog(Map<String, dynamic> historyItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.warning, color: Colors.red, size: 28), SizedBox(width: 8), Text("Hapus Permanen", style: TextStyle(color: Colors.red))]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Anda akan menghapus transaksi ini secara permanen:", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("📦 Kode: ${(historyItem['code'] ?? '').toString().toUpperCase()}"), 
              Text("🔢 Jumlah: ${historyItem['qty']} Pcs"),
              Text("📍 Dari: ${historyItem['from_location']}"), 
              Text("🎯 Tujuan: ${historyItem['to_location']}"),
              const Divider(),
              const Text("⚠️ PERINGATAN:", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              const Text("• Data stock di lokasi tujuan akan DIHAPUS"), 
              const Text("• Data stock di lokasi asal TIDAK berubah"),
              const Text("• Riwayat ini akan DIHAPUS"), 
              const Text("• TINDAKAN INI TIDAK DAPAT DIURKAN!"),
            ]),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Hapus Permanen")),
        ],
      ),
    );
    if (confirm != true) return;
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      String newUniqId = historyItem['new_uniq_id'];
      int historyId = historyItem['id'];
      if (newUniqId != null && newUniqId.isNotEmpty) { await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', newUniqId); }
      await Supabase.instance.client.from('take_history').delete().eq('id', historyId);
      if (mounted) {
        Navigator.pop(context);
        Utils.showSuccessSnackbar(context, "✅ Berhasil menghapus permanen transaksi\n${historyItem['code']} - ${historyItem['qty']} Pcs");
        _loadInitialData(); _loadHistory();
      }
    } catch (e) { if (mounted) { Navigator.pop(context); Utils.showErrorSnackbar(context, "Gagal menghapus: $e"); } }
  }
}

// ==============================================
// CEK BY CODE PAGE (DENGAN UNIQUE ID FIX)
// ==============================================
class CekByCodePage extends StatefulWidget {
  const CekByCodePage({super.key});

  @override
  State<CekByCodePage> createState() => _CekByCodePageState();
}

class _CekByCodePageState extends State<CekByCodePage> {
  String searchCode = "";
  final TextEditingController _codeController = TextEditingController();
  
  List<Map<String, dynamic>> allDataGws = [];
  List<Map<String, dynamic>> allDataNonGws = [];
  bool isLoading = true;
  String? errorMessage;
  
  Set<String> checkedItems = {};
  Map<String, String> notes = {};
  String sortBy = "default";

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadCheckedItems();
    _loadNotes();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadCheckedItems() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_status').select();
      for (var item in response) { 
        checkedItems.add(item['id'].toString()); 
      }
      setState(() {});
    } catch (e) {
      print("Error load checked items: $e");
    }
  }

  Future<void> _loadNotes() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_notes').select();
      for (var item in response) { 
        notes[item['id'].toString()] = item['note'].toString(); 
      }
      setState(() {});
    } catch (e) {
      print("Error load notes: $e");
    }
  }

  Future<void> _saveCheckedStatus(String itemId, bool isChecked) async {
    try {
      if (isChecked) { 
        await Supabase.instance.client.from('cek_oke_status').upsert({'id': itemId, 'status': 'OKE'}); 
        checkedItems.add(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_status').delete().eq('id', itemId); 
        checkedItems.remove(itemId); 
      }
      setState(() {});
    } catch (e) { 
      print("Error save checked status: $e");
      Utils.showErrorSnackbar(context, "Gagal menyimpan status");
    }
  }

  Future<void> _saveNote(String itemId, String note) async {
    try {
      if (note.isEmpty) { 
        await Supabase.instance.client.from('cek_oke_notes').delete().eq('id', itemId); 
        notes.remove(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_notes').upsert({'id': itemId, 'note': note}); 
        notes[itemId] = note; 
      }
      setState(() {});
    } catch (e) { 
      print("Error save note: $e");
      Utils.showErrorSnackbar(context, "Gagal menyimpan catatan");
    }
  }

  Future<void> _refreshCheckedItems() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Status"),
        content: const Text("Apakah Anda yakin ingin mereset semua status CEK OKE dan catatan?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Reset")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { isLoading = true; });

    try {
      await Supabase.instance.client.from('cek_oke_status').delete().neq('id', '0');
      await Supabase.instance.client.from('cek_oke_notes').delete().neq('id', '0');
      checkedItems.clear();
      notes.clear();
      if (mounted) {
        Utils.showSuccessSnackbar(context, "Semua status dan catatan berhasil direset");
        setState(() {});
      }
    } catch (e) {
      if (mounted) Utils.showErrorSnackbar(context, "Gagal mereset: $e");
    } finally {
      if (mounted) setState(() { isLoading = false; });
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() { isLoading = true; errorMessage = null; });
      
      List<Map<String, dynamic>> allGws = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      while (hasMore) {
        final response = await Supabase.instance.client.from('inventory_gws').select().range(start, start + batchSize - 1);
        allGws.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) hasMore = false; else start += batchSize;
      }
      
      List<Map<String, dynamic>> allNonGws = [];
      start = 0;
      hasMore = true;
      while (hasMore) {
        final response = await Supabase.instance.client.from('inventory_non_gws').select().range(start, start + batchSize - 1);
        allNonGws.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) hasMore = false; else start += batchSize;
      }
      
      setState(() { allDataGws = allGws; allDataNonGws = allNonGws; isLoading = false; });
    } catch (e) { 
      setState(() { errorMessage = e.toString(); isLoading = false; });
      Utils.showErrorSnackbar(context, "Gagal memuat data: $e");
    }
  }

  List<Map<String, dynamic>> get filteredData {
    if (searchCode.isEmpty) return [];
    List<Map<String, dynamic>> results = [];
    String query = searchCode.toUpperCase().trim();
    
    int gwsCounter = 0;
    int nonGwsCounter = 0;
    
    for (var item in allDataGws) {
      String code = (item['code'] ?? '').toString().toUpperCase();
      if (code.contains(query)) {
        results.add({ 
          ...item, 
          'ticket_bc': item['ticket_bc'] ?? '-', 
          'lokasi': item['lokasi'] ?? '-', 
          'weekly': item['weekly'] ?? '-', 
          'qty': item['qty'] ?? 0, 
          'id': 'gws_${item['id']}_${gwsCounter++}_${item['code']}',
          'isGws': true 
        });
      }
    }
    
    for (var item in allDataNonGws) {
      String code = (item['code'] ?? '').toString().toUpperCase();
      if (code.contains(query)) {
        results.add({ 
          ...item, 
          'ticket_bc': 'NON GWS', 
          'lokasi': item['lokasi'] ?? '-', 
          'weekly': item['weekly'] ?? '-', 
          'qty': item['qty'] ?? 0, 
          'id': 'ngws_${item['uniq_id']}_${nonGwsCounter++}',
          'isGws': false 
        });
      }
    }
    
    if (sortBy == 'weekly_asc') {
      results.sort((a, b) { String w1 = a['weekly']?.toString() ?? ''; String w2 = b['weekly']?.toString() ?? ''; return w1.compareTo(w2); });
    } else if (sortBy == 'weekly_desc') {
      results.sort((a, b) { String w1 = a['weekly']?.toString() ?? ''; String w2 = b['weekly']?.toString() ?? ''; return w2.compareTo(w1); });
    }
    return results;
  }

  Map<String, dynamic> getSummary() {
    int totalGws = 0, totalNonGws = 0;
    Map<String, int> weeklyGws = {}, weeklyNonGws = {};
    for (var item in filteredData) {
      int qty = item['qty'] ?? 0;
      String weekly = item['weekly']?.toString() ?? '-';
      bool isGws = item['isGws'] == true;
      if (isGws) { totalGws += qty; weeklyGws[weekly] = (weeklyGws[weekly] ?? 0) + qty; }
      else { totalNonGws += qty; weeklyNonGws[weekly] = (weeklyNonGws[weekly] ?? 0) + qty; }
    }
    return { 'totalGws': totalGws, 'totalNonGws': totalNonGws, 'totalAll': totalGws + totalNonGws, 'weeklyGws': weeklyGws, 'weeklyNonGws': weeklyNonGws };
  }

  Future<int> getStockFromMaster(String code) async {
    if (code.isEmpty) return 0;
    try {
      final response = await Supabase.instance.client.from('stock_master').select('stock').eq('code', code.toUpperCase()).maybeSingle();
      return response != null ? (response['stock'] ?? 0) : 0;
    } catch (e) { return 0; }
  }

  Future<Map<String, dynamic>> _getSummaryWithStock() async {
    var summary = getSummary();
    int stock = await getStockFromMaster(searchCode);
    summary['stock'] = stock;
    summary['balance'] = stock - (summary['totalAll'] as int);
    return summary;
  }

  void _exportToCSV() {
    if (filteredData.isEmpty) { Utils.showErrorSnackbar(context, "Tidak ada data untuk di export"); return; }
    String csvContent = "No,TICKET BC,Code,Lokasi,Weekly,QTY,Status,Note\n";
    for (int i = 0; i < filteredData.length; i++) {
      var item = filteredData[i];
      String status = checkedItems.contains(item['id']) ? "OKE CEK" : "";
      String note = notes[item['id']] ?? "";
      csvContent += "${i + 1},\"${item['ticket_bc'] ?? ''}\",\"${(item['code'] ?? '').toString().toUpperCase()}\",\"${item['lokasi'] ?? ''}\",\"${item['weekly'] ?? ''}\",${item['qty'] ?? 0},\"$status\",\"$note\"\n";
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [Icon(Icons.download, color: Colors.green), SizedBox(width: 8), Text("Export CSV")]),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(padding: const EdgeInsets.all(8), color: Colors.green.shade50, child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 20), const SizedBox(width: 8), Text("${filteredData.length} baris data siap di-copy")])),
              const SizedBox(height: 12),
              const Text("Copy teks CSV di bawah ini, lalu paste ke Excel:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(height: 300, decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)), child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(8.0), child: SelectableText(csvContent, style: const TextStyle(fontSize: 10, fontFamily: 'monospace')))))),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(8), color: Colors.blue.shade50, child: const Row(children: [Icon(Icons.info_outline, size: 16, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text("Tips: Select All (Ctrl+A) lalu Copy (Ctrl+C), paste ke Excel", style: TextStyle(fontSize: 11)))])),
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Tutup"))],
      ),
    );
  }

  Widget _buildCompareCard(String label, int value, Color color) {
    String displayValue = value.toString();
    if (label == "BALANCE") {
      if (value > 0) displayValue = "-$value";
      else if (value < 0) displayValue = "+${value.abs()}";
      else displayValue = "0";
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [Text(label, style: TextStyle(fontSize: 12, color: color)), Text(displayValue, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: label == "BALANCE" ? Colors.red : color))]),
    );
  }

  void _showNoteDialog(String itemId, String currentNote) {
    TextEditingController noteController = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan"),
        content: TextField(controller: noteController, decoration: const InputDecoration(hintText: "Ketik catatan untuk baris ini...", border: OutlineInputBorder()), maxLines: 3),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")), ElevatedButton(onPressed: () { _saveNote(itemId, noteController.text); Navigator.pop(context); }, child: const Text("Simpan"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CEK ACTUAL - BY CODE"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort), 
            onSelected: (value) { setState(() { sortBy = value; }); }, 
            itemBuilder: (context) => [
              const PopupMenuItem(value: "default", child: Text("Default")), 
              const PopupMenuItem(value: "weekly_asc", child: Text("Weekly A → Z")), 
              const PopupMenuItem(value: "weekly_desc", child: Text("Weekly Z → A"))
            ]
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshCheckedItems, tooltip: "Reset semua status CEK OKE"),
          IconButton(icon: const Icon(Icons.download), onPressed: _exportToCSV, tooltip: "Export hasil pencarian ke CSV"),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _codeController, 
                  autofocus: true, 
                  decoration: InputDecoration(
                    hintText: "Cari berdasarkan Code... (contoh: 7033, C45830)", 
                    prefixIcon: const Icon(Icons.search), 
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), 
                    filled: true, 
                    fillColor: Colors.white, 
                    suffixIcon: _codeController.text.isNotEmpty 
                        ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _codeController.clear(); setState(() => searchCode = ""); }) 
                        : null
                  ), 
                  onChanged: (value) => setState(() => searchCode = value)
                ),
                const SizedBox(height: 8),
                Text("🔍 Mencari di: GWS (NK01) + NON GWS", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));
    if (searchCode.isEmpty) {
      return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search, size: 64, color: Colors.grey), SizedBox(height: 16), Text("Masukkan kode barang untuk mencari"), SizedBox(height: 8), Text("Contoh: 7033, C45830, 12510", style: TextStyle(fontSize: 12, color: Colors.grey))]));
    }
    if (filteredData.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off, size: 64, color: Colors.grey), const SizedBox(height: 16), Text("Tidak ada data ditemukan untuk \"$searchCode\""), const SizedBox(height: 8), Text("Coba cari dengan kode yang lain", style: TextStyle(fontSize: 12, color: Colors.grey))]));
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _getSummaryWithStock(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        var summary = snapshot.data!;
        int totalGws = summary['totalGws'], totalNonGws = summary['totalNonGws'], totalAll = summary['totalAll'], stock = summary['stock'], balance = summary['balance'];
        var weeklyGws = summary['weeklyGws'] as Map<String, int>;
        var weeklyNonGws = summary['weeklyNonGws'] as Map<String, int>;

        return Column(
          children: [
            Container(
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("🔍 Hasil pencarian code: \"$searchCode\"", style: const TextStyle(fontWeight: FontWeight.bold)), Text("${filteredData.length} baris | Total: $totalAll Pcs", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
                  const SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      childrenPadding: const EdgeInsets.all(12),
                      title: const Row(children: [Icon(Icons.summarize, size: 20, color: Colors.blue), SizedBox(width: 8), Text("LIHAT RINGKASAN", style: TextStyle(fontWeight: FontWeight.bold))]),
                      initiallyExpanded: false,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("COMPARE STOCK", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 8),
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildCompareCard("STOCK", stock, Colors.blue), _buildCompareCard("GWS", totalGws, Colors.orange), _buildCompareCard("NON GWS", totalNonGws, Colors.purple), _buildCompareCard("BALANCE", balance, Colors.red)]),
                            const Divider(height: 24),
                            if (weeklyGws.isNotEmpty) ...[
                              const Text("RINCIAN PER WEEKLY (GWS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, runSpacing: 8, children: weeklyGws.entries.map((entry) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(20)), child: Text("${entry.key}: ${entry.value} Pcs", style: TextStyle(color: Colors.orange.shade700)))).toList()),
                              const SizedBox(height: 16),
                            ],
                            if (weeklyNonGws.isNotEmpty) ...[
                              const Text("RINCIAN PER WEEKLY (NON GWS)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              const SizedBox(height: 8),
                              Wrap(spacing: 8, runSpacing: 8, children: weeklyNonGws.entries.map((entry) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(20)), child: Text("${entry.key}: ${entry.value} Pcs", style: TextStyle(color: Colors.purple.shade700)))).toList()),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final item = filteredData[index];
                  final bool isChecked = checkedItems.contains(item['id']);
                  final bool isGws = item['isGws'] == true;
                  final String currentNote = notes[item['id']] ?? "";
                  final Color textColor = isGws ? Colors.blue.shade700 : Colors.orange.shade700;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: isChecked ? Colors.green.shade50 : null,
                    child: ListTile(
                      leading: Icon(isGws ? Icons.inventory : Icons.warehouse, color: textColor, size: 28),
                      title: Row(children: [Expanded(child: Text((item['code'] ?? '-').toString().toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor))), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)), child: Text("${item['qty'] ?? 0} Pcs", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)))]),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(children: [Icon(Icons.qr_code, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4), Expanded(child: Text(item['ticket_bc'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)))]),
                          const SizedBox(height: 2),
                          Row(children: [Icon(Icons.location_on, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4), Expanded(child: Text(item['lokasi'] ?? '-', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)))]),
                          const SizedBox(height: 2),
                          Row(children: [Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600), const SizedBox(width: 4), Text("Weekly: ${item['weekly'] ?? '-'}", style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(isChecked ? Icons.check_circle : Icons.check_circle_outline, color: isChecked ? Colors.green : Colors.grey, size: 28), onPressed: () { _saveCheckedStatus(item['id'], !isChecked); }),
                          IconButton(icon: Icon(currentNote.isNotEmpty ? Icons.edit_note : Icons.note_add, color: currentNote.isNotEmpty ? Colors.blue : Colors.grey, size: 24), onPressed: () { _showNoteDialog(item['id'], currentNote); }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ==============================================
// CEK BY AREA PAGE (DENGAN UNIQUE ID FIX)
// ==============================================
class CekByAreaPage extends StatefulWidget {
  const CekByAreaPage({super.key});

  @override
  State<CekByAreaPage> createState() => _CekByAreaPageState();
}

class _CekByAreaPageState extends State<CekByAreaPage> {
  List<Map<String, dynamic>> allDataGws = [];
  List<Map<String, dynamic>> allDataNonGws = [];
  bool isLoading = true;
  String? errorMessage;
  bool groupByLocation = true;
  
  Set<String> checkedItems = {};
  Map<String, String> notes = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
    _loadCheckedItems();
    _loadNotes();
  }

  Future<void> _loadCheckedItems() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_status_area').select();
      for (var item in response) { 
        checkedItems.add(item['id'].toString()); 
      }
      setState(() {});
    } catch (e) {
      print("Error load checked items: $e");
    }
  }

  Future<void> _loadNotes() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_notes_area').select();
      for (var item in response) { 
        notes[item['id'].toString()] = item['note'].toString(); 
      }
      setState(() {});
    } catch (e) {
      print("Error load notes: $e");
    }
  }

  Future<void> _saveCheckedStatus(String itemId, bool isChecked) async {
    try {
      if (isChecked) { 
        await Supabase.instance.client.from('cek_oke_status_area').upsert({'id': itemId, 'status': 'OKE'}); 
        checkedItems.add(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_status_area').delete().eq('id', itemId); 
        checkedItems.remove(itemId); 
      }
      setState(() {});
    } catch (e) {
      print("Error save checked status: $e");
      Utils.showErrorSnackbar(context, "Gagal menyimpan status");
    }
  }

  Future<void> _saveNote(String itemId, String note) async {
    try {
      if (note.isEmpty) { 
        await Supabase.instance.client.from('cek_oke_notes_area').delete().eq('id', itemId); 
        notes.remove(itemId); 
      } else { 
        await Supabase.instance.client.from('cek_oke_notes_area').upsert({'id': itemId, 'note': note}); 
        notes[itemId] = note; 
      }
      setState(() {});
    } catch (e) {
      print("Error save note: $e");
      Utils.showErrorSnackbar(context, "Gagal menyimpan catatan");
    }
  }

  Future<void> _refreshCheckedItems() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Status"),
        content: const Text("Apakah Anda yakin ingin mereset semua status CEK OKE dan catatan untuk Area?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Reset")),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { isLoading = true; });

    try {
      await Supabase.instance.client.from('cek_oke_status_area').delete().neq('id', '0');
      await Supabase.instance.client.from('cek_oke_notes_area').delete().neq('id', '0');
      checkedItems.clear();
      notes.clear();
      if (mounted) {
        Utils.showSuccessSnackbar(context, "Semua status dan catatan area berhasil direset");
        setState(() {});
      }
    } catch (e) {
      if (mounted) Utils.showErrorSnackbar(context, "Gagal mereset: $e");
    } finally {
      if (mounted) setState(() { isLoading = false; });
    }
  }

  Future<void> _loadAllData() async {
    try {
      setState(() { isLoading = true; errorMessage = null; });
      
      List<Map<String, dynamic>> allGws = [];
      int start = 0;
      const int batchSize = 1000;
      bool hasMore = true;
      while (hasMore) {
        final response = await Supabase.instance.client.from('inventory_gws').select().range(start, start + batchSize - 1);
        allGws.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) hasMore = false; else start += batchSize;
      }
      
      List<Map<String, dynamic>> allNonGws = [];
      start = 0;
      hasMore = true;
      while (hasMore) {
        final response = await Supabase.instance.client.from('inventory_non_gws').select().range(start, start + batchSize - 1);
        allNonGws.addAll(List<Map<String, dynamic>>.from(response));
        if (response.length < batchSize) hasMore = false; else start += batchSize;
      }
      
      setState(() { allDataGws = allGws; allDataNonGws = allNonGws; isLoading = false; });
    } catch (e) { 
      setState(() { errorMessage = e.toString(); isLoading = false; });
      Utils.showErrorSnackbar(context, "Gagal memuat data: $e");
    }
  }

  String getBlock(String lokasi) {
    if (lokasi.isEmpty) return "Unknown";
    RegExp regExp = RegExp(r'-(\d+[A-Z])-');
    Match? match = regExp.firstMatch(lokasi);
    return match != null ? match.group(1)! : "Unknown";
  }

  Map<String, List<String>> getBlocksWithLines() {
    Map<String, Set<String>> blockLines = {};
    for (var item in allDataGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi.isNotEmpty) { String block = getBlock(lokasi); if (block != "Unknown") blockLines.putIfAbsent(block, () => {}).add(lokasi); }
    }
    for (var item in allDataNonGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi.isNotEmpty) { String block = getBlock(lokasi); if (block != "Unknown") blockLines.putIfAbsent(block, () => {}).add(lokasi); }
    }
    Map<String, List<String>> result = {};
    blockLines.forEach((block, lines) { result[block] = lines.toList()..sort(); });
    List<String> sortedBlocks = result.keys.toList();
    sortedBlocks.sort((a, b) {
      int floorA = int.tryParse(a.substring(0, a.length-1)) ?? 0;
      int floorB = int.tryParse(b.substring(0, b.length-1)) ?? 0;
      if (floorA != floorB) return floorA.compareTo(floorB);
      return a.compareTo(b);
    });
    Map<String, List<String>> sortedResult = {};
    for (var block in sortedBlocks) { sortedResult[block] = result[block]!; }
    return sortedResult;
  }

  List<Map<String, dynamic>> getItemsByLine(String line) {
    List<Map<String, dynamic>> items = [];
    
    int gwsCounter = 0;
    for (var item in allDataGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi == line) {
        items.add({ 
          ...item, 
          'source': 'GWS', 
          'ticket_bc': item['ticket_bc'] ?? '-',
          'unique_id': 'gws_${item['id']}_${gwsCounter++}_${item['code']}'
        });
      }
    }
    
    for (var item in allDataNonGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi == line) {
        items.add({ 
          ...item, 
          'source': 'NON GWS', 
          'ticket_bc': 'NON GWS',
          'unique_id': 'ngws_${item['uniq_id']}'
        });
      }
    }
    
    items.sort((a, b) {
      String code1 = (a['code'] ?? '').toString().toUpperCase();
      String code2 = (b['code'] ?? '').toString().toUpperCase();
      return code1.compareTo(code2);
    });
    return items;
  }

  List<Map<String, dynamic>> getAllItems() {
    List<Map<String, dynamic>> allItems = [];
    
    int gwsCounter = 0;
    for (var item in allDataGws) { 
      allItems.add({ 
        ...item, 
        'source': 'GWS',
        'unique_id': 'gws_${item['id']}_${gwsCounter++}_${item['code']}'
      }); 
    }
    
    for (var item in allDataNonGws) { 
      allItems.add({ 
        ...item, 
        'source': 'NON GWS',
        'unique_id': 'ngws_${item['uniq_id']}'
      }); 
    }
    
    allItems.sort((a, b) {
      String lokasiA = (a['lokasi'] ?? '').toString();
      String lokasiB = (b['lokasi'] ?? '').toString();
      return lokasiA.compareTo(lokasiB);
    });
    return allItems;
  }

  Color _getWeeklyColor(String weekly) {
    if (weekly.isEmpty || weekly == '-') return Colors.grey;
    Map<String, Color> weeklyColorMap = { 
      '0526': Colors.blue, '0626': Colors.green, '0726': Colors.orange, 
      '0826': Colors.purple, '0926': Colors.teal, '1026': Colors.pink, 
      '1126': Colors.indigo, '1226': Colors.cyan, '1326': Colors.amber, 
      '1426': Colors.lime, '1526': Colors.red 
    };
    return weeklyColorMap[weekly] ?? Colors.grey;
  }

  Future<void> _editItem(Map<String, dynamic> item, String source) async {
    String tableName = (source == 'GWS') ? 'inventory_gws' : 'inventory_non_gws';
    String idField = (source == 'GWS') ? 'id' : 'uniq_id';
    dynamic itemId = item[idField];
    TextEditingController qtyController = TextEditingController(text: item['qty'].toString());
    TextEditingController lokasiController = TextEditingController(text: item['lokasi'] ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Icon(Icons.edit, color: Colors.orange.shade700), const SizedBox(width: 8), Expanded(child: Text("Edit ${(item['code'] ?? '-').toString().toUpperCase()}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: "QTY", border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers)), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextFormField(controller: lokasiController, decoration: const InputDecoration(labelText: "LOKASI", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on), hintText: "Contoh: NK01-1A-01")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              int newQty = int.tryParse(qtyController.text) ?? 0;
              String newLokasi = lokasiController.text.trim().toUpperCase();
              if (newLokasi.isEmpty) { Utils.showErrorSnackbar(context, "Lokasi tidak boleh kosong"); return; }
              try {
                await Supabase.instance.client.from(tableName).update({'qty': newQty, 'lokasi': newLokasi}).eq(idField, itemId);
                if (mounted) { Navigator.pop(context); Utils.showSuccessSnackbar(context, "Data berhasil diupdate"); _loadAllData(); }
              } catch (e) { if (mounted) Utils.showErrorSnackbar(context, "Error: $e"); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showNoteDialog(String itemId, String currentNote) {
    TextEditingController noteController = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Catatan"),
        content: TextField(controller: noteController, decoration: const InputDecoration(hintText: "Ketik catatan untuk baris ini...", border: OutlineInputBorder()), maxLines: 3),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")), ElevatedButton(onPressed: () { _saveNote(itemId, noteController.text); Navigator.pop(context); }, child: const Text("Simpan"))],
      ),
    );
  }

  void _showAddItemDialog(String currentLokasi) {
    String selectedSource = 'GWS';
    TextEditingController codeController = TextEditingController();
    TextEditingController qtyController = TextEditingController();
    TextEditingController weeklyController = TextEditingController();
    TextEditingController ticketBcController = TextEditingController();
    
    int qtyValue = 0;
    
    Set<String> uniqueCodes = {};
    for (var item in allDataGws) { uniqueCodes.add((item['code'] ?? '').toString().toUpperCase()); }
    for (var item in allDataNonGws) { uniqueCodes.add((item['code'] ?? '').toString().toUpperCase()); }
    List<String> codeList = uniqueCodes.toList()..sort();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(children: [Icon(Icons.add_circle, color: Colors.green, size: 28), const SizedBox(width: 10), const Text("Tambah Data Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]),
                  const Divider(height: 24),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("LOKASI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.blue.shade200)),
                              child: Row(children: [const Icon(Icons.location_on, size: 20, color: Colors.blue), const SizedBox(width: 8), Expanded(child: Text(currentLokasi, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)))]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("SUMBER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () { setStateDialog(() { selectedSource = 'GWS'; }); },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(color: selectedSource == 'GWS' ? Colors.blue : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.inventory, color: selectedSource == 'GWS' ? Colors.white : Colors.blue), const SizedBox(width: 8), Text("GWS", style: TextStyle(color: selectedSource == 'GWS' ? Colors.white : Colors.blue, fontWeight: FontWeight.bold))]),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () { setStateDialog(() { selectedSource = 'NON GWS'; }); },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        decoration: BoxDecoration(color: selectedSource == 'NON GWS' ? Colors.orange : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.warehouse, color: selectedSource == 'NON GWS' ? Colors.white : Colors.orange), const SizedBox(width: 8), Text("NON GWS", style: TextStyle(color: selectedSource == 'NON GWS' ? Colors.white : Colors.orange, fontWeight: FontWeight.bold))]),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("CODE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Autocomplete<String>(
                              optionsBuilder: (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                                return codeList.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                              },
                              onSelected: (selection) { codeController.text = selection; setStateDialog(() {}); },
                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                codeController.addListener(() { setStateDialog(() {}); });
                                return TextFormField(
                                  controller: codeController,
                                  focusNode: focusNode,
                                  decoration: InputDecoration(
                                    hintText: "Ketik Code...",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                    suffixIcon: codeController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { codeController.clear(); setStateDialog(() {}); }) : null,
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("QTY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: qtyController,
                                    decoration: InputDecoration(hintText: "0", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)),
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    onChanged: (value) { setStateDialog(() { qtyValue = int.tryParse(value) ?? 0; }); },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () { int current = int.tryParse(qtyController.text) ?? 0; if (current > 0) { qtyController.text = (current - 1).toString(); setStateDialog(() { qtyValue = current - 1; }); } },
                                  child: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.remove, color: Colors.red, size: 28)),
                                ),
                                InkWell(
                                  onTap: () { int current = int.tryParse(qtyController.text) ?? 0; qtyController.text = (current + 1).toString(); setStateDialog(() { qtyValue = current + 1; }); },
                                  child: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.add, color: Colors.green, size: 28)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("WEEKLY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 4),
                            TextFormField(controller: weeklyController, decoration: InputDecoration(hintText: "Contoh: 1526", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (selectedSource == 'GWS')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("TICKET BC", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 4),
                              TextFormField(controller: ticketBcController, decoration: InputDecoration(hintText: "Nomor ticket", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)), style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text("BATAL", style: TextStyle(fontSize: 16, color: Colors.grey)))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            String code = codeController.text.trim().toUpperCase();
                            String qty = qtyController.text.trim();
                            String weekly = weeklyController.text.trim();
                            String ticketBc = ticketBcController.text.trim();
                            if (code.isEmpty) { Utils.showErrorSnackbar(context, "Code harus diisi"); return; }
                            if (qty.isEmpty) { Utils.showErrorSnackbar(context, "Qty harus diisi"); return; }
                            try {
                              Map<String, dynamic> newData = { 'code': code, 'qty': int.parse(qty), 'lokasi': currentLokasi.toUpperCase(), 'weekly': weekly.isEmpty ? null : weekly, 'date_time': DateTime.now().toIso8601String() };
                              if (selectedSource == 'GWS') { newData['ticket_bc'] = ticketBc.isEmpty ? null : ticketBc; await Supabase.instance.client.from('inventory_gws').insert(newData); }
                              else { newData['uniq_id'] = 'UID-${DateTime.now().millisecondsSinceEpoch}'; newData['status'] = 'Normal Stock'; await Supabase.instance.client.from('inventory_non_gws').insert(newData); }
                              if (mounted) { Navigator.pop(context); Utils.showSuccessSnackbar(context, "Data berhasil ditambahkan"); _loadAllData(); }
                            } catch (e) { if (mounted) Utils.showErrorSnackbar(context, "Error: $e"); }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: const Text("SIMPAN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CEK ACTUAL - BY AREA"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshCheckedItems, tooltip: "Reset semua status CEK OKE"),
          IconButton(icon: Icon(groupByLocation ? Icons.view_list : Icons.grid_view), onPressed: () { setState(() { groupByLocation = !groupByLocation; }); }, tooltip: groupByLocation ? "Tampilkan semua baris" : "Tampilkan ringkasan"),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorMessage != null) return Center(child: Text("Error: $errorMessage"));

    if (!groupByLocation) {
      List<Map<String, dynamic>> allItems = getAllItems();
      if (allItems.isEmpty) return const Center(child: Text("Tidak ada data"));
      Map<String, List<Map<String, dynamic>>> groupedByLocation = {};
      for (var item in allItems) {
        String lokasi = (item['lokasi'] ?? 'Unknown').toString();
        groupedByLocation.putIfAbsent(lokasi, () => []).add(item);
      }
      List<String> sortedLocations = groupedByLocation.keys.toList()..sort();
      return ListView.builder(
        itemCount: sortedLocations.length,
        itemBuilder: (context, index) {
          String lokasi = sortedLocations[index];
          List<Map<String, dynamic>> items = groupedByLocation[lokasi]!;
          int totalQtyLokasi = items.fold(0, (sum, item) => sum + ((item['qty'] ?? 0) as int));
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ExpansionTile(
              title: Row(children: [Expanded(child: Text(lokasi, style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.add_circle, color: Colors.green, size: 20), onPressed: () => _showAddItemDialog(lokasi), tooltip: "Tambah data di lokasi ini")]),
              subtitle: Text("${items.length} item | Total Qty: $totalQtyLokasi Pcs"),
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final String itemId = item['unique_id'];
                bool isChecked = checkedItems.contains(itemId);
                String currentNote = notes[itemId] ?? '';
                String weekly = item['weekly']?.toString() ?? '-';
                return Container(
                  color: isChecked ? Colors.green.shade100 : null,
                  child: ListTile(
                    leading: Icon(item['source'] == 'GWS' ? Icons.inventory : Icons.warehouse, color: item['source'] == 'GWS' ? Colors.blue : Colors.orange),
                    title: Row(children: [Text((item['code'] ?? '-').toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 12), Expanded(child: Text(item['ticket_bc'] ?? '-', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis))]),
                    subtitle: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _getWeeklyColor(weekly).withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text("Weekly: $weekly", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getWeeklyColor(weekly)))), const SizedBox(width: 12), Text("Qty: ${item['qty']} Pcs", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _editItem(item, item['source']), tooltip: "Edit Qty/Lokasi"),
                        IconButton(icon: Icon(isChecked ? Icons.check_circle : Icons.check_circle_outline, color: isChecked ? Colors.green : Colors.grey), onPressed: () { _saveCheckedStatus(itemId, !isChecked); }),
                        IconButton(icon: Icon(currentNote.isNotEmpty ? Icons.edit_note : Icons.note_add, color: currentNote.isNotEmpty ? Colors.blue : Colors.grey), onPressed: () { _showNoteDialog(itemId, currentNote); }),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      );
    }
    
    var blocks = getBlocksWithLines();
    if (blocks.isEmpty) return const Center(child: Text("Tidak ada data lokasi"));

    return ListView.builder(
      itemCount: blocks.length,
      itemBuilder: (context, index) {
        String block = blocks.keys.elementAt(index);
        List<String> lines = blocks[block]!;
        int totalQtyBlock = 0;
        for (var line in lines) {
          var items = getItemsByLine(line);
          for (var item in items) totalQtyBlock += (item['qty'] ?? 0) as int;
        }
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ExpansionTile(
            leading: CircleAvatar(backgroundColor: block.startsWith('1') ? Colors.blue.shade100 : Colors.green.shade100, child: Text(block)),
            title: Text("BLOK $block", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: Text("${lines.length} Line | Total Qty: $totalQtyBlock Pcs"),
            children: lines.map((line) {
              var items = getItemsByLine(line);
              int totalQtyLine = items.fold(0, (sum, item) => sum + ((item['qty'] ?? 0) as int));
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                color: block.startsWith('1') ? Colors.blue.shade50 : Colors.green.shade50,
                child: ExpansionTile(
                  title: Row(children: [Expanded(child: Text(line, style: const TextStyle(fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.add_circle, color: Colors.green, size: 20), onPressed: () => _showAddItemDialog(line), tooltip: "Tambah data di lokasi ini")]),
                  subtitle: Text("${items.length} item | Total Qty: $totalQtyLine Pcs"),
                  children: items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    final String itemId = item['unique_id'];
                    bool isChecked = checkedItems.contains(itemId);
                    String currentNote = notes[itemId] ?? '';
                    String weekly = item['weekly']?.toString() ?? '-';
                    return Container(
                      color: isChecked ? Colors.green.shade100 : null,
                      child: ListTile(
                        leading: Icon(item['source'] == 'GWS' ? Icons.inventory : Icons.warehouse, color: item['source'] == 'GWS' ? Colors.blue : Colors.orange),
                        title: Row(children: [Text((item['code'] ?? '-').toString().toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(width: 12), Expanded(child: Text(item['ticket_bc'] ?? '-', style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis))]),
                        subtitle: Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _getWeeklyColor(weekly).withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text("Weekly: $weekly", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _getWeeklyColor(weekly)))), const SizedBox(width: 12), Text("Qty: ${item['qty']} Pcs", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _editItem(item, item['source']), tooltip: "Edit Qty/Lokasi"),
                            IconButton(icon: Icon(isChecked ? Icons.check_circle : Icons.check_circle_outline, color: isChecked ? Colors.green : Colors.grey), onPressed: () { _saveCheckedStatus(itemId, !isChecked); }),
                            IconButton(icon: Icon(currentNote.isNotEmpty ? Icons.edit_note : Icons.note_add, color: currentNote.isNotEmpty ? Colors.blue : Colors.grey), onPressed: () { _showNoteDialog(itemId, currentNote); }),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}