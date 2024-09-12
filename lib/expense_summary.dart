import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class WalletSummaryPortal extends StatelessWidget {
  final double depositedAmount;
  final double amountUsed;
  final double balanceRemained;

   WalletSummaryPortal({
    required this.depositedAmount,
    required this.amountUsed,
    required this.balanceRemained,
  });

  final formatter = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Wallet Summary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                child: _buildSummaryCard(),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 24),
                Text(
                  'Expense Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1.3,
                  child: _buildPieChart(),
                ),
                SizedBox(height: 24),
                _buildDetailsList(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildSummaryRow('Deposited Amount', depositedAmount, Colors.green),
            SizedBox(height: 8),
            _buildSummaryRow('Amount Used', amountUsed, Colors.red),
            SizedBox(height: 8),
            Divider(),
            SizedBox(height: 8),
            _buildSummaryRow('Balance Remained', balanceRemained, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          'TZS ${formatter.format(amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 0,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.red.shade400,
            value: amountUsed,
            title: '${((amountUsed / depositedAmount) * 100).toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green.shade400,
            value: balanceRemained,
            title: '${((balanceRemained / depositedAmount) * 100).toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        _buildDetailItem('Amount Used', amountUsed, Colors.red.shade400),
        SizedBox(height: 8),
        _buildProgressIndicator(amountUsed, Colors.red.shade400),
        SizedBox(height: 16),
        _buildDetailItem('Balance Remained', balanceRemained, Colors.green.shade400),
        SizedBox(height: 8),
        _buildProgressIndicator(balanceRemained, Colors.green.shade400),
      ],
    );
  }

  Widget _buildDetailItem(String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(label),
        ),
        Text(
          'TZS ${formatter.format(amount)}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double amount, Color color) {
    double percentage = (amount / depositedAmount).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        SizedBox(height: 4),
        Text(
          '${(percentage * 100).toStringAsFixed(1)}%',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
