import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vqhsrrlofnyccjxkgmmn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZxaHNycmxvZm55Y2NqeGtnbW1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY0NzA1MzcsImV4cCI6MjA5MjA0NjUzN30.4OQ_8ZybM6DcwaTd3jMHH5BXv5hbwFtLEESBbFOQ7ag',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monitoring Stock Tyre',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
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
// STOCK ADMIN PAGE - DENGAN RINGKASAN COLLAPSE
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

  String _getDayName() {
    final now = DateTime.now();
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return days[now.weekday % 7];
  }

  String _getFormattedDateTime() {
    final now = DateTime.now();
    final dayName = _getDayName();
    return "$dayName, ${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute}:${now.second}";
  }

  String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
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
      lastUpdate = _getFormattedDateTime();
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STOCK ADMIN"),
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
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return Center(child: Text("Error: $errorMessage"));
    }
    if (allData.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

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
                          Text("${formatNumber(totalStock)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue)),
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
                                Text("${formatNumber(totalGws)} PCS", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
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
                                Text("${formatNumber(totalNonGws)} PCS", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
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
                            Text(variantNotInData != 0 ? "${formatNumber(variantNotInData)} PCS" : "0 PCS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: variantNotInData != 0 ? Colors.red : Colors.green)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Total Varian: ${formatNumber(totalVarian)} item", style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
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

  String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

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
                    Text("${formatNumber(variantNotInData)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
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
                            Text("${formatNumber(totalKelebihan)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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
                            Text("${formatNumber(totalKekurangan)} PCS", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
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
// NON GWS TABLE PAGE
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
  bool isLoading = true;
  String? errorMessage;

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

  List<Map<String, dynamic>> get filteredData {
    if (!hasSearched || searchQuery.isEmpty) {
      return [];
    }
    final query = searchQuery.toLowerCase().trim();
    return allData.where((item) {
      final code = (item['code'] ?? '').toString();
      final lokasi = (item['lokasi'] ?? '').toString();
      return code.contains(query) || lokasi.contains(query);
    }).toList();
  }

  int get totalQty {
    return filteredData.fold(0, (sum, item) => sum + ((item['qty'] ?? 0) as int));
  }

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
        String yearStr = clean.substring(clean.length - 2);
        return 2000 + int.parse(yearStr);
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

  void _exportToCSV() {
    if (allData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada data untuk di export"), backgroundColor: Colors.red),
      );
      return;
    }
    
    String csvContent = "No,Code,Lokasi,Weekly,Qty,Status,Noted,Checked By,Date Time\n";
    for (int i = 0; i < allData.length; i++) {
      var item = allData[i];
      csvContent += "${i + 1},"
          "\"${item['code'] ?? ''}\","
          "\"${item['lokasi'] ?? ''}\","
          "\"${item['weekly'] ?? ''}\","
          "${item['qty'] ?? 0},"
          "\"${item['status'] ?? ''}\","
          "\"${item['noted'] ?? ''}\","
          "\"${item['checked_by'] ?? ''}\","
          "\"${item['date_time'] ?? ''}\"\n";
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DATA NON GWS (TABEL)"),
        actions: [IconButton(icon: const Icon(Icons.download), onPressed: _exportToCSV, tooltip: "Export CSV")],
        bottom: PreferredSize(
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
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() { searchQuery = ""; hasSearched = false; });
                        },
                      )
                    : null,
              ),
              onChanged: (value) { setState(() { searchQuery = value.toLowerCase().trim(); hasSearched = value.isNotEmpty; }); },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, backgroundColor: Colors.orange, child: const Icon(Icons.add, color: Colors.white)),
      body: _buildBody(),
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
                            int itemYear = _extractYearFromWeekly(item['weekly'] ?? '');
                            return itemYear == year;
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
        Container(color: Colors.orange.shade50, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("🔍 Hasil: \"${_searchController.text}\""), Text("${filteredData.length} baris")])),
        Container(color: Colors.orange.shade700, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12), child: Row(children: [_buildHeaderCell("No", flex: 1), _buildHeaderCell("CODE", flex: 2), _buildHeaderCell("LOKASI", flex: 2), _buildHeaderCell("WEEKLY", flex: 2), _buildHeaderCell("QTY", flex: 1), _buildHeaderCell("STATUS", flex: 2)])),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length + 1,
            itemBuilder: (context, index) {
              if (index == filteredData.length) {
                return Container(color: Colors.grey.shade100, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [const Text("TOTAL QTY: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text("$totalQty Pcs", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red))]));
              }
              final item = filteredData[index];
              return GestureDetector(
                onTap: () => _showPopupMenu(context, item, item['uniq_id']),
                child: Container(
                  color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  child: Row(children: [
                    _buildCell("${index + 1}", flex: 1),
                    _buildCell((item['code'] ?? "-").toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                    _buildCell((item['lokasi'] ?? "-").toString().toUpperCase(), flex: 2),
                    _buildCell(item['weekly'] ?? "-", flex: 2),
                    _buildCell("${item['qty'] ?? 0}", flex: 1, fontWeight: FontWeight.bold),
                    _buildCell((item['status'] ?? "-").toString().toUpperCase(), flex: 2, fontSize: 11),
                  ]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(flex: flex, child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center));
  }

  Widget _buildCell(String text, {int flex = 1, FontWeight fontWeight = FontWeight.normal, Color color = Colors.black87, double fontSize = 13}) {
    return Expanded(flex: flex, child: Text(text, style: TextStyle(color: color, fontWeight: fontWeight, fontSize: fontSize), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis));
  }

  void _showPopupMenu(BuildContext context, Map<String, dynamic> item, String uniqId) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 20),
          ListTile(leading: const Icon(Icons.edit, color: Colors.blue), title: const Text("Edit Data"), onTap: () { Navigator.pop(context); _showEditDialog(item, uniqId); }),
          ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Hapus Data"), onTap: () { Navigator.pop(context); _confirmDelete(uniqId, item['code'] ?? ''); }),
          const Divider(),
          ListTile(leading: const Icon(Icons.close, color: Colors.grey), title: const Text("Batal"), onTap: () => Navigator.pop(context)),
          const SizedBox(height: 10),
        ]),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _qtyController = TextEditingController();
  final _lokasiController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _notedController = TextEditingController();
  final _checkedByController = TextEditingController();
  final _statusController = TextEditingController();

  void _clearControllers() { _codeController.clear(); _qtyController.clear(); _lokasiController.clear(); _weeklyController.clear(); _notedController.clear(); _checkedByController.clear(); _statusController.clear(); }
  void _showAddDialog() { _clearControllers(); _showFormDialog(isEdit: false); }
  void _showEditDialog(Map<String, dynamic> item, String uniqId) { _codeController.text = item['code']?.toString() ?? ""; _qtyController.text = item['qty']?.toString() ?? ""; _lokasiController.text = item['lokasi']?.toString() ?? ""; _weeklyController.text = item['weekly']?.toString() ?? ""; _notedController.text = item['noted']?.toString() ?? ""; _checkedByController.text = item['checked_by']?.toString() ?? ""; _statusController.text = item['status']?.toString() ?? ""; _showFormDialog(isEdit: true, uniqId: uniqId); }
  
  void _showFormDialog({required bool isEdit, String? uniqId}) {
    if (!isEdit) _statusController.text = "OKE CEK";
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(isEdit ? "✏️ Edit Data" : "➕ Tambah Data"),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                        List<String> uniqueCodes = allData.map((e) => (e['code'] ?? '').toString().toUpperCase()).toSet().toList();
                        return uniqueCodes.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (selection) { _codeController.text = selection; },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _codeController.addListener(() { setStateDialog(() {}); });
                        return TextFormField(controller: _codeController, focusNode: focusNode, decoration: const InputDecoration(labelText: "Code", border: OutlineInputBorder(), hintText: "Ketik untuk mencari..."), enabled: !isEdit, validator: (value) => value?.isEmpty ?? true ? "Code harus diisi" : null);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(controller: _qtyController, decoration: const InputDecoration(labelText: "Qty", border: OutlineInputBorder()), keyboardType: TextInputType.number, validator: (value) => value?.isEmpty ?? true ? "Qty harus diisi" : null),
                    const SizedBox(height: 10),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) return const Iterable<String>.empty();
                        List<String> uniqueLokasi = allData.map((e) => (e['lokasi'] ?? '').toString().toUpperCase()).toSet().toList();
                        return uniqueLokasi.where((option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (selection) { _lokasiController.text = selection; },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _lokasiController.addListener(() { setStateDialog(() {}); });
                        return TextFormField(controller: _lokasiController, focusNode: focusNode, decoration: const InputDecoration(labelText: "Lokasi", border: OutlineInputBorder(), hintText: "Ketik untuk mencari..."));
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(controller: _weeklyController, decoration: const InputDecoration(labelText: "Weekly", border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextFormField(controller: _notedController, decoration: const InputDecoration(labelText: "Noted", border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextFormField(controller: _checkedByController, decoration: const InputDecoration(labelText: "Checked By", border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextFormField(controller: _statusController, decoration: const InputDecoration(labelText: "Status", border: OutlineInputBorder(), hintText: "OKE CEK"), enabled: false),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
              ElevatedButton(onPressed: () async { if (_formKey.currentState?.validate() ?? false) await _saveData(isEdit: isEdit, uniqId: uniqId); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: Text(isEdit ? "Update" : "Simpan")),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveData({required bool isEdit, String? uniqId}) async {
    final table = Supabase.instance.client.from('inventory_non_gws');
    final code = _codeController.text.trim().toUpperCase();
    Map<String, dynamic> data = {
      "code": code,
      "qty": int.tryParse(_qtyController.text) ?? 0,
      "lokasi": _lokasiController.text.trim().toUpperCase(),
      "weekly": _weeklyController.text.trim(),
      "noted": _notedController.text.trim(),
      "checked_by": _checkedByController.text.trim(),
      "status": _statusController.text.trim(),
      "date_time": DateTime.now().toString(),
    };
    try {
      if (isEdit && uniqId != null) { await table.update(data).eq('uniq_id', uniqId); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Data berhasil diupdate"), backgroundColor: Colors.green)); }
      else { data['uniq_id'] = 'UID-${DateTime.now().millisecondsSinceEpoch}'; await table.insert(data); if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Data berhasil ditambahkan"), backgroundColor: Colors.green)); }
      if (mounted) { Navigator.pop(context); _loadInitialData(); }
    } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red)); }
  }

  Future<void> _confirmDelete(String uniqId, String code) async {
    final confirm = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text("Hapus Data?"), content: Text("Apakah Anda yakin ingin menghapus data dengan Code: ${code.toUpperCase()}?"), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")), TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Hapus"))]));
    if (confirm == true) await _deleteData(uniqId);
  }

  Future<void> _deleteData(String uniqId) async {
    try { await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', uniqId); if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Data berhasil dihapus"), backgroundColor: Colors.orange)); _loadInitialData(); } }
    catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red)); }
  }
}

// ==============================================
// CEK BY CODE PAGE
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
      for (var item in response) { checkedItems.add(item['id'].toString()); }
      setState(() {});
    } catch (e) { print("Error load checked items: $e"); }
  }

  Future<void> _loadNotes() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_notes').select();
      for (var item in response) { notes[item['id'].toString()] = item['note'].toString(); }
      setState(() {});
    } catch (e) { print("Error load notes: $e"); }
  }

  Future<void> _saveCheckedStatus(String itemId, bool isChecked) async {
    try {
      if (isChecked) { await Supabase.instance.client.from('cek_oke_status').upsert({'id': itemId, 'status': 'OKE'}); checkedItems.add(itemId); }
      else { await Supabase.instance.client.from('cek_oke_status').delete().eq('id', itemId); checkedItems.remove(itemId); }
      setState(() {});
    } catch (e) { print("Error save checked status: $e"); }
  }

  Future<void> _saveNote(String itemId, String note) async {
    try {
      if (note.isEmpty) { await Supabase.instance.client.from('cek_oke_notes').delete().eq('id', itemId); notes.remove(itemId); }
      else { await Supabase.instance.client.from('cek_oke_notes').upsert({'id': itemId, 'note': note}); notes[itemId] = note; }
      setState(() {});
    } catch (e) { print("Error save note: $e"); }
  }

  Future<void> _refreshCheckedItems() async {
    checkedItems.clear(); notes.clear();
    await _loadCheckedItems(); await _loadNotes();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Semua status dan note telah direset"), backgroundColor: Colors.orange));
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
    } catch (e) { setState(() { errorMessage = e.toString(); isLoading = false; }); }
  }

  List<Map<String, dynamic>> get filteredData {
    if (searchCode.isEmpty) return [];
    List<Map<String, dynamic>> results = [];
    String query = searchCode.toUpperCase().trim();
    
    for (var item in allDataGws) {
      String code = (item['code'] ?? '').toString().toUpperCase();
      if (code.contains(query)) {
        results.add({ ...item, 'ticket_bc': item['ticket_bc'] ?? '-', 'lokasi': item['lokasi'] ?? '-', 'weekly': item['weekly'] ?? '-', 'qty': item['qty'] ?? 0, 'id': 'gws_${item['id']}', 'isGws': true });
      }
    }
    
    for (var item in allDataNonGws) {
      String code = (item['code'] ?? '').toString().toUpperCase();
      if (code.contains(query)) {
        results.add({ ...item, 'ticket_bc': 'NON GWS', 'lokasi': item['lokasi'] ?? '-', 'weekly': item['weekly'] ?? '-', 'qty': item['qty'] ?? 0, 'id': 'ngws_${item['uniq_id']}', 'isGws': false });
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
    if (filteredData.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tidak ada data untuk di export"), backgroundColor: Colors.red)); return; }
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
          PopupMenuButton<String>(icon: const Icon(Icons.sort), onSelected: (value) { setState(() { sortBy = value; }); }, itemBuilder: (context) => [const PopupMenuItem(value: "default", child: Text("Default")), const PopupMenuItem(value: "weekly_asc", child: Text("Weekly A → Z")), const PopupMenuItem(value: "weekly_desc", child: Text("Weekly Z → A"))]),
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
                TextField(controller: _codeController, autofocus: true, decoration: InputDecoration(hintText: "Cari berdasarkan Code... (contoh: 7033, C45830)", prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.white, suffixIcon: _codeController.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _codeController.clear(); setState(() => searchCode = ""); }) : null), onChanged: (value) => setState(() => searchCode = value)),
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
                  final currentNote = notes[item['id']] ?? "";
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
// CEK BY AREA PAGE - DENGAN TAMBAH DATA, EDIT, CEK OKE, NOTE
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
      for (var item in response) { checkedItems.add(item['id'].toString()); }
      setState(() {});
    } catch (e) { print("Error load checked items: $e"); }
  }

  Future<void> _loadNotes() async {
    try {
      final response = await Supabase.instance.client.from('cek_oke_notes_area').select();
      for (var item in response) { notes[item['id'].toString()] = item['note'].toString(); }
      setState(() {});
    } catch (e) { print("Error load notes: $e"); }
  }

  Future<void> _saveCheckedStatus(String itemId, bool isChecked) async {
    try {
      if (isChecked) { await Supabase.instance.client.from('cek_oke_status_area').upsert({'id': itemId, 'status': 'OKE'}); checkedItems.add(itemId); }
      else { await Supabase.instance.client.from('cek_oke_status_area').delete().eq('id', itemId); checkedItems.remove(itemId); }
      setState(() {});
    } catch (e) { print("Error save checked status: $e"); }
  }

  Future<void> _saveNote(String itemId, String note) async {
    try {
      if (note.isEmpty) { await Supabase.instance.client.from('cek_oke_notes_area').delete().eq('id', itemId); notes.remove(itemId); }
      else { await Supabase.instance.client.from('cek_oke_notes_area').upsert({'id': itemId, 'note': note}); notes[itemId] = note; }
      setState(() {});
    } catch (e) { print("Error save note: $e"); }
  }

  Future<void> _refreshCheckedItems() async {
    checkedItems.clear(); notes.clear();
    await _loadCheckedItems(); await _loadNotes();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Semua status dan note telah direset"), backgroundColor: Colors.orange));
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
              if (newLokasi.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lokasi tidak boleh kosong"), backgroundColor: Colors.red)); return; }
              try {
                await Supabase.instance.client.from(tableName).update({'qty': newQty, 'lokasi': newLokasi}).eq(idField, itemId);
                if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Data berhasil diupdate"), backgroundColor: Colors.green)); _loadAllData(); }
              } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red)); }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(String currentLokasi) {
    String selectedSource = 'GWS';
    TextEditingController codeController = TextEditingController();
    TextEditingController qtyController = TextEditingController();
    TextEditingController weeklyController = TextEditingController();
    TextEditingController ticketBcController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Row(children: [Icon(Icons.add_circle, color: Colors.green), SizedBox(width: 8), Text("Tambah Data Baru")]),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(initialValue: currentLokasi, decoration: const InputDecoration(labelText: "LOKASI", border: OutlineInputBorder(), prefixIcon: Icon(Icons.location_on), hintText: "Otomatis sesuai lokasi"), enabled: false),
                  const SizedBox(height: 12),
                  SegmentedButton<String>(
                    segments: const [ButtonSegment(value: 'GWS', label: Text("GWS"), icon: Icon(Icons.inventory)), ButtonSegment(value: 'NON GWS', label: Text("NON GWS"), icon: Icon(Icons.warehouse))],
                    selected: {selectedSource},
                    onSelectionChanged: (Set<String> selection) { setStateDialog(() { selectedSource = selection.first; }); },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(controller: codeController, decoration: const InputDecoration(labelText: "CODE", border: OutlineInputBorder(), prefixIcon: Icon(Icons.qr_code), hintText: "Contoh: C45830")),
                  const SizedBox(height: 12),
                  TextFormField(controller: qtyController, decoration: const InputDecoration(labelText: "QTY", border: OutlineInputBorder(), prefixIcon: Icon(Icons.numbers)), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextFormField(controller: weeklyController, decoration: const InputDecoration(labelText: "WEEKLY", border: OutlineInputBorder(), prefixIcon: Icon(Icons.calendar_today), hintText: "Contoh: 1526")),
                  const SizedBox(height: 12),
                  if (selectedSource == 'GWS') TextFormField(controller: ticketBcController, decoration: const InputDecoration(labelText: "TICKET BC", border: OutlineInputBorder(), prefixIcon: Icon(Icons.qr_code), hintText: "Nomor ticket")),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () async {
                  String code = codeController.text.trim().toUpperCase();
                  String qty = qtyController.text.trim();
                  String weekly = weeklyController.text.trim();
                  String ticketBc = ticketBcController.text.trim();
                  if (code.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Code harus diisi"), backgroundColor: Colors.red)); return; }
                  if (qty.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Qty harus diisi"), backgroundColor: Colors.red)); return; }
                  try {
                    Map<String, dynamic> newData = { 'code': code, 'qty': int.parse(qty), 'lokasi': currentLokasi.toUpperCase(), 'weekly': weekly.isEmpty ? null : weekly, 'date_time': DateTime.now().toIso8601String() };
                    if (selectedSource == 'GWS') { newData['ticket_bc'] = ticketBc.isEmpty ? null : ticketBc; await Supabase.instance.client.from('inventory_gws').insert(newData); }
                    else { newData['uniq_id'] = 'UID-${DateTime.now().millisecondsSinceEpoch}'; newData['status'] = 'Normal Stock'; await Supabase.instance.client.from('inventory_non_gws').insert(newData); }
                    if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ Data berhasil ditambahkan"), backgroundColor: Colors.green)); _loadAllData(); }
                  } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red)); }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Simpan"),
              ),
            ],
          );
        },
      ),
    );
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
    } catch (e) { setState(() { errorMessage = e.toString(); isLoading = false; }); }
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
    for (var item in allDataGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi == line) items.add({ ...item, 'source': 'GWS', 'ticket_bc': item['ticket_bc'] ?? '-' });
    }
    for (var item in allDataNonGws) {
      String lokasi = (item['lokasi'] ?? '').toString().toUpperCase();
      if (lokasi == line) items.add({ ...item, 'source': 'NON GWS', 'ticket_bc': 'NON GWS' });
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
    for (var item in allDataGws) { allItems.add({ ...item, 'source': 'GWS' }); }
    for (var item in allDataNonGws) { allItems.add({ ...item, 'source': 'NON GWS' }); }
    allItems.sort((a, b) {
      String lokasiA = (a['lokasi'] ?? '').toString();
      String lokasiB = (b['lokasi'] ?? '').toString();
      return lokasiA.compareTo(lokasiB);
    });
    return allItems;
  }

  Color _getWeeklyColor(String weekly) {
    if (weekly.isEmpty || weekly == '-') return Colors.grey;
    Map<String, Color> weeklyColorMap = { '0526': Colors.blue, '0626': Colors.green, '0726': Colors.orange, '0826': Colors.purple, '0926': Colors.teal, '1026': Colors.pink, '1126': Colors.indigo, '1226': Colors.cyan, '1326': Colors.amber, '1426': Colors.lime, '1526': Colors.red };
    return weeklyColorMap[weekly] ?? Colors.grey;
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
              children: items.map((item) {
                String itemId = '${item['source']}_${item['code']}_${item['weekly']}_${item['ticket_bc']}';
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
                  children: items.map((item) {
                    String itemId = '${item['source']}_${item['code']}_${item['weekly']}_${item['ticket_bc']}';
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