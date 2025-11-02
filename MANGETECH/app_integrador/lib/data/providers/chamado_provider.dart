import 'package:flutter/material.dart';
import '../../data/api/api_service.dart';
import '../../models/chamado.dart';

class ChamadoProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Chamado> _chamados = [];
  bool _isLoading = false;
  String? _error;

  List<Chamado> get chamados => _chamados;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ========== CARREGAR CHAMADOS ==========
  
  Future<void> fetchChamados({
    String? status,
    String? urgencia,
    String? search,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _chamados = await _apiService.getChamados(
        status: status,
        urgencia: urgencia,
        search: search,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar chamados: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== BUSCAR CHAMADO POR ID ==========
  
  Chamado? getChamadoById(String id) {
    try {
      return _chamados.firstWhere((c) => c.id == id);
    } catch (e) {
      print('Chamado não encontrado: $id');
      return null;
    }
  }

  Future<Chamado?> fetchChamadoById(String id) async {
    try {
      final chamado = await _apiService.getChamadoById(id);
      
      // Atualizar na lista se já existir
      final index = _chamados.indexWhere((c) => c.id == id);
      if (index != -1) {
        _chamados[index] = chamado;
        notifyListeners();
      }
      
      return chamado;
    } catch (e) {
      _error = 'Erro ao carregar chamado: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // ========== CRIAR CHAMADO ==========
  
  Future<bool> createChamado({
    required String titulo,
    required String descricao,
    required String ativo,
    required String ambiente,
    required String urgencia,
    String? dataSugerida,
    List<int>? responsaveis,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final novoChamado = await _apiService.createChamado(
        titulo: titulo,
        descricao: descricao,
        ativo: ativo,
        ambiente: ambiente,
        urgencia: urgencia,
        dataSugerida: dataSugerida,
        responsaveis: responsaveis,
      );
      
      _chamados.insert(0, novoChamado);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erro ao criar chamado: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ NOVO: Atualizar chamado
  Future<bool> updateChamado({
    required String chamadoId,
    String? titulo,
    String? descricao,
    String? ativo,
    String? ambiente,
    String? urgencia,
    String? status,
    String? dataSugerida,
    List<int>? responsaveis,
  }) async {
    try {
      final chamadoAtualizado = await _apiService.updateChamado(
        id: chamadoId,
        titulo: titulo,
        descricao: descricao,
        ativo: ativo,
        ambiente: ambiente,
        urgencia: urgencia,
        status: status,
        dataSugerida: dataSugerida,
        responsaveis: responsaveis,
      );
      
      // Atualizar na lista local
      final index = _chamados.indexWhere((c) => c.id == chamadoId);
      if (index != -1) {
        _chamados[index] = chamadoAtualizado;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Erro ao atualizar chamado: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ========== MUDAR STATUS ==========
  
  Future<bool> mudarStatus({
    required String chamadoId,
    required String novoStatus,
    required String descricao,
  }) async {
    try {
      await _apiService.mudarStatus(
        chamadoId: chamadoId,
        novoStatus: novoStatus,
        descricao: descricao,
      );
      
      // Recarregar o chamado atualizado do servidor
      await fetchChamadoById(chamadoId);
      
      return true;
    } catch (e) {
      _error = 'Erro ao mudar status: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ========== ADICIONAR COMENTÁRIO ==========
  
  Future<bool> adicionarComentario({
    required String chamadoId,
    required String texto,
  }) async {
    try {
      await _apiService.adicionarComentario(
        chamadoId: chamadoId,
        texto: texto,
      );
      
      // Recarregar o chamado específico
      await fetchChamadoById(chamadoId);
      
      return true;
    } catch (e) {
      _error = 'Erro ao adicionar comentário: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ========== ESTATÍSTICAS ==========
  
  Future<Map<String, dynamic>?> getEstatisticas() async {
    try {
      return await _apiService.getEstatisticas();
    } catch (e) {
      _error = 'Erro ao carregar estatísticas: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // ========== FILTROS LOCAIS ==========
  
  List<Chamado> filterByStatus(String status) {
    return _chamados.where((c) => c.status.toUpperCase() == status.toUpperCase()).toList();
  }

  List<Chamado> filterByUrgencia(String urgencia) {
    return _chamados.where((c) => c.prioridade == urgencia).toList();
  }

  List<Chamado> searchChamados(String query) {
    if (query.isEmpty) return _chamados;
    
    final lowerQuery = query.toLowerCase();
    return _chamados.where((c) {
      return c.titulo.toLowerCase().contains(lowerQuery) ||
             c.descricao.toLowerCase().contains(lowerQuery) ||
             c.id.toLowerCase().contains(lowerQuery) ||
             c.ativo.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ========== LIMPAR ERROS ==========
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}