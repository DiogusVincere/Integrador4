  import 'package:app_integrador/ui/screens/editarChamado_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:intl/intl.dart';
  import '../../data/providers/chamado_provider.dart';
  import '../../models/chamado.dart';
  import '../theme/app_theme.dart';


  class ChamadoDetailScreen extends StatefulWidget {
    final String chamadoId;

    const ChamadoDetailScreen({
      Key? key,
      required this.chamadoId,
    }) : super(key: key);

    @override
    State<ChamadoDetailScreen> createState() => _ChamadoDetailScreenState();
  }

  class _ChamadoDetailScreenState extends State<ChamadoDetailScreen> {
    
    Future<void> _navigateToEdit(Chamado chamado) async {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditarChamadoScreen(chamado: chamado),
        ),
      );

      // Se o chamado foi editado com sucesso, recarrega os detalhes
      if (result == true && mounted) {
        final provider = Provider.of<ChamadoProvider>(context, listen: false);
        await provider.fetchChamadoById(widget.chamadoId);
        setState(() {}); // Força reconstrução da tela
      }
    }

    @override
    Widget build(BuildContext context) {
      final provider = Provider.of<ChamadoProvider>(context);
      final chamado = provider.getChamadoById(widget.chamadoId);

      if (chamado == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Chamado não encontrado')),
          body: const Center(
            child: Text('Chamado não encontrado'),
          ),
        );
      }

      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Detalhes do Chamado'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Editar chamado',
              onPressed: () => _navigateToEdit(chamado),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'comentar') {
                  _showAddComentarioDialog(chamado);
                } else if (value == 'status') {
                  _showMudarStatusDialog(chamado);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'comentar',
                  child: Row(
                    children: [
                      Icon(Icons.comment_outlined),
                      SizedBox(width: 12),
                      Text('Adicionar comentário'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'status',
                  child: Row(
                    children: [
                      Icon(Icons.sync_alt),
                      SizedBox(width: 12),
                      Text('Mudar status'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            final provider = Provider.of<ChamadoProvider>(context, listen: false);
            await provider.fetchChamadoById(widget.chamadoId);
            setState(() {});
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chamado.id,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        chamado.titulo,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(chamado.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              chamado.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(chamado.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPrioridadeColor(chamado.prioridade).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flag_outlined,
                                  size: 14,
                                  color: _getPrioridadeColor(chamado.prioridade),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  chamado.prioridade,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _getPrioridadeColor(chamado.prioridade),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Descrição
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        chamado.descricao,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Informações
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Solicitante', chamado.solicitante),
                      _buildInfoRow(
                        'Criado em',
                        DateFormat('dd/MM/yyyy HH:mm').format(chamado.dataCriacao),
                      ),
                      _buildInfoRow('Ambiente', chamado.ambiente),
                      _buildInfoRow('Ativo', chamado.ativo),
                      if (chamado.dataSugerida != null)
                        _buildInfoRow(
                          'Data Sugerida',
                          DateFormat('dd/MM/yyyy HH:mm').format(chamado.dataSugerida!),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Responsáveis
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Responsáveis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (chamado.responsaveis.isEmpty)
                        Text(
                          'Nenhum responsável atribuído',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        ...chamado.responsaveis.map((resp) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: AppTheme.primaryColor,
                                  child: Text(
                                    _getInitials(resp),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(resp),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Histórico
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Histórico',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (chamado.historico.isEmpty)
                        Text(
                          'Nenhum histórico ainda',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        ...chamado.historico.map((history) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(history.status),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      history.status,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(history.descricao),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${history.usuario} - ${DateFormat('dd/MM/yyyy HH:mm').format(history.timestamp)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Comentários
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Comentários',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddComentarioDialog(chamado),
                            icon: const Icon(Icons.add_comment, size: 18),
                            label: const Text('Adicionar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (chamado.comentarios.isEmpty)
                        Text(
                          'Nenhum comentário ainda',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      else
                        ...chamado.comentarios.map((comentario) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comentario.usuario,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(comentario.texto),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd/MM/yyyy HH:mm')
                                      .format(comentario.timestamp),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    Widget _buildInfoRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    Color _getStatusColor(String status) {
      switch (status.toUpperCase()) {
        case 'ABERTO':
          return AppTheme.statusAberto;
        case 'AGUARDANDO RESP':
        case 'AGUARDANDO RESPONSÁVEIS':
          return AppTheme.statusAguardando;
        case 'EM ANDAMENTO':
          return AppTheme.statusAndamento;
        case 'REALIZADO':
          return AppTheme.statusRealizado;
        case 'CONCLUÍDO':
          return AppTheme.statusConcluido;
        case 'CANCELADO':
          return AppTheme.statusCancelado;
        default:
          return Colors.grey;
      }
    }

    Color _getPrioridadeColor(String prioridade) {
      switch (prioridade.toLowerCase()) {
        case 'crítico':
          return Colors.red;
        case 'alta':
          return Colors.orange;
        case 'média':
          return Colors.yellow[700]!;
        case 'baixa':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }

    String _getInitials(String name) {
      final parts = name.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      if (parts[0].length >= 2) {
        return parts[0].substring(0, 2).toUpperCase();
      }
      return parts[0][0].toUpperCase();
    }

    void _showAddComentarioDialog(Chamado chamado) {
      final controller = TextEditingController();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Adicionar Comentário'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Digite seu comentário...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  
                  final provider = Provider.of<ChamadoProvider>(context, listen: false);
                  final success = await provider.adicionarComentario(
                    chamadoId: chamado.id,
                    texto: controller.text.trim(),
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comentário adicionado!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    setState(() {});
                  }
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      );
    }

    void _showMudarStatusDialog(Chamado chamado) {
      String novoStatus = chamado.status;
      final controller = TextEditingController();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Mudar Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: novoStatus,
                decoration: const InputDecoration(
                  labelText: 'Novo Status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ABERTO', child: Text('ABERTO')),
                  DropdownMenuItem(value: 'AGUARDANDO RESP', child: Text('AGUARDANDO RESP')),
                  DropdownMenuItem(value: 'EM ANDAMENTO', child: Text('EM ANDAMENTO')),
                  DropdownMenuItem(value: 'REALIZADO', child: Text('REALIZADO')),
                  DropdownMenuItem(value: 'CONCLUÍDO', child: Text('CONCLUÍDO')),
                  DropdownMenuItem(value: 'CANCELADO', child: Text('CANCELADO')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    novoStatus = value;
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Descrição da mudança',
                  hintText: 'Ex: Problema resolvido',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.of(context).pop();
                  
                  final provider = Provider.of<ChamadoProvider>(context, listen: false);
                  final success = await provider.mudarStatus(
                    chamadoId: chamado.id,
                    novoStatus: novoStatus,
                    descricao: controller.text.trim(),
                  );
                  
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status alterado!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    setState(() {});
                  }
                }
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
    }
  }