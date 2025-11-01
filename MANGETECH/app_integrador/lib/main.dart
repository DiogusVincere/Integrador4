  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'ui/screens/login_screen.dart';
  import 'ui/screens/cadastro_screen.dart';
  import 'ui/screens/esqueci_senha_screen.dart';
  import 'ui/screens/dashboard_screen.dart';
  import 'ui/screens/dashBoardGerencial_screen.dart';
  import 'ui/screens/gestao_ativos_screen.dart';
  import 'data/providers/chamado_provider.dart';
  import 'data/providers/auth_provider.dart';
  import 'ui/theme/app_theme.dart';

  void main() {
    runApp(const MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ChamadoProvider()),
        ],
        child: MaterialApp(
          title: 'Chamados App',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          initialRoute: '/login', // ✅ Inicia no login com teste automático
          routes: {
            '/login': (context) => const LoginScreen(),
            '/cadastro': (context) => const CadastroScreen(),
            '/esqueci-senha': (context) => const EsqueciSenhaScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/dashboard-gerencial': (context) => const DashboardGerencialScreen(),
            '/gestao-ativos': (context) => const GestaoAtivosScreen()
          },
        ),
      );
    }
  }