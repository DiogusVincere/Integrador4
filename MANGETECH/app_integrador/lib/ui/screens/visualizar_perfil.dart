import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/api/api_service.dart';
import '../theme/app_theme.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _estatisticas;
  String? _error;
  
  bool _notificacoesChamados = true;
  bool _notificacoesComentarios = true;
  bool _notificacoesStatus = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _apiService.getUserProfile(),
        _apiService.getEstatisticas(),
      ]);

      if (!mounted) return;

      setState(() {
        _profileData = results[0] as Map<String, dynamic>?;
        _estatisticas = results[1] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getSafeString(dynamic value, [String defaultValue = 'Não informado']) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ========== EDITAR PERFIL ==========
  
  Future<void> _showEditarPerfilDialog() async {
    if (!mounted) return;
    
    final nomeController = TextEditingController(
      text: _getSafeString(_profileData?['first_name'], '')
    );
    final sobrenomeController = TextEditingController(
      text: _getSafeString(_profileData?['last_name'], '')
    );
    final usuarioController = TextEditingController(
      text: _getSafeString(_profileData?['username'], '')
    );
    final emailController = TextEditingController(
      text: _getSafeString(_profileData?['email'], '')
    );
    
    final formKey = GlobalKey<FormState>();

    try {
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite seu nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: sobrenomeController,
                    decoration: const InputDecoration(
                      labelText: 'Sobrenome',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite seu sobrenome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: usuarioController,
                    decoration: const InputDecoration(
                      labelText: 'Usuário',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite seu usuário';
                      }
                      if (value.trim().length < 3) {
                        return 'Usuário deve ter pelo menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite seu email';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Digite um email válido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      );

      if (result == true && mounted && _profileData != null) {
        setState(() {
          _profileData!['first_name'] = nomeController.text.trim();
          _profileData!['last_name'] = sobrenomeController.text.trim();
          _profileData!['username'] = usuarioController.text.trim();
          _profileData!['email'] = emailController.text.trim();
        });
        _showSnackBar('Perfil atualizado com sucesso!');
      }
    } catch (e) {
      _showSnackBar('Erro ao editar perfil', isError: true);
    } finally {
      nomeController.dispose();
      sobrenomeController.dispose();
      usuarioController.dispose();
      emailController.dispose();
    }
  }

  // ========== NOTIFICAÇÕES ==========
  
  Future<void> _showNotificacoesDialog() async {
    bool localChamados = _notificacoesChamados;
    bool localComentarios = _notificacoesComentarios;
    bool localStatus = _notificacoesStatus;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Notificações'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Novos Chamados'),
                value: localChamados,
                onChanged: (value) {
                  setDialogState(() {
                    localChamados = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Comentários'),
                value: localComentarios,
                onChanged: (value) {
                  setDialogState(() {
                    localComentarios = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Mudanças de Status'),
                value: localStatus,
                onChanged: (value) {
                  setDialogState(() {
                    localStatus = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _notificacoesChamados = localChamados;
                    _notificacoesComentarios = localComentarios;
                    _notificacoesStatus = localStatus;
                  });
                }
                Navigator.pop(dialogContext);
                _showSnackBar('Preferências salvas!');
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== ALTERAR SENHA ==========
  
  Future<void> _showAlterarSenhaDialog() async {
    final senhaAtualController = TextEditingController();
    final novaSenhaController = TextEditingController();
    final confirmarSenhaController = TextEditingController();
    
    final formKey = GlobalKey<FormState>();
    bool obscureSenhaAtual = true;
    bool obscureNovaSenha = true;
    bool obscureConfirmarSenha = true;

    bool? result;
    
    try {
      result = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: const Text('Alterar Senha'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: senhaAtualController,
                      obscureText: obscureSenhaAtual,
                      decoration: InputDecoration(
                        labelText: 'Senha Atual',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureSenhaAtual ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () {
                            setDialogState(() {
                              obscureSenhaAtual = !obscureSenhaAtual;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Digite a senha atual';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: novaSenhaController,
                      obscureText: obscureNovaSenha,
                      decoration: InputDecoration(
                        labelText: 'Nova Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureNovaSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () {
                            setDialogState(() {
                              obscureNovaSenha = !obscureNovaSenha;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Digite a nova senha';
                        if (value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: confirmarSenhaController,
                      obscureText: obscureConfirmarSenha,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscureConfirmarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirmarSenha = !obscureConfirmarSenha;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Confirme a senha';
                        if (value != novaSenhaController.text) return 'Senhas não conferem';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                child: const Text('Alterar'),
              ),
            ],
          ),
        ),
      );

      if (result == true && mounted) {
        _showSnackBar('Senha alterada com sucesso!');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao alterar senha', isError: true);
      }
    } finally {
      senhaAtualController.dispose();
      novaSenhaController.dispose();
      confirmarSenhaController.dispose();
    }
  }

  // ========== LOGOUT ==========
  
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Logout'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sair'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _showEditarPerfilDialog,
          ),
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
            Text('Carregando perfil...'),
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
              const Text('Erro ao carregar perfil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfileData,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    final authProvider = Provider.of<AuthProvider>(context);

    return RefreshIndicator(
      onRefresh: _loadProfileData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(authProvider),
          const SizedBox(height: 24),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildStatisticsCard(),
          const SizedBox(height: 16),
          _buildSettingsCard(),
          const SizedBox(height: 16),
          _buildLogoutButton(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AuthProvider authProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Center(
                child: Text(
                  authProvider.getInitials(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.userName ?? 'Usuário',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            if (authProvider.userEmail != null)
              Text(
                authProvider.userEmail!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Pessoais',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.person_outline,
              'Nome',
              _getSafeString(_profileData?['first_name']),
            ),
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              _getSafeString(_profileData?['email']),
            ),
            _buildInfoRow(
              Icons.badge_outlined,
              'Usuário',
              _getSafeString(_profileData?['username']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    int totalChamados = 0;
    int abertos = 0;
    int andamento = 0;
    int concluidos = 0;
    
    final porStatus = _estatisticas?['por_status'];
    
    if (porStatus != null && porStatus is List) {
      for (var item in porStatus) {
        if (item == null) continue;
        
        final status = _getSafeString(item['status'], '').toUpperCase();
        final totalStr = _getSafeString(item['total'], '0');
        final total = int.tryParse(totalStr) ?? 0;
        
        totalChamados += total;
        
        if (status == 'ABERTO') {
          abertos = total;
        } else if (status.contains('ANDAMENTO')) {
          andamento = total;
        } else if (status.contains('CONCLU')) {
          concluidos = total;
        }
      }
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minhas Estatísticas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Total', totalChamados.toString(), Icons.assessment, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Abertos', abertos.toString(), Icons.inbox, Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Andamento', andamento.toString(), Icons.hourglass_empty, Colors.purple),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Concluídos', concluidos.toString(), Icons.check_circle, Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Configurações',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
            ),
            title: const Text('Notificações'),
            subtitle: const Text('Gerencie suas notificações'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showNotificacoesDialog,
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
            ),
            title: const Text('Alterar Senha'),
            subtitle: const Text('Altere sua senha de acesso'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showAlterarSenhaDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      color: Colors.red[50],
      child: InkWell(
        onTap: _handleLogout,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.red[700]),
              const SizedBox(width: 12),
              Text(
                'Sair da Conta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}  