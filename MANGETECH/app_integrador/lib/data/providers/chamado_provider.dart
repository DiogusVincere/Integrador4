import 'package:flutter/material.dart';
import '../../models/chamado.dart';

class ChamadoProvider with ChangeNotifier {
  List<Chamado> _chamados = [];
  bool _isLoading = false;
  String? _error;

  List<Chamado> get chamados => _chamados;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchChamados() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simula delay de API
      await Future.delayed(const Duration(seconds: 1));
      _chamados = _getMockChamados();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erro ao carregar chamados: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Chamado? getChamadoById(String id) {
    try {
      return _chamados.firstWhere((c) => c.id == id);
    } catch (e) {
      print('Chamado não encontrado: $id');
      return null;
    }
  }

  void atualizarStatus(String chamadoId, String novoStatus) {
    final index = _chamados.indexWhere((c) => c.id == chamadoId);
    if (index != -1) {
      // Aqui você implementaria a lógica de atualização
      // Por enquanto, apenas notifica
      notifyListeners();
    }
  }

  List<Chamado> _getMockChamados() {
    final now = DateTime.now();
    
    return [
      Chamado(
        id: '#REQ-2025-3043',
        titulo: 'Problema com impressora no setor financeiro',
        descricao: 'A impressora do setor financeiro HP LaserJet Pro M404dn está apresentando problemas de conexão de alimentação. Quando tentamos conectar o cabo, o display não funciona. Já tentamos trocar os cabos e verificar a configuração, mas o problema persiste.',
        status: 'EM ANDAMENTO',
        prioridade: 'Alta',
        ambiente: 'Setor Financeiro - Sala 204',
        ativo: 'HP LaserJet Pro M404dn (HKKT-0542)',
        solicitante: 'Maria Souza',
        responsaveis: ['Carlos Silva', 'João Mendes'],
        dataCriacao: now.subtract(const Duration(days: 2)),
        dataSugerida: now.add(const Duration(days: 1)),
        anexos: [
          'https://via.placeholder.com/300x200/FF6B6B/FFFFFF?text=Foto+1',
          'https://via.placeholder.com/300x200/4ECDC4/FFFFFF?text=Foto+2',
          'https://via.placeholder.com/300x200/45B7D1/FFFFFF?text=Foto+3',
        ],
        historico: [
          ChamadoStatusHistory(
            id: '1',
            status: 'ABERTO',
            descricao: 'Chamado aberto para resolver problema em impressora do setor financeiro.',
            usuario: 'Maria Souza',
            timestamp: now.subtract(const Duration(days: 2, hours: 2)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '2',
            status: 'EM ANDAMENTO',
            descricao: 'Atribuído para equipe técnica. Vou verificar o equipamento amanhã pela manhã.',
            usuario: 'Carlos Silva',
            timestamp: now.subtract(const Duration(days: 1, hours: 9)),
            fotos: ['https://via.placeholder.com/300x200/FFE66D/000000?text=Equipamento'],
          ),
          ChamadoStatusHistory(
            id: '3',
            status: 'AGUARDANDO RESP',
            descricao: 'Identifiquei problema no mecanismo de alimentação. Necessário substituir a correia da impressora.',
            usuario: 'Carlos Silva',
            timestamp: now.subtract(const Duration(days: 1, hours: 6)),
            fotos: [
              'https://via.placeholder.com/300x200/A8E6CF/000000?text=Problema',
              'https://via.placeholder.com/300x200/FF8B94/FFFFFF?text=Detalhe',
            ],
          ),
          ChamadoStatusHistory(
            id: '4',
            status: 'EM ANDAMENTO',
            descricao: 'Peça chegou. Vou substituir e verificar o funcionamento hoje.',
            usuario: 'Carlos Silva',
            timestamp: now.subtract(const Duration(hours: 2)),
            fotos: [],
          ),
        ],
        comentarios: [
          Comentario(
            id: '1',
            usuario: 'Carlos Silva',
            texto: 'Verifiquei o equipamento e realmente tem problemas na conexão. Vou precisar abrir e avaliar os componentes internos.',
            timestamp: now.subtract(const Duration(days: 1, hours: 9)),
          ),
          Comentario(
            id: '2',
            usuario: 'Ana Oliveira',
            texto: 'Por favor, avise quando for realizar o reparo para organizarmos o trabalho do setor. Obrigada!',
            timestamp: now.subtract(const Duration(hours: 5)),
          ),
        ],
      ),
      
      Chamado(
        id: '#REQ-2025-3044',
        titulo: 'Ar condicionado com vazamento de água',
        descricao: 'O ar condicionado da sala de reuniões está pingando água no chão. Já colocamos um balde embaixo mas precisa de manutenção urgente.',
        status: 'ABERTO',
        prioridade: 'Média',
        ambiente: 'Sala de Reuniões - 3º Andar',
        ativo: 'Ar Condicionado Split 18000 BTUs (AC-301)',
        solicitante: 'Pedro Santos',
        responsaveis: [],
        dataCriacao: now.subtract(const Duration(hours: 3)),
        dataSugerida: now.add(const Duration(days: 2)),
        anexos: [
          'https://via.placeholder.com/300x200/96CEB4/FFFFFF?text=Vazamento',
        ],
        historico: [
          ChamadoStatusHistory(
            id: '1',
            status: 'ABERTO',
            descricao: 'Chamado criado para manutenção de ar condicionado com vazamento.',
            usuario: 'Pedro Santos',
            timestamp: now.subtract(const Duration(hours: 3)),
            fotos: ['https://via.placeholder.com/300x200/96CEB4/FFFFFF?text=Vazamento'],
          ),
        ],
        comentarios: [],
      ),

      Chamado(
        id: '#REQ-2025-3042',
        titulo: 'Computador não liga - Setor de TI',
        descricao: 'Desktop Dell Optiplex 7090 não está ligando. LED da fonte pisca mas não dá boot.',
        status: 'REALIZADO',
        prioridade: 'Crítico',
        ambiente: 'TI - Sala 105',
        ativo: 'Dell Optiplex 7090 (PC-TI-042)',
        solicitante: 'Lucas Ferreira',
        responsaveis: ['Roberto Costa'],
        dataCriacao: now.subtract(const Duration(days: 5)),
        dataSugerida: now.subtract(const Duration(days: 3)),
        anexos: [],
        historico: [
          ChamadoStatusHistory(
            id: '1',
            status: 'ABERTO',
            descricao: 'Computador apresentando falha ao ligar.',
            usuario: 'Lucas Ferreira',
            timestamp: now.subtract(const Duration(days: 5)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '2',
            status: 'EM ANDAMENTO',
            descricao: 'Iniciando diagnóstico do equipamento.',
            usuario: 'Roberto Costa',
            timestamp: now.subtract(const Duration(days: 4)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '3',
            status: 'REALIZADO',
            descricao: 'Problema resolvido. Era a fonte de alimentação que estava com defeito. Substituída por uma nova.',
            usuario: 'Roberto Costa',
            timestamp: now.subtract(const Duration(days: 3)),
            fotos: [],
          ),
        ],
        comentarios: [
          Comentario(
            id: '1',
            usuario: 'Lucas Ferreira',
            texto: 'Muito obrigado pelo atendimento rápido! Computador funcionando perfeitamente.',
            timestamp: now.subtract(const Duration(days: 3)),
          ),
        ],
      ),

      Chamado(
        id: '#REQ-2025-3041',
        titulo: 'Lâmpada queimada no corredor',
        descricao: 'Três lâmpadas do corredor principal estão queimadas, deixando o ambiente escuro.',
        status: 'CONCLUÍDO',
        prioridade: 'Baixa',
        ambiente: 'Corredor Principal - 2º Andar',
        ativo: 'Iluminação LED (LUM-201-203)',
        solicitante: 'Fernanda Lima',
        responsaveis: ['José Almeida'],
        dataCriacao: now.subtract(const Duration(days: 7)),
        dataSugerida: now.subtract(const Duration(days: 5)),
        anexos: [],
        historico: [
          ChamadoStatusHistory(
            id: '1',
            status: 'ABERTO',
            descricao: 'Solicitação de troca de lâmpadas.',
            usuario: 'Fernanda Lima',
            timestamp: now.subtract(const Duration(days: 7)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '2',
            status: 'EM ANDAMENTO',
            descricao: 'Lâmpadas solicitadas no estoque.',
            usuario: 'José Almeida',
            timestamp: now.subtract(const Duration(days: 6)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '3',
            status: 'REALIZADO',
            descricao: 'Lâmpadas trocadas com sucesso.',
            usuario: 'José Almeida',
            timestamp: now.subtract(const Duration(days: 5)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '4',
            status: 'CONCLUÍDO',
            descricao: 'Chamado finalizado e aprovado pelo solicitante.',
            usuario: 'Fernanda Lima',
            timestamp: now.subtract(const Duration(days: 5)),
            fotos: [],
          ),
        ],
        comentarios: [],
      ),

      Chamado(
        id: '#REQ-2025-3045',
        titulo: 'Tela do notebook com falha',
        descricao: 'Notebook apresenta linhas verticais na tela. Problema começou hoje de manhã.',
        status: 'AGUARDANDO RESP',
        prioridade: 'Alta',
        ambiente: 'RH - Sala 302',
        ativo: 'Lenovo ThinkPad E14 (NB-RH-012)',
        solicitante: 'Carla Mendes',
        responsaveis: ['Roberto Costa', 'Carlos Silva'],
        dataCriacao: now.subtract(const Duration(hours: 6)),
        dataSugerida: now.add(const Duration(days: 3)),
        anexos: [
          'https://via.placeholder.com/300x200/F67280/FFFFFF?text=Tela+Com+Defeito',
          'https://via.placeholder.com/300x200/C06C84/FFFFFF?text=Detalhe',
        ],
        historico: [
          ChamadoStatusHistory(
            id: '1',
            status: 'ABERTO',
            descricao: 'Notebook com problema na tela.',
            usuario: 'Carla Mendes',
            timestamp: now.subtract(const Duration(hours: 6)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '2',
            status: 'EM ANDAMENTO',
            descricao: 'Analisando o equipamento. Possível problema no cabo flat da tela.',
            usuario: 'Roberto Costa',
            timestamp: now.subtract(const Duration(hours: 4)),
            fotos: [],
          ),
          ChamadoStatusHistory(
            id: '3',
            status: 'AGUARDANDO RESP',
            descricao: 'Necessário solicitar peça de reposição. Aguardando aprovação da gestão.',
            usuario: 'Roberto Costa',
            timestamp: now.subtract(const Duration(hours: 2)),
            fotos: [],
          ),
        ],
        comentarios: [
          Comentario(
            id: '1',
            usuario: 'Carla Mendes',
            texto: 'Quanto tempo vai levar aproximadamente? Preciso do notebook para trabalhar.',
            timestamp: now.subtract(const Duration(hours: 1)),
          ),
        ],
      ),
    ];
  }
}