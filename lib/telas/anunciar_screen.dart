import 'package:flutter/material.dart';
import 'disciplinas_screen.dart';
import 'cadastro_professor_screen.dart';

class AnunciarScreen extends StatelessWidget {
  const AnunciarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Área do Professor")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _cardMenu(context, "Disciplinas", Icons.book, Colors.orange, const DisciplinasScreen()),
            const SizedBox(height: 20),
            _cardMenu(context, "Meus Anúncios", Icons.person_add, Colors.blue, const CadastroProfessorScreen()),
          ],
        ),
      ),
    );
  }

  Widget _cardMenu(BuildContext context, String title, IconData icon, Color color, Widget page) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Card(
        child: ListTile(
          leading: Icon(icon, color: color, size: 40),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: const Icon(Icons.arrow_forward),
        ),
      ),
    );
  }
}