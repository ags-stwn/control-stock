import 'package:flutter/material.dart';
import 'utils.dart';

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
    // PERBAIKAN: Hitung ulang selisih dengan rumus yang benar
    // Rumus: SELISIH = (GWS + NON GWS) - STOCK
    final correctedVariants = problematicVariants.map((v) {
      int stock = v['stock'] as int;
      int gws = v['gws'] as int;
      int nonGws = v['non_gws'] as int;
      int correctedSelisih = (gws + nonGws) - stock;
      
      return {
        ...v,
        'selisih': correctedSelisih,
        'status': correctedSelisih > 0 ? "PLUS" : (correctedSelisih < 0 ? "MINUS" : "SAMA"),
      };
    }).toList();
    
    // Hitung total PLUS dan MINUS berdasarkan selisih yang sudah diperbaiki
    final plusVariants = correctedVariants.where((v) => v['selisih'] > 0).toList();
    final minusVariants = correctedVariants.where((v) => v['selisih'] < 0).toList();
    
    int totalPlus = plusVariants.fold(0, (sum, v) => sum + (v['selisih'] as int));
    int totalMinus = minusVariants.fold(0, (sum, v) => sum + (v['selisih'] as int).abs());
    int totalSelisih = totalPlus - totalMinus;

    return Scaffold(
      appBar: AppBar(
        title: const Text("DETAIL VARIAN BERMASALAH"), 
        backgroundColor: Colors.red, 
        foregroundColor: Colors.white
      ),
      body: Column(
        children: [
          // HEADER SUMMARY CARD
          Container(
            color: Colors.red.shade50, 
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // TOTAL SELISIH
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    const Text("TOTAL SELISIH", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                    Text("${Utils.formatNumber(totalSelisih.abs())} PCS", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 20, 
                        color: totalSelisih >= 0 ? Colors.red : Colors.orange
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // PLUS DAN MINUS - DIBUAT BISA DIKLIK
                Row(
                  children: [
                    // Kotak PLUS (bisa diklik)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showDetailDialog(context, plusVariants, "PLUS", Colors.red);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8), 
                          decoration: BoxDecoration(
                            color: Colors.red.shade100, 
                            borderRadius: BorderRadius.circular(8)
                          ), 
                          child: Column(
                            children: [
                              const Text("PLUS", style: TextStyle(fontWeight: FontWeight.bold)), 
                              Text("${Utils.formatNumber(totalPlus)} PCS", 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${plusVariants.length} code", 
                                style: TextStyle(fontSize: 10, color: Colors.red.shade700)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Kotak MINUS (bisa diklik)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _showDetailDialog(context, minusVariants, "MINUS", Colors.orange);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8), 
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100, 
                            borderRadius: BorderRadius.circular(8)
                          ), 
                          child: Column(
                            children: [
                              const Text("MINUS", style: TextStyle(fontWeight: FontWeight.bold)), 
                              Text("${Utils.formatNumber(totalMinus)} PCS", 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${minusVariants.length} code", 
                                style: TextStyle(fontSize: 10, color: Colors.orange.shade700)
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // TOTAL CODE BERMASALAH
                Text(
                  "Total ${correctedVariants.length} code bermasalah", 
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          
          // TABLE HEADER
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
          
          // TABLE BODY
          Expanded(
            child: ListView.builder(
              itemCount: correctedVariants.length,
              itemBuilder: (context, index) {
                final item = correctedVariants[index];
                final bool isEven = index % 2 == 0;
                final bool isPlus = item['selisih'] > 0;
                final int selisihValue = item['selisih'];
                final String selisihText = selisihValue > 0 ? "+$selisihValue" : "$selisihValue";
                
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
                      _buildCell(
                        selisihText, 
                        flex: 2, 
                        fontWeight: FontWeight.bold, 
                        color: isPlus ? Colors.red : Colors.orange,
                      ),
                      _buildCell(
                        item['status'], 
                        flex: 2, 
                        fontWeight: FontWeight.bold, 
                        color: isPlus ? Colors.red : Colors.orange,
                      ),
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

  // Fungsi untuk menampilkan dialog detail PLUS atau MINUS
  void _showDetailDialog(BuildContext context, List<Map<String, dynamic>> variants, String type, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DETAIL $type",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${variants.length} code bermasalah",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        color: color,
                      ),
                    ],
                  ),
                ),
                
                // Total summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.05),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem("Total $type", variants.fold(0, (sum, v) => sum + (v['selisih'] as int).abs()).toString(), color),
                      _buildSummaryItem("Total Code", variants.length.toString(), color),
                    ],
                  ),
                ),
                
                // List header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  color: Colors.grey.shade100,
                  child: Row(
                    children: [
                      _buildDialogHeaderCell("No", flex: 1),
                      _buildDialogHeaderCell("CODE", flex: 2),
                      _buildDialogHeaderCell("STOCK", flex: 2),
                      _buildDialogHeaderCell("GWS", flex: 2),
                      _buildDialogHeaderCell("NON GWS", flex: 2),
                      _buildDialogHeaderCell("SELISIH", flex: 2),
                    ],
                  ),
                ),
                
                // List body
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    itemCount: variants.length,
                    itemBuilder: (context, index) {
                      final item = variants[index];
                      final bool isEven = index % 2 == 0;
                      final int selisihValue = item['selisih'];
                      final String selisihText = selisihValue > 0 ? "+$selisihValue" : "$selisihValue";
                      
                      return Container(
                        color: isEven ? Colors.white : Colors.grey.shade50,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            _buildDialogCell("${index + 1}", flex: 1),
                            _buildDialogCell(item['code'].toString().toUpperCase(), flex: 2, fontWeight: FontWeight.bold),
                            _buildDialogCell("${item['stock']}", flex: 2),
                            _buildDialogCell("${item['gws']}", flex: 2),
                            _buildDialogCell("${item['non_gws']}", flex: 2),
                            _buildDialogCell(
                              selisihText,
                              flex: 2,
                              fontWeight: FontWeight.bold,
                              color: type == "PLUS" ? Colors.red : Colors.orange,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Utils.formatNumber(int.parse(value)),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
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
        style: const TextStyle(
          color: Colors.white, 
          fontWeight: FontWeight.bold, 
          fontSize: 13
        ), 
        textAlign: TextAlign.center,
      ),
    );
  }
  
  Widget _buildCell(
    String text, {
    int flex = 1, 
    FontWeight fontWeight = FontWeight.normal, 
    Color color = Colors.black87, 
    double fontSize = 13
  }) {
    return Expanded(
      flex: flex, 
      child: Text(
        text, 
        style: TextStyle(
          color: color, 
          fontWeight: fontWeight, 
          fontSize: fontSize
        ), 
        textAlign: TextAlign.center, 
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // Untuk dialog
  Widget _buildDialogHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDialogCell(
    String text, {
    int flex = 1,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black87,
  }) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}