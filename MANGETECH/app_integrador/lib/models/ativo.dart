class Ativo {
  final int id;
  final String codigo;
  final String nome;
  final String modelo;
  final String? fabricante;
  final String? numeroSerie;
  final String? fornecedor;
  final String ambiente;
  final String status;
  final DateTime dataCadastro;
  final DateTime dataAtualizacao;
  final List<AtivoHistorico> historicoMovimentacoes;
  final int totalChamados;
  final int chamadosAbertos;
  final UltimoChamado? ultimoChamado;

  Ativo({
    required this.id,
    required this.codigo,
    required this.nome,
    required this.modelo,
    this.fabricante,
    this.numeroSerie,
    this.fornecedor,
    required this.ambiente,
    required this.status,
    required this.dataCadastro,
    required this.dataAtualizacao,
    this.historicoMovimentacoes = const [],
    this.totalChamados = 0,
    this.chamadosAbertos = 0,
    this.ultimoChamado,
  });

  factory Ativo.fromJson(Map<String, dynamic> json) {
    return Ativo(
      id: json['id'] ?? 0,
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? '',
      modelo: json['modelo'] ?? '',
      fabricante: json['fabricante'],
      numeroSerie: json['numero_serie'],
      fornecedor: json['fornecedor'],
      ambiente: json['ambiente'] ?? '',
      status: json['status'] ?? '',
      dataCadastro: DateTime.parse(json['data_cadastro']),
      dataAtualizacao: DateTime.parse(json['data_atualizacao']),
      historicoMovimentacoes: (json['historico_movimentacoes'] as List?)
              ?.map((h) => AtivoHistorico.fromJson(h))
              .toList() ??
          [],
      totalChamados: json['total_chamados'] ?? 0,
      chamadosAbertos: json['chamados_abertos'] ?? 0,
      ultimoChamado: json['ultimo_chamado'] != null
          ? UltimoChamado.fromJson(json['ultimo_chamado'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nome': nome,
      'modelo': modelo,
      'fabricante': fabricante,
      'numero_serie': numeroSerie,
      'fornecedor': fornecedor,
      'ambiente': ambiente,
      'status': status,
    };
  }
}

class AtivoHistorico {
  final int id;
  final String tipo;
  final String descricao;
  final String? usuarioNome;
  final DateTime dataCriacao;

  AtivoHistorico({
    required this.id,
    required this.tipo,
    required this.descricao,
    this.usuarioNome,
    required this.dataCriacao,
  });

  factory AtivoHistorico.fromJson(Map<String, dynamic> json) {
    return AtivoHistorico(
      id: json['id'] ?? 0,
      tipo: json['tipo'] ?? '',
      descricao: json['descricao'] ?? '',
      usuarioNome: json['usuario_nome'],
      dataCriacao: DateTime.parse(json['data_criacao']),
    );
  }
}

class UltimoChamado {
  final int id;
  final String titulo;
  final String status;
  final String data;

  UltimoChamado({
    required this.id,
    required this.titulo,
    required this.status,
    required this.data,
  });

  factory UltimoChamado.fromJson(Map<String, dynamic> json) {
    return UltimoChamado(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      status: json['status'] ?? '',
      data: json['data'] ?? '',
    );
  }
}