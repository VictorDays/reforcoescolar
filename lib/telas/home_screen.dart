import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de imagens para o carrossel (pode usar URLs ou assets)
    final List<String> imagensDestaque = [
      'https://via.placeholder.com/800x400.png?text=Melhore+suas+Notas',
      'https://via.placeholder.com/800x400.png?text=Professores+Especializados',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reforço Escolar", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // REQUISITO: Carrossel de Imagens
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: CarouselSlider(
                options: CarouselOptions(height: 180.0, autoPlay: true, enlargeCenterPage: true),
                items: imagensDestaque.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(url, fit: BoxFit.cover, width: 1000),
                  );
                }).toList(),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Categorias", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            // Grid de Disciplinas (Exemplo rápido)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _cardCategoria("Matemática", Icons.calculate, Colors.blue),
                _cardCategoria("Português", Icons.book, Colors.orange),
                _cardCategoria("Física", Icons.biotech, Colors.purple),
                _cardCategoria("Química", Icons.science, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardCategoria(String titulo, IconData icone, Color cor) {
    return Container(
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: cor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icone, size: 40, color: cor),
          const SizedBox(height: 8),
          Text(titulo, style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}