import 'package:flutter/material.dart';

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