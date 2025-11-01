import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/api/api_service.dart';

class DashboardGerencialScreen extends StatefulWidget {
  const DashboardGerencialScreen({Key? key}) : super(key: key);

  @override
  State<DashboardGerencialScreen> createState() => _DashboardGerencialScreenState();
}

class _DashboardGerencialScreenState extends State<DashboardGerencialScreen> {
  final ApiService _apiService = ApiService();
  
  String _selectedPeriod = '30';
  bool _isLoading = true;
  Map<String, dynamic>? _dashboardData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getDashboardGerencial();
      
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dashboard Gerencial'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedPeriod == '7' ? 'Últimos 7 dias' :
                    _selectedPeriod == '30' ? 'Últimos 30 dias' : 'Últimos 90 dias',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
            onSelected: (value) {
              setState(() => _selectedPeriod = value);
              _loadDashboardData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7', child: Text('Últimos 7 dias')),
              const PopupMenuItem(value: '30', child: Text('Últimos 30 dias')),
              const PopupMenuItem(value: '90', child: Text('Últimos 90 dias')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _showExportOptions,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando dashboard...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadDashboardData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_dashboardData == null) {
      return const Center(child: Text('Sem dados disponíveis'));
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildKPICards(),
          const SizedBox(height: 24),
          _buildChartRow1(),
          const SizedBox(height: 24),
          _buildChartRow2(),
          const SizedBox(height: 24),
          _buildCriticalTicketsTable(),
        ],
      ),
    );
  }

  Widget _buildKPICards() {
    final kpis = _dashboardData!['kpis'] as Map<String, dynamic>;
    
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildKPICard(
          'Total Chamados',
          kpis['total_chamados'].toString(),
          'Todos os chamados',
          Icons.assessment,
          Colors.blue,
          '',
          true,
        ),
        _buildKPICard(
          'Abertos',
          kpis['abertos'].toString(),
          'Aguardando atendimento',
          Icons.inbox,
          Colors.orange,
          '',
          false,
        ),
        _buildKPICard(
          'Em Andamento',
          kpis['em_andamento'].toString(),
          'Sendo resolvidos',
          Icons.hourglass_empty,
          Colors.purple,
          '',
          false,
        ),
        _buildKPICard(
          'Críticos Abertos',
          kpis['criticos_abertos'].toString(),
          'Alta prioridade',
          Icons.warning,
          Colors.red,
          '',
          false,
        ),
      ],
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    String trend,
    bool isPositive, {
    bool showProgress = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartRow1() {
    final porStatus = _dashboardData!['por_status'] as Map<String, dynamic>;
    
    final total = porStatus.values.fold<int>(0, (sum, value) => sum + (value as int));
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chamados por Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: (porStatus['aberto'] ?? 0).toDouble(),
                      title: '${((porStatus['aberto'] ?? 0) / total * 100).toStringAsFixed(0)}%',
                      color: Colors.blue,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: (porStatus['em_andamento'] ?? 0).toDouble(),
                      title: '${((porStatus['em_andamento'] ?? 0) / total * 100).toStringAsFixed(0)}%',
                      color: Colors.orange,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: (porStatus['concluido'] ?? 0).toDouble(),
                      title: '${((porStatus['concluido'] ?? 0) / total * 100).toStringAsFixed(0)}%',
                      color: Colors.green,
                      radius: 50,
                    ),
                    PieChartSectionData(
                      value: (porStatus['cancelado'] ?? 0).toDouble(),
                      title: '${((porStatus['cancelado'] ?? 0) / total * 100).toStringAsFixed(0)}%',
                      color: Colors.red,
                      radius: 50,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildLegendItem('Aberto', Colors.blue),
                _buildLegendItem('Em Andamento', Colors.orange),
                _buildLegendItem('Concluído', Colors.green),
                _buildLegendItem('Cancelado', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildChartRow2() {
    final porUrgencia = _dashboardData!['por_urgencia'] as Map<String, dynamic>;
    
    // Calcular o valor máximo para o gráfico
    int maxValue = 0;
    porUrgencia.forEach((key, value) {
      if (value is int && value > maxValue) {
        maxValue = value;
      }
    });
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chamados por Urgência',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (maxValue + 10).toDouble(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['Baixa', 'Média', 'Alta', 'Crítico'];
                          if (value.toInt() >= 0 && value.toInt() < titles.length) {
                            return Text(titles[value.toInt()], style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: (porUrgencia['baixa'] ?? 0).toDouble(), color: Colors.blue, width: 20)]),
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: (porUrgencia['media'] ?? 0).toDouble(), color: Colors.yellow[700]!, width: 20)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: (porUrgencia['alta'] ?? 0).toDouble(), color: Colors.orange, width: 20)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: (porUrgencia['critico'] ?? 0).toDouble(), color: Colors.red, width: 20)]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalTicketsTable() {
    final criticos = _dashboardData!['criticos'] as List<dynamic>;
    
    if (criticos.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.check_circle_outline, size: 48, color: Colors.green[400]),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum chamado crítico aberto',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Chamados Críticos Abertos',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Título')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Ambiente')),
                DataColumn(label: Text('Urgência')),
              ],
              rows: criticos.map((chamado) {
                final urgencia = chamado['urgencia'] ?? chamado['prioridade'] ?? 'Média';
                Color urgenciaColor;
                switch (urgencia.toLowerCase()) {
                  case 'crítico':
                    urgenciaColor = Colors.red;
                    break;
                  case 'alta':
                    urgenciaColor = Colors.orange;
                    break;
                  default:
                    urgenciaColor = Colors.yellow[700]!;
                }
                
                return DataRow(
                  cells: [
                    DataCell(Text(
                      '#${chamado['id']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    )),
                    DataCell(SizedBox(
                      width: 200,
                      child: Text(
                        chamado['titulo'] ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    )),
                    DataCell(Text(chamado['status'] ?? '')),
                    DataCell(Text(chamado['ambiente'] ?? '')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: urgenciaColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          urgencia,
                          style: TextStyle(
                            color: urgenciaColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Exportar Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              title: const Text('Exportar como PDF'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: Colors.green),
              title: const Text('Exportar como CSV'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Funcionalidade em desenvolvimento'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}