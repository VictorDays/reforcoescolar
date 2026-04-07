
import 'package:flutter/material.dart';
import '../modelos/professor.dart';
import '../modelos/disciplina.dart';
import 'image_picker_widget.dart';

class ProfessorForm extends StatefulWidget {
  final Professor? professor;
  final List<Disciplina> disciplinas;

  const ProfessorForm({
    super.key,
    this.professor,
    required this.disciplinas,
  });

  @override
  State<ProfessorForm> createState() => _ProfessorFormState();
}

class _ProfessorFormState extends State<ProfessorForm> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _contatoController = TextEditingController();
  
  String? _disciplinaSelecionada;
  String? _fotoPath;

  @override
  void initState() {
    super.initState();
    if (widget.professor != null) {
      _nomeController.text = widget.professor!.nome;
      _disciplinaSelecionada = widget.professor!.disciplina;
      _valorController.text = widget.professor!.valor.toString();
      _descricaoController.text = widget.professor!.descricao;
      _contatoController.text = widget.professor!.contato;
      _fotoPath = widget.professor!.foto;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _valorController.dispose();
    _descricaoController.dispose();
    _contatoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.professor == null ? 'Adicionar Professor' : 'Editar Professor',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seletor de foto
              ImagePickerWidget(
                currentImagePath: _fotoPath,
                onImageSelected: (path) {
                  setState(() {
                    _fotoPath = path;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o nome do professor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Disciplina
              DropdownButtonFormField<String>(
                value: _disciplinaSelecionada,
                decoration: const InputDecoration(
                  labelText: 'Disciplina *',
                  border: OutlineInputBorder(),
                ),
                items: widget.disciplinas.map((disciplina) {
                  return DropdownMenuItem(
                    value: disciplina.nome,
                    child: Text(disciplina.nome),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _disciplinaSelecionada = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma disciplina';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Valor
              TextFormField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor por hora (RS) *',
                  border: OutlineInputBorder(),
                  prefixText: 'R\$ ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o valor por hora';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Informe um valor válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Contato
              TextFormField(
                controller: _contatoController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'WhatsApp / Telefone *',
                  border: OutlineInputBorder(),
                  hintText: '(11) 99999-9999',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe um telefone para contato';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              
              // Descrição
              TextFormField(
                controller: _descricaoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                  hintText: 'Conte sobre experiências, metodologia...',
                ),
              ),
            ],
          ),
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
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final professor = Professor(
        id: widget.professor?.id,
        nome: _nomeController.text.trim(),
        disciplina: _disciplinaSelecionada!,
        valor: double.parse(_valorController.text),
        descricao: _descricaoController.text,
        contato: _contatoController.text,
        foto: _fotoPath,
        ativo: widget.professor?.ativo ?? true,
      );
      Navigator.pop(context, professor);
    }
  }
}