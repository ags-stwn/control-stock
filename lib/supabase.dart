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
                      _buildMenuButton(context, "STOCK ADMIN", Colors.green, Icons.inventory_2, StockAdminPage()),
                      const SizedBox(height: 20),
                      _buildMenuButton(context, "DATA NON GWS", Colors.orange, Icons.history, NonGwsTablePage()),
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
      
      final response = await Supabase.instance.client
          .from('stock_master')
          .select();
      
      setState(() {
        allData = List<Map<String, dynamic>>.from(response);
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text("Error: $errorMessage"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    if (filteredData.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

    return ListView.builder(
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
// NON GWS TABLE PAGE - DENGAN AUTOCOMPLETE
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
      
      final response = await Supabase.instance.client
          .from('inventory_non_gws')
          .select()
          .order('weekly', ascending: false);
      
      final normalizedData = response.map((item) {
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
        title: const Row(
          children: [
            Icon(Icons.download, color: Colors.green),
            SizedBox(width: 8),
            Text("Export CSV"),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.green.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    Text("${allData.length} baris data siap di-copy"),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text("Copy teks CSV di bawah ini, lalu paste ke Excel:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                        csvContent,
                        style: const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.blue.shade50,
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Tips: Select All (Ctrl+A) lalu Copy (Ctrl+C), paste ke Excel",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DATA NON GWS (TABEL)"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportToCSV,
            tooltip: "Export CSV",
          ),
        ],
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
                          setState(() {
                            searchQuery = "";
                            hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase().trim();
                  hasSearched = value.isNotEmpty;
                });
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text("Error: $errorMessage"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadInitialData,
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      );
    }

    if (allData.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

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
                      const Row(
                        children: [
                          Icon(Icons.summarize, color: Colors.orange, size: 28),
                          SizedBox(width: 10),
                          Text("RINGKASAN DATA NON GWS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
                          return Container(
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
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("TOTAL SEMUA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("$totalAll PCS", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => hasSearched = true),
                          icon: const Icon(Icons.search),
                          label: const Text("MULAI PENCARIAN"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  searchQuery = "";
                  hasSearched = false;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Kembali ke Ringkasan"),
            ),
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

  void _clearControllers() { 
    _codeController.clear(); 
    _qtyController.clear(); 
    _lokasiController.clear(); 
    _weeklyController.clear(); 
    _notedController.clear(); 
    _checkedByController.clear(); 
    _statusController.clear(); 
  }
  
  void _showAddDialog() { 
    _clearControllers(); 
    _showFormDialog(isEdit: false); 
  }
  
  void _showEditDialog(Map<String, dynamic> item, String uniqId) { 
    _codeController.text = item['code']?.toString() ?? ""; 
    _qtyController.text = item['qty']?.toString() ?? ""; 
    _lokasiController.text = item['lokasi']?.toString() ?? ""; 
    _weeklyController.text = item['weekly']?.toString() ?? ""; 
    _notedController.text = item['noted']?.toString() ?? ""; 
    _checkedByController.text = item['checked_by']?.toString() ?? ""; 
    _statusController.text = item['status']?.toString() ?? ""; 
    _showFormDialog(isEdit: true, uniqId: uniqId); 
  }
  
  void _showFormDialog({required bool isEdit, String? uniqId}) {
    // Set status otomatis untuk tambah baru
    if (!isEdit) {
      _statusController.text = "OKE CEK";
    }
    
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
                    // CODE dengan AutoComplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        List<String> uniqueCodes = allData
                            .map((e) => (e['code'] ?? '').toString().toUpperCase())
                            .toSet()
                            .toList();
                        return uniqueCodes.where((option) =>
                            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (selection) {
                        _codeController.text = selection;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _codeController.addListener(() {
                          setStateDialog(() {});
                        });
                        return TextFormField(
                          controller: _codeController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: "Code",
                            border: OutlineInputBorder(),
                            hintText: "Ketik untuk mencari...",
                          ),
                          enabled: !isEdit,
                          validator: (value) => value?.isEmpty ?? true ? "Code harus diisi" : null,
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    // QTY
                    TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(labelText: "Qty", border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true ? "Qty harus diisi" : null,
                    ),
                    const SizedBox(height: 10),
                    
                    // LOKASI dengan AutoComplete
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        List<String> uniqueLokasi = allData
                            .map((e) => (e['lokasi'] ?? '').toString().toUpperCase())
                            .toSet()
                            .toList();
                        return uniqueLokasi.where((option) =>
                            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (selection) {
                        _lokasiController.text = selection;
                      },
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _lokasiController.addListener(() {
                          setStateDialog(() {});
                        });
                        return TextFormField(
                          controller: _lokasiController,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            labelText: "Lokasi",
                            border: OutlineInputBorder(),
                            hintText: "Ketik untuk mencari...",
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    
                    // WEEKLY
                    TextFormField(
                      controller: _weeklyController,
                      decoration: const InputDecoration(labelText: "Weekly", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    
                    // NOTED
                    TextFormField(
                      controller: _notedController,
                      decoration: const InputDecoration(labelText: "Noted", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    
                    // CHECKED BY (manual)
                    TextFormField(
                      controller: _checkedByController,
                      decoration: const InputDecoration(labelText: "Checked By", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    
                    // STATUS (read only)
                    TextFormField(
                      controller: _statusController,
                      decoration: const InputDecoration(
                        labelText: "Status",
                        border: OutlineInputBorder(),
                        hintText: "OKE CEK",
                      ),
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await _saveData(isEdit: isEdit, uniqId: uniqId);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: Text(isEdit ? "Update" : "Simpan"),
              ),
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
      if (isEdit && uniqId != null) {
        await table.update(data).eq('uniq_id', uniqId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Data berhasil diupdate"), backgroundColor: Colors.green),
          );
        }
      } else {
        data['uniq_id'] = 'UID-${DateTime.now().millisecondsSinceEpoch}';
        await table.insert(data);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Data berhasil ditambahkan"), backgroundColor: Colors.green),
          );
        }
      }
      if (mounted) {
        Navigator.pop(context);
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _confirmDelete(String uniqId, String code) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Data?"),
        content: Text("Apakah Anda yakin ingin menghapus data dengan Code: ${code.toUpperCase()}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text("Hapus")),
        ],
      ),
    );
    if (confirm == true) await _deleteData(uniqId);
  }

  Future<void> _deleteData(String uniqId) async {
    try {
      await Supabase.instance.client.from('inventory_non_gws').delete().eq('uniq_id', uniqId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🗑️ Data berhasil dihapus"), backgroundColor: Colors.orange),
        );
        _loadInitialData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }
}