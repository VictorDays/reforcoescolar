import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'repositories/usuario_repository.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _status = 'Testando conexão...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _testarConexao();
  }

  Future<void> _testarConexao() async {
    try {
      // Teste 1: Verificar se cliente existe
      final client = SupabaseConfig.client;
      setState(() {
        _status = '✅ Cliente Supabase OK\n';
      });

      // Teste 2: Tentar ler tabela usuarios
      final response = await client
          .from(SupabaseConfig.tableUsuarios)
          .select()
          .limit(1);
      
      setState(() {
        _status += '✅ Conexão com banco OK\n';
        _status += '📊 Tabela usuarios acessível\n';
      });

      // Teste 3: Verificar buckets
      final buckets = await client.storage.listBuckets();
      final bucketNames = buckets.map((b) => b.name).toList();
      
      setState(() {
        _status += '📦 Buckets disponíveis: ${bucketNames.join(', ')}\n';
      });

      if (bucketNames.contains(SupabaseConfig.bucketAvatars)) {
        _status += '✅ Bucket avatars OK\n';
      } else {
        _status += '⚠️ Bucket avatars não encontrado\n';
      }

      if (bucketNames.contains(SupabaseConfig.bucketAulas)) {
        _status += '✅ Bucket aulas OK\n';
      } else {
        _status += '⚠️ Bucket aulas não encontrado\n';
      }

      _status += '\n🎉 Tudo funcionando! Pode prosseguir.';
      
    } catch (e) {
      setState(() {
        _status = '❌ ERRO: $e\n\nVerifique:\n- URL e chaves corretas\n- Tabelas criadas\n- Buckets criados';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste Supabase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_loading) const CircularProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _status,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}