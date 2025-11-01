import 'package:app_integrador/ui/screens/editar_chamado_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/chamado_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../widgets/chamado_card.dart';
import 'criar_chamado_screen.dart';
import 'gestao_ativos_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega os chamados após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChamados();
    });
  }

  Future<void> _loadChamados() async {
    try {
      await Provider.of<ChamadoProvider>(context, listen: false).fetchChamados();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar chamados: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _navigateToDetail(String chamadoId) {
    final provider = Provider.of<ChamadoProvider>(context, listen: false);
    final chamado = provider.getChamadoById(chamadoId);
    
    if (chamado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chamado não encontrado'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChamadoDetailScreen(
          chamadoId: chamadoId,
        ),
      ),
    );
  }

  Future<void> _navigateToCriarChamado() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CriarChamadoScreen(),
      ),
    );

    // Se o chamado foi criado com sucesso, recarrega a lista
    if (result == true && mounted) {
      _loadChamados();
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja realmente sair do aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Sair',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
      
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implementar busca
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Busca em desenvolvimento'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Gestão de Ativos',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const GestaoAtivosScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  authProvider.getInitials(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 'perfil') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Perfil em desenvolvimento'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (value == 'sair') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'perfil',
                child: Row(
                  children: [
                    const Icon(Icons.person_outline),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authProvider.userName ?? 'Usuário',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (authProvider.userEmail != null)
                          Text(
                            authProvider.userEmail!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'sair',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Sair', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Consumer<ChamadoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando chamados...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadChamados,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.chamados.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum chamado encontrado',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crie seu primeiro chamado clicando no botão abaixo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToCriarChamado,
                      icon: const Icon(Icons.add),
                      label: const Text('Criar Chamado'),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadChamados,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.chamados.length,
              itemBuilder: (context, index) {
                final chamado = provider.chamados[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ChamadoCard(
                    chamado: chamado,
                    onTap: () => _navigateToDetail(chamado.id),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCriarChamado,
        icon: const Icon(Icons.add),
        label: const Text('Criar Chamado'),
      ),
    );
  }
}