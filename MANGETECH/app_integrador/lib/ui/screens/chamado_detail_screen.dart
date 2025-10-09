import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/providers/chamado_provider.dart';
import '../../models/chamado.dart';
import '../theme/app_theme.dart';

class ChamadoDetailScreen extends StatelessWidget {
  final String chamadoId;

  const ChamadoDetailScreen({
    Key? key,
    required this.chamadoId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChamadoProvider>(context);
    final chamado = provider.getChamadoById(chamadoId);

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
      ),
      body: ListView(
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
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      chamado.status.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
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
                    DateFormat('dd/MM/yyyy').format(chamado.dataCriacao),
                  ),
                  _buildInfoRow('Ambiente', chamado.ambiente),
                  _buildInfoRow('Ativo', chamado.ativo),
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
                    const Text('Nenhum responsável')
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
                                  color: Colors.blue,
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
                  const Text(
                    'Comentários',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (chamado.comentarios.isEmpty)
                    const Text('Nenhum comentário ainda')
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
}