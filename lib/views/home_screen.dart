import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reforcoescolar/models/solicitacao.dart';
import '../controllers/auth_controller.dart';
import '../controllers/agendamento_controller.dart';
import '../models/usuario.dart';
import '../models/aula.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;

  const HomeScreen({
    super.key,
    required this.usuario,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final agendamentoController = context.read<AgendamentoController>();
    
    if (widget.usuario.tipo == TipoUsuario.aluno) {
      await agendamentoController.carregarProximasAulas(
        widget.usuario.id,
        'aluno',
      );
    } else if (widget.usuario.tipo == TipoUsuario.professor) {
      await agendamentoController.carregarProximasAulas(
        widget.usuario.id,
        'professor',
      );
      await agendamentoController.carregarSolicitacoesPendentes(
        widget.usuario.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AgendamentoController()),
      ],
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: _carregarDados,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Olá, ${widget.usuario.nome.split(' ').first}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  centerTitle: true,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade700,
                          Colors.blue.shade300,
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.school,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Conteúdo
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: Consumer<AgendamentoController>(
                  builder: (context, agendamentoController, child) {
                    if (agendamentoController.isLoading) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                    
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        // Card de boas-vindas
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.blue.shade100,
                                      child: Icon(
                                        widget.usuario.tipo == TipoUsuario.aluno
                                            ? Icons.person
                                            : Icons.school,
                                        size: 30,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.usuario.nome,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            widget.usuario.tipo == TipoUsuario.aluno
                                                ? 'Aluno'
                                                : widget.usuario.tipo == TipoUsuario.professor
                                                    ? 'Professor'
                                                    : 'Administrador',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
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
                        
                        // Próximas Aulas
                        _buildProximasAulas(agendamentoController),
                        
                        const SizedBox(height: 16),
                        
                        // Solicitações Pendentes (apenas professor)
                        if (widget.usuario.tipo == TipoUsuario.professor)
                          _buildSolicitacoesPendentes(agendamentoController),
                      ]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProximasAulas(AgendamentoController controller) {
    final aulas = controller.aulas;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Próximas Aulas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (aulas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('Nenhuma aula agendada'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aulas.length > 5 ? 5 : aulas.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final aula = aulas[index];
                  return _buildAulaTile(aula);
                },
              ),
            if (aulas.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    // TODO: Navegar para tela de todas as aulas
                  },
                  child: Text('Ver todas (${aulas.length})'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAulaTile(Aula aula) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: aula.status.color.withOpacity(0.2),
        child: Icon(
          Icons.school,
          color: aula.status.color,
          size: 20,
        ),
      ),
      title: Text(
        widget.usuario.tipo == TipoUsuario.aluno
            ? 'Aula com Professor'
            : 'Aula com Aluno',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${aula.dataFormatada} • ${aula.horarioFormatado}h',
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: aula.status.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          aula.status.displayName,
          style: TextStyle(
            color: aula.status.color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitacoesPendentes(AgendamentoController controller) {
    final pendentes = controller.solicitacoes
        .where((s) => s.status == SolicitacaoStatus.pendente)
        .toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Solicitações Pendentes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (pendentes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('Nenhuma solicitação pendente'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendentes.length > 3 ? 3 : pendentes.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final solicitacao = pendentes[index];
                  return ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person_add, size: 20),
                    ),
                    title: const Text('Nova solicitação de aula'),
                    subtitle: Text(
                      'Clique para ver detalhes',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Pendente',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      // TODO: Navegar para tela de detalhe da solicitação
                    },
                  );
                },
              ),
            if (pendentes.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () {
                    // TODO: Navegar para tela de todas solicitações
                  },
                  child: Text('Ver todas (${pendentes.length})'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}