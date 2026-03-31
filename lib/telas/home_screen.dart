// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/disciplinas_section.dart';
import '../widgets/professores_destaque.dart';
import '../database/db_helper.dart';
import '../modelos/disciplina.dart';
import '../modelos/professor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Disciplina> _disciplinas = [];
  List<Professor> _professores = [];
  bool _isLoadingDisciplinas = true;
  bool _isLoadingProfessores = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoadingDisciplinas = true;
      _isLoadingProfessores = true;
    });
    
    final disciplinas = await DBHelper.getAllDisciplinas();
    final professores = await DBHelper.getAllProfessores();
    
    setState(() {
      _disciplinas = disciplinas;
      _professores = professores;
      _isLoadingDisciplinas = false;
      _isLoadingProfessores = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _carregarDados,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCarousel(),
            const SizedBox(height: 32),
            // Widget de Disciplinas
            DisciplinasSectionWidget(
              disciplinas: _disciplinas,
              isLoading: _isLoadingDisciplinas,
              onViewAll: () {
                // Navegar para todas as disciplinas
              },
              onDisciplinaTap: (disciplina) {
                // Mostrar professores por disciplina
                _showProfessoresPorDisciplina(disciplina);
              },
            ),
            const SizedBox(height: 32),
            // Widget de Professores em Destaque
            ProfessoresDestaqueWidget(
              professores: _professores,
              isLoading: _isLoadingProfessores,
              onViewAll: () {
                // Navegar para todos os professores
              },
              onProfessorTap: (professor) {
                _showDetalhesProfessor(professor);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reforço Escolar',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Encontre o professor perfeito para você',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    final carouselItems = [
      _buildCarouselItem(
        '🎓 Aulas Particulares',
        'Aprenda no seu ritmo',
        Colors.orange.shade400,
      ),
      _buildCarouselItem(
        '📚 Todas as Disciplinas',
        'Do fundamental ao vestibular',
        Colors.green.shade400,
      ),
      _buildCarouselItem(
        '💻 Online ou Presencial',
        'Escolha a melhor opção',
        Colors.purple.shade400,
      ),
    ];

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: carouselItems.length,
        itemBuilder: (context, index) => carouselItems[index],
      ),
    );
  }

  Widget _buildCarouselItem(String titulo, String subtitulo, Color cor) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitulo,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfessoresPorDisciplina(Disciplina disciplina) {
    // Implementar navegação para lista de professores da disciplina
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mostrar professores de ${disciplina.nome}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDetalhesProfessor(Professor professor) {
    // Implementar navegação para detalhes do professor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalhes de ${professor.nome}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}