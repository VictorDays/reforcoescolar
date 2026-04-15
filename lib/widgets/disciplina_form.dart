import 'package:flutter/material.dart';
import '../modelos/disciplina.dart';

class DisciplinaForm extends StatefulWidget {
  final Disciplina? disciplina;

  const DisciplinaForm({super.key, this.disciplina});

  @override
  State<DisciplinaForm> createState() => _DisciplinaFormState();
}

class _DisciplinaFormState extends State<DisciplinaForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.disciplina != null) {
      _nomeController.text = widget.disciplina!.nome;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.disciplina == null ? 'Adicionar Disciplina' : 'Editar Disciplina',
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nomeController,
          decoration: const InputDecoration(
            labelText: 'Nome da Disciplina',
            border: OutlineInputBorder(),
            hintText: 'Ex: Matemática',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Por favor, informe o nome da disciplina';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _salvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final disciplina = Disciplina(
        id: widget.disciplina?.id,
        nome: _nomeController.text.trim(),
      );
      Navigator.pop(context, disciplina);
    }
  }
}