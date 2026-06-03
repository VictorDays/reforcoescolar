import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../models/usuario.dart';
import '../controllers/novidade_controller.dart';
import '../controllers/professor_controller.dart';
import '../controllers/admin_controller.dart';
import '../models/novidade.dart';
import '../widgets/professor_card.dart';
import 'aluno/professor_detalhe_screen.dart';
import 'aluno/notificacoes_screen.dart';
import '../controllers/solicitacao_controller.dart';
import '../controllers/aluno_controller.dart';

class DashboardScreen extends StatefulWidget {
  final Usuario usuario;
  const DashboardScreen({super.key, required this.usuario});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final novidadeCtrl = context.read<NovidadeController>();
      final profCtrl = context.read<ProfessorController>();
      final adminCtrl = context.read<AdminController>();
      novidadeCtrl.carregarAtivas();
      profCtrl.carregarProfessores();
      adminCtrl.carregarDisciplinas();

      if (widget.usuario.isAluno) {
        final alunoCtrl = context.read<AlunoController>();
        final solCtrl = context.read<SolicitacaoController>();
        await alunoCtrl.carregarPerfil(widget.usuario.id);
        final alunoId = alunoCtrl.alunoAtual?['id'];
        if (alunoId != null) solCtrl.carregarDoAluno(alunoId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: RefreshIndicator(
        color: const Color(0xFF5C6BC0),
        onRefresh: () async {
          await context.read<NovidadeController>().carregarAtivas();
          await context.read<ProfessorController>().carregarProfessores();
          await context.read<AdminController>().carregarDisciplinas();
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF5C6BC0),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          widget.usuario.nome.isNotEmpty
                              ? widget.usuario.nome[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, ${widget.usuario.nome.split(' ').first}! 👋',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              widget.usuario.tipoLabel,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (widget.usuario.isAluno)
                        Consumer<SolicitacaoController>(
                          builder: (ctx, solCtrl, _) {
                            final count = solCtrl.solicitacoes
                                .where((s) => s.isAprovada)
                                .length;
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_rounded,
                                      color: Colors.white),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotificacoesScreen(
                                          usuario: widget.usuario),
                                    ),
                                  ),
                                ),
                                if (count > 0)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE53935),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          count > 9 ? '9+' : '$count',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildNovidadesCarousel(),
          const SizedBox(height: 28),
          _buildDisciplinasSection(),
          const SizedBox(height: 28),
          _buildProfessoresRecentes(),
        ],
      ),
    );
  }

  // ─── CARROSSEL NOVIDADES ───────────────────────────────────────────────────
  Widget _buildNovidadesCarousel() {
    return Consumer<NovidadeController>(
      builder: (ctx, ctrl, _) {
        final novidades = ctrl.novidades;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 4, height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Novidades',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (ctrl.isLoading)
              Container(
                height: 150,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (novidades.isEmpty)
              _buildCarouselPlaceholder()
            else
              Column(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 150,
                      autoPlay: novidades.length > 1,
                      autoPlayInterval: const Duration(seconds: 4),
                      enlargeCenterPage: true,
                      viewportFraction: 0.88,
                      onPageChanged: (i, _) => setState(() => _carouselIndex = i),
                    ),
                    items: novidades.map((n) => _buildCarouselItem(n)).toList(),
                  ),
                  if (novidades.length > 1) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(novidades.length, (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _carouselIndex == i ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: _carouselIndex == i
                              ? const Color(0xFF5C6BC0)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )),
                    ),
                  ],
                ],
              ),
          ],
        );
      },
    );
  }

  Widget _buildCarouselItem(Novidade n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [n.cor, n.cor.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: n.cor.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(n.titulo,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(n.descricao,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselPlaceholder() {
    return Container(
      height: 150,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.school_rounded, color: Colors.white, size: 40),
          SizedBox(height: 8),
          Text('Bem-vindo ao Reforço Escolar!',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
      ),
    );
  }

  // ─── DISCIPLINAS ──────────────────────────────────────────────────────────
  Widget _buildDisciplinasSection() {
    return Consumer<AdminController>(
      builder: (ctx, ctrl, _) {
        final disciplinas = ctrl.disciplinas.where((d) => d['ativa'] == true).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 4, height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8F00),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Disciplinas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (ctrl.isLoading)
              const SizedBox(height: 90, child: Center(child: CircularProgressIndicator()))
            else if (disciplinas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Nenhuma disciplina ativa', style: TextStyle(color: Colors.grey.shade500)),
              )
            else
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: disciplinas.length,
                  itemBuilder: (ctx, i) => _buildDisciplinaChip(disciplinas[i]),
                ),
              ),
          ],
        );
      },
    );
  }

  static const List<Color> _disciplinaColors = [
    Color(0xFF5C6BC0), Color(0xFF43A047), Color(0xFFE53935),
    Color(0xFFFF8F00), Color(0xFF00897B), Color(0xFF8E24AA),
    Color(0xFF039BE5), Color(0xFFD81B60),
  ];

  static const List<IconData> _disciplinaIcons = [
    Icons.calculate_rounded, Icons.book_rounded, Icons.science_rounded,
    Icons.biotech_rounded, Icons.history_edu_rounded, Icons.translate_rounded,
    Icons.music_note_rounded, Icons.palette_rounded,
  ];

  Widget _buildDisciplinaChip(Map<String, dynamic> d) {
    final nome = d['nome'] as String;
    final idx = (nome.codeUnits.first) % _disciplinaColors.length;
    final cor = _disciplinaColors[idx];
    final icon = _disciplinaIcons[idx];

    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 82,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              nome,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cor),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── PROFESSORES RECENTES ─────────────────────────────────────────────────
  Widget _buildProfessoresRecentes() {
    return Consumer<ProfessorController>(
      builder: (ctx, ctrl, _) {
        final professores = ctrl.professores.take(5).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Container(
                      width: 4, height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43A047),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Professores Recentes',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (ctrl.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (professores.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('Nenhum professor cadastrado ainda', style: TextStyle(color: Colors.grey.shade500)),
              )
            else
              ...professores.map((p) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ProfessorCard(
                  professorData: p,
                  onTap: widget.usuario.isAluno
                      ? () => Navigator.push(context, MaterialPageRoute(
                            builder: (_) => ProfessorDetalheScreen(
                              professorData: p,
                              usuario: widget.usuario,
                            )))
                      : null,
                ),
              )),
          ],
        );
      },
    );
  }
}
