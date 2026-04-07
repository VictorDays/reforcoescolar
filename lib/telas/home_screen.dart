
import 'package:flutter/material.dart';
import 'package:reforcoescolar/telas/login_screen.dart';
import '../widgets/disciplinas_section.dart';
import '../widgets/custom_carousel.dart'; 
import '../widgets/professores_destaque.dart';
import '../widgets/professor_card.dart';
import '../database/db_helper.dart';
import '../modelos/disciplina.dart';
import '../modelos/professor.dart';
import '../modelos/usuario.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  final Usuario usuario;

  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Disciplina> _disciplinas = [];
  List<Professor> _professores = [];
  Set<int> _favoritos = {};
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
    
    if (widget.usuario.tipo == TipoUsuario.aluno) {
      final favoritosList = await DBHelper.getFavoritosByUsuario(widget.usuario.id!);
      setState(() {
        _favoritos = favoritosList.map((p) => p.id!).toSet();
      });
    }
    
    setState(() {
      _disciplinas = disciplinas;
      _professores = professores;
      _isLoadingDisciplinas = false;
      _isLoadingProfessores = false;
    });
  }

  Future<void> _toggleFavorito(Professor professor) async {
    if (widget.usuario.tipo != TipoUsuario.aluno) return;
    
    final isFav = _favoritos.contains(professor.id);
    
    if (isFav) {
      await DBHelper.removeFavorito(widget.usuario.id!, professor.id!);
      setState(() {
        _favoritos.remove(professor.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${professor.nome} removido dos favoritos'), backgroundColor: Colors.orange),
      );
    } else {
      await DBHelper.addFavorito(widget.usuario.id!, professor.id!);
      setState(() {
        _favoritos.add(professor.id!);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${professor.nome} adicionado aos favoritos'), backgroundColor: Colors.green),
      );
    }
  }

  Future<void> _logout() async {
    await DBHelper.logout(widget.usuario.id!);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reforço Escolar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: RefreshIndicator(
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
              DisciplinasSectionWidget(
                disciplinas: _disciplinas,
                isLoading: _isLoadingDisciplinas,
                onViewAll: () {},
                onDisciplinaTap: (disciplina) {
                  _showProfessoresPorDisciplina(disciplina);
                },
              ),
              const SizedBox(height: 32),
              _buildProfessoresSection(),
              const SizedBox(height: 24),
            ],
          ),
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
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Olá, ${widget.usuario.nome}!',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 4),
          Text(
            widget.usuario.tipo == TipoUsuario.admin ? 'Modo Administrador' : 'Encontre o professor perfeito para você',
            style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

Widget _buildCarousel() {
  final carouselItems = [
    CarouselItem(
      title: '🎓 Aulas Particulares',
      subtitle: 'Aprenda no seu ritmo com professores qualificados',
      color: Colors.orange.shade400,
      icon: Icons.school,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aulas particulares'), duration: Duration(seconds: 1)),
        );
      },
    ),
    CarouselItem(
      title: '📚 Todas as Disciplinas',
      subtitle: 'Do fundamental ao vestibular, temos o professor ideal',
      color: Colors.green.shade400,
      icon: Icons.menu_book,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todas as disciplinas'), duration: Duration(seconds: 1)),
        );
      },
    ),
    CarouselItem(
      title: '💻 Online ou Presencial',
      subtitle: 'Escolha a modalidade que melhor se adapta à sua rotina',
      color: Colors.purple.shade400,
      icon: Icons.videocam,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Online ou presencial'), duration: Duration(seconds: 1)),
        );
      },
    ),
    CarouselItem(
      title: '⭐ Professores Avaliados',
      subtitle: 'Mais de 1000 professores disponíveis',
      color: Colors.blue.shade400,
      icon: Icons.star,
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Professores avaliados'), duration: Duration(seconds: 1)),
        );
      },
    ),
  ];

  return CustomCarousel(
    items: carouselItems,
    height: 140,
    autoPlayInterval: const Duration(seconds: 3),
  );
}


  Widget _buildProfessoresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Professores em Destaque', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        if (_isLoadingProfessores)
          const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
        else if (_professores.isEmpty)
          const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Nenhum professor cadastrado')))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _professores.length > 3 ? 3 : _professores.length,
            itemBuilder: (context, index) {
              final professor = _professores[index];
              final isFavorito = _favoritos.contains(professor.id);
              return ProfessorCard(
                professor: professor,
                isFavorito: isFavorito,
                onTap: () => _showDetalhesProfessor(professor),
                onFavoritoTap: widget.usuario.tipo == TipoUsuario.aluno ? () => _toggleFavorito(professor) : null,
              );
            },
          ),
      ],
    );
  }

  void _showProfessoresPorDisciplina(Disciplina disciplina) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mostrar professores de ${disciplina.nome}'), duration: const Duration(seconds: 2)),
    );
  }

  void _showDetalhesProfessor(Professor professor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Detalhes de ${professor.nome}'), duration: const Duration(seconds: 2)),
    );
  }
}