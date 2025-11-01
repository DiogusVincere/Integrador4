  import 'dart:convert';
  import 'dart:io';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import '../../models/chamado.dart';
  import '../../models/ativo.dart';

  class ApiService {
    // ========== CONFIGURAÇÃO DA API ==========
    // IMPORTANTE: Mude conforme seu ambiente
    
    // Android Emulator
    static const String baseUrl = 'http://10.0.2.2:8000/api';
    
    // iOS Simulator
    // static const String baseUrl = 'http://127.0.0.1:8000/api';
    
    // Dispositivo físico (use seu IP local)
    // static const String baseUrl = 'http://192.168.15.18:8000/api';
    
    // ========== TIMEOUT ==========
    static const Duration timeout = Duration(seconds: 30);
    
    // ========== HEADERS ==========
    
    Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      if (includeAuth) {
        final token = await _getToken();
        if (token != null) {
          headers['Authorization'] = 'Token $token';
        }
      }
      
      return headers;
    }
    
    Future<String?> _getToken() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    }
    
    Future<void> _saveToken(String token) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
    }
    
    Future<void> _removeToken() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
    }
    
    // ========== TRATAMENTO DE ERROS ==========
    
    dynamic _handleResponse(http.Response response) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {'success': true};
        }
        return json.decode(utf8.decode(response.bodyBytes));
      } else if (response.statusCode == 400) {
        final error = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(_formatErrorMessage(error));
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso negado.');
      } else if (response.statusCode == 404) {
        throw Exception('Recurso não encontrado.');
      } else if (response.statusCode == 500) {
        throw Exception('Erro no servidor. Tente novamente mais tarde.');
      } else {
        throw Exception('Erro: ${response.statusCode}');
      }
    }
    
    String _formatErrorMessage(dynamic error) {
      if (error is Map) {
        if (error.containsKey('message')) return error['message'];
        if (error.containsKey('error')) return error['error'];
        if (error.containsKey('errors')) {
          final errors = error['errors'];
          if (errors is Map) return errors.values.first.toString();
          return errors.toString();
        }
        
        final errorMessages = <String>[];
        error.forEach((key, value) {
          if (value is List) {
            errorMessages.add('$key: ${value.join(", ")}');
          } else {
            errorMessages.add('$key: $value');
          }
        });
        return errorMessages.join('\n');
      }
      return error.toString();
    }
    
    // ========== AUTENTICAÇÃO ==========
    
    Future<Map<String, dynamic>> register({
      required String nome,
      required String email,
      required String senha,
    }) async {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/register/'),
              headers: await _getHeaders(includeAuth: false),
              body: json.encode({
                'nome': nome,
                'email': email,
                'senha': senha,
              }),
            )
            .timeout(timeout);
        
        final data = _handleResponse(response);
        if (data['token'] != null) {
          await _saveToken(data['token']);
        }
        return data;
      } on SocketException {
        throw Exception('Sem conexão com a internet. Verifique sua conexão.');
      } on http.ClientException {
        throw Exception('Erro ao conectar com o servidor. Verifique se o backend está rodando em $baseUrl');
      } catch (e) {
        throw Exception('Erro ao registrar: $e');
      }
    }
    
    Future<Map<String, dynamic>> login({
      required String email,
      required String senha,
    }) async {
      try {
        print('Tentando login em: $baseUrl/auth/login/');
        
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/login/'),
              headers: await _getHeaders(includeAuth: false),
              body: json.encode({
                'email': email,
                'senha': senha,
              }),
            )
            .timeout(timeout);
        
        final data = _handleResponse(response);
        
        if (data['success'] == true && data['token'] != null) {
          await _saveToken(data['token']);
        }
        return data;
      } on SocketException {
        throw Exception('Sem conexão. Verifique sua internet.');
      } on http.ClientException {
        throw Exception('Erro ao conectar. Verifique se o Django está rodando em http://192.168.15.18:8000');
      } catch (e) {
        throw Exception('Erro ao fazer login: $e');
      }
    }
    
    Future<void> logout() async {
      try {
        await http
            .post(
              Uri.parse('$baseUrl/auth/logout/'),
              headers: await _getHeaders(),
            )
            .timeout(timeout);
      } finally {
        await _removeToken();
      }
    }
    
    Future<Map<String, dynamic>> recuperarSenha({required String email}) async {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/auth/recuperar-senha/'),
              headers: await _getHeaders(includeAuth: false),
              body: json.encode({'email': email}),
            )
            .timeout(timeout);
        
        return _handleResponse(response);
      } catch (e) {
        throw Exception('Erro ao recuperar senha: $e');
      }
    }
    
    // ========== CHAMADOS ==========
    
    Future<List<Chamado>> getChamados({
      String? status,
      String? urgencia,
      String? search,
    }) async {
      try {
        var uri = Uri.parse('$baseUrl/chamados/');
        
        final queryParams = <String, String>{};
        if (status != null) queryParams['status'] = status;
        if (urgencia != null) queryParams['urgencia'] = urgencia;
        if (search != null) queryParams['search'] = search;
        
        if (queryParams.isNotEmpty) {
          uri = uri.replace(queryParameters: queryParams);
        }
        
        final response = await http
            .get(uri, headers: await _getHeaders())
            .timeout(timeout);
        
        final data = _handleResponse(response);
        final results = data['results'] ?? data;
        
        return (results as List).map((json) => Chamado.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Erro ao carregar chamados: $e');
      }
    }
    
    Future<Chamado> getChamadoById(String id) async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/chamados/$id/'),
              headers: await _getHeaders(),
            )
            .timeout(timeout);
        
        final data = _handleResponse(response);
        return Chamado.fromJson(data);
      } catch (e) {
        throw Exception('Erro ao carregar chamado: $e');
      }
    }
    
    Future<Chamado> createChamado({
      required String titulo,
      required String descricao,
      required String ativo,
      required String ambiente,
      required String urgencia,
      String? dataSugerida,
      List<int>? responsaveis,
      List<File>? anexos,
    }) async {
      try {
        final body = {
          'titulo': titulo,
          'descricao': descricao,
          'ativo': ativo,
          'ambiente': ambiente,
          'urgencia': urgencia,
          'status': 'ABERTO',
          if (dataSugerida != null) 'data_sugerida': dataSugerida,
          if (responsaveis != null && responsaveis.isNotEmpty) 
            'responsaveis': responsaveis,
        };
        
        final response = await http
            .post(
              Uri.parse('$baseUrl/chamados/'),
              headers: await _getHeaders(),
              body: json.encode(body),
            )
            .timeout(timeout);
        
        final data = _handleResponse(response);
        final chamado = Chamado.fromJson(data);
        
        // Upload de anexos se houver
        if (anexos != null && anexos.isNotEmpty) {
          for (var file in anexos) {
            await _uploadAnexo(chamado.id, file);
          }
        }
        
        return chamado;
      } catch (e) {
        throw Exception('Erro ao criar chamado: $e');
      }
    }
    
    Future<void> mudarStatus({
      required String chamadoId,
      required String novoStatus,
      required String descricao,
      List<File>? fotos,
    }) async {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/chamados/$chamadoId/mudar_status/'),
        );
        
        final headers = await _getHeaders();
        request.headers.addAll(headers);
        
        request.fields['status'] = novoStatus;
        request.fields['descricao'] = descricao;
        
        if (fotos != null) {
          for (var foto in fotos) {
            request.files.add(
              await http.MultipartFile.fromPath('fotos', foto.path),
            );
          }
        }
        
        final streamedResponse = await request.send().timeout(timeout);
        final response = await http.Response.fromStream(streamedResponse);
        
        _handleResponse(response);
      } catch (e) {
        throw Exception('Erro ao mudar status: $e');
      }
    }
    
    Future<void> adicionarComentario({
      required String chamadoId,
      required String texto,
    }) async {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl/chamados/$chamadoId/adicionar_comentario/'),
              headers: await _getHeaders(),
              body: json.encode({'texto': texto}),
            )
            .timeout(timeout);
        
        _handleResponse(response);
      } catch (e) {
        throw Exception('Erro ao adicionar comentário: $e');
      }
    }
    
    Future<void> _uploadAnexo(String chamadoId, File file) async {
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/chamados/$chamadoId/adicionar_anexo/'),
        );
        
        final headers = await _getHeaders();
        request.headers.addAll(headers);
        
        request.files.add(
          await http.MultipartFile.fromPath('arquivo', file.path),
        );
        
        final streamedResponse = await request.send().timeout(timeout);
        final response = await http.Response.fromStream(streamedResponse);
        
        _handleResponse(response);
      } catch (e) {
        throw Exception('Erro ao fazer upload de anexo: $e');
      }
    }
    
    Future<Map<String, dynamic>> getEstatisticas() async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/chamados/estatisticas/'),
              headers: await _getHeaders(),
            )
            .timeout(timeout);
        
        return _handleResponse(response);
      } catch (e) {
        throw Exception('Erro ao carregar estatísticas: $e');
      }
    }
    
    // ========== ATIVOS ==========
    
    Future<List<Ativo>> getAtivos({String? search}) async {
      try {
        var uri = Uri.parse('$baseUrl/ativos/');
        
        if (search != null) {
          uri = uri.replace(queryParameters: {'search': search});
        }
        
        final response = await http
            .get(uri, headers: await _getHeaders())
            .timeout(timeout);
        
        final data = _handleResponse(response);
        final results = data['results'] ?? data;
        
        return (results as List).map((json) => Ativo.fromJson(json)).toList();
      } catch (e) {
        throw Exception('Erro ao carregar ativos: $e');
      }
    }
    
    Future<Ativo> getAtivoByQRCode(String codigo) async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/ativos/$codigo/por_qrcode/'),
              headers: await _getHeaders(),
            )
            .timeout(timeout);
        
        final data = _handleResponse(response);
        return Ativo.fromJson(data['ativo']);
      } catch (e) {
        throw Exception('Erro ao buscar ativo: $e');
      }
    }
    
    // ========== DASHBOARD GERENCIAL ==========
    
    Future<Map<String, dynamic>> getDashboardGerencial() async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/dashboard/gerencial/'),
              headers: await _getHeaders(),
            )
            .timeout(timeout);
        
        final data = _handleResponse(response);
        return data['data'] ?? {};
      } catch (e) {
        throw Exception('Erro ao carregar dashboard: $e');
      }
    }
    
    // ========== USUÁRIOS ==========
    
    Future<Map<String, dynamic>> getUserProfile() async {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/usuarios/me/'),
              headers: await _getHeaders(),
            )
            .timeout(timeout);
        
        final data = _handleResponse(response);
        return data['user'] ?? {};
      } catch (e) {
        throw Exception('Erro ao carregar perfil: $e');
      }
    }
    
    // ========== TESTE DE CONEXÃO ==========
    
    Future<bool> testConnection() async {
      try {
        print('Testando conexão com: $baseUrl');
        final response = await http
            .get(Uri.parse('$baseUrl/chamados/'))
            .timeout(const Duration(seconds: 5));
        
        print('Status Code: ${response.statusCode}');
        return response.statusCode == 200 || response.statusCode == 401;
      } catch (e) {
        print('Erro ao testar conexão: $e');
        return false;
      }
    }
  }