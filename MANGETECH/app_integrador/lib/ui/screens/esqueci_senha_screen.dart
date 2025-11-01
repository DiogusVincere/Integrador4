import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/auth_provider.dart';

class EsqueciSenhaScreen extends StatefulWidget {
  const EsqueciSenhaScreen({Key? key}) : super(key: key);

  @override
  State<EsqueciSenhaScreen> createState() => _EsqueciSenhaScreenState();
}

class _EsqueciSenhaScreenState extends State<EsqueciSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailEnviado = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleRecuperarSenha() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.recuperarSenha(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          setState(() => _emailEnviado = true);
        } else {
          _mostrarMensagem(
            authProvider.error ?? 'Erro ao enviar email de recuperação',
            sucesso: false,
          );
        }
      }
    }
  }

  void _mostrarMensagem(String mensagem, {required bool sucesso}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: sucesso ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 2,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              child: _emailEnviado ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset,
            size: 64,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(height: 24),
          const Text(
            'Esqueceu a senha?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Não se preocupe! Digite seu email e enviaremos instruções para redefinir sua senha',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Email
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              hintText: 'seu@email.com',
            ),
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            enabled: !_isLoading,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, insira seu email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Por favor, insira um email válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Botão Enviar
          ElevatedButton(
            onPressed: _isLoading ? null : _handleRecuperarSenha,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                : const Text('Enviar Instruções'),
          ),
          const SizedBox(height: 16),

          // Link para Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lembrou a senha?',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                child: const Text(
                  'Voltar ao login',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Email Enviado!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Se o email informado estiver cadastrado, você receberá instruções para redefinir sua senha em:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          _emailController.text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2563EB),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue[700],
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                'Verifique sua caixa de entrada e spam',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'O email pode levar alguns minutos para chegar',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Botão Voltar ao Login
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Voltar ao Login'),
        ),
        const SizedBox(height: 12),

        // Botão Reenviar Email
        TextButton(
          onPressed: () {
            setState(() {
              _emailEnviado = false;
            });
          },
          child: const Text(
            'Não recebeu o email? Tentar novamente',
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}