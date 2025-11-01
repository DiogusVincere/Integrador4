import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GestaoAtivosScreen extends StatefulWidget {
  const GestaoAtivosScreen({Key? key}) : super(key: key);

  @override
  State<GestaoAtivosScreen> createState() => _GestaoAtivosScreenState();
}

class _GestaoAtivosScreenState extends State<GestaoAtivosScreen> {
  final _searchController = TextEditingController();
  String? _selectedEnvironment;
  String? _selectedStatus;
  String? _selectedManufacturer;

  final List<Asset> _assets = [
    Asset(
      id: 'AST-001',
      name: 'Servidor Dell R740',
      model: 'Dell PowerEdge',
      environment: 'Produção',
      status: 'Ativo',
      lastTicket: 'CHM-2023-045',
    ),
    Asset(
      id: 'AST-002',
      name: 'Switch Cisco 2960X',
      model: 'Cisco Catalyst',
      environment: 'Testes',
      status: 'Manutenção',
      lastTicket: 'CHM-2023-112',
    ),
    Asset(
      id: 'AST-003',
      name: 'Notebook Lenovo T490',
      model: 'Lenovo ThinkPad',
      environment: 'Desenvolvimento',
      status: 'Inativo',
      lastTicket: null,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Gestão de Ativos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => _showQRScanner(),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),

          // Asset List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _assets.length,
              itemBuilder: (context, index) {
                return _buildAssetCard(_assets[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar ativos...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Dropdowns
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedEnvironment,
                  decoration: InputDecoration(
                    labelText: 'Ambiente',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'production', child: Text('Produção')),
                    DropdownMenuItem(value: 'development', child: Text('Desenvolvimento')),
                    DropdownMenuItem(value: 'testing', child: Text('Testes')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedEnvironment = value);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Todos')),
                    DropdownMenuItem(value: 'active', child: Text('Ativo')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inativo')),
                    DropdownMenuItem(value: 'maintenance', child: Text('Manutenção')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAssetCard(Asset asset) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAssetDetails(asset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // QR Code Thumbnail
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: asset.id,
                  size: 60,
                ),
              ),
              const SizedBox(width: 16),

              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.id,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.model,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildChip(asset.environment, Colors.blue),
                        _buildStatusChip(asset.status),
                        if (asset.lastTicket != null)
                          _buildChip(asset.lastTicket!, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined),
                    onPressed: () => _showAssetDetails(asset),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Ativo':
        color = Colors.green;
        break;
      case 'Inativo':
        color = Colors.red;
        break;
      case 'Manutenção':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return _buildChip(status, color);
  }

  void _showQRScanner() {
    final MobileScannerController cameraController = MobileScannerController();
    final TextEditingController manualInputController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scanner QR Code',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    cameraController.dispose();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        cameraController.dispose();
                        Navigator.pop(context);
                        _showAssetDetailsByQR(barcode.rawValue);
                        break;
                      }
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Posicione o QR code dentro da área destacada'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: manualInputController,
                    decoration: InputDecoration(
                      hintText: 'Ex: AST-001',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (manualInputController.text.isNotEmpty) {
                      cameraController.dispose();
                      Navigator.pop(context);
                      _showAssetDetailsByQR(manualInputController.text);
                    }
                  },
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ],
        ),
      ),
    ).whenComplete(() {
      cameraController.dispose();
      manualInputController.dispose();
    });
  }

  void _showAssetDetails(Asset asset) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detalhes do Ativo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // QR Code
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: asset.id,
                  size: 200,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.smartphone),
                    label: const Text('Abrir no app'),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ID ${asset.id} copiado!')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copiar ID'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Technical Information
            const Text(
              'Informações Técnicas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Nome', asset.name),
            _buildInfoRow('Tag QR', asset.id),
            _buildInfoRow('Modelo', asset.model),
            _buildInfoRow('Serial', 'CN74839283'),
            _buildInfoRow('Fabricante', 'Dell'),
            _buildInfoRow('Fornecedor', 'ABC Distribuidora'),
            _buildInfoRow('Ambiente', asset.environment),
            _buildInfoRow('Status', asset.status),
            const SizedBox(height: 24),

            // Related Tickets
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Chamados Relacionados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ver Chamados'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTicketStat('Total de Chamados', '3', Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTicketStat('Em Aberto', '1', Colors.orange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (asset.lastTicket != null) ...[
                    _buildTicketItem(
                      asset.lastTicket!,
                      'Problema com rede',
                      '15/05/2023',
                      'Resolvido',
                      Colors.green,
                    ),
                    const SizedBox(height: 8),
                    _buildTicketItem(
                      'CHM-2023-112',
                      'Atualização de firmware',
                      '02/08/2023',
                      'Em Andamento',
                      Colors.orange,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Movement History
            const Text(
              'Histórico de Movimentações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildHistoryItem(
                    'Ativo cadastrado',
                    'Por: João Silva • 10/01/2022',
                    Icons.check_circle,
                    Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryItem(
                    'Movido para Produção',
                    'Por: Maria Souza • 15/02/2022',
                    Icons.refresh,
                    Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildHistoryItem(
                    'Manutenção preventiva',
                    'Por: Carlos Oliveira • 20/06/2022',
                    Icons.build,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.grey[200],
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildTicketItem(String id, String title, String date, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                id,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$title - $date',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String subtitle, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAssetDetailsByQR(String? qrCode) {
    if (qrCode == null) return;
    
    final asset = _assets.firstWhere(
      (a) => a.id == qrCode,
      orElse: () => _assets[0],
    );
    
    _showAssetDetails(asset);
  }
}

class Asset {
  final String id;
  final String name;
  final String model;
  final String environment;
  final String status;
  final String? lastTicket;

  Asset({
    required this.id,
    required this.name,
    required this.model,
    required this.environment,
    required this.status,
    this.lastTicket,
  });
}