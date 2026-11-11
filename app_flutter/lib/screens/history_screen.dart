import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // Lista real que virá do banco de dados
  List<Map<String, String>> _downloadHistory = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  // Função que busca os dados gravados no celular
  Future<void> _carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final listaSalva = prefs.getStringList('playkeeper_history') ?? [];

    // Transforma a lista de textos (JSON) de volta em Mapa
    setState(() {
      _downloadHistory = listaSalva.map((item) {
        final mapa = jsonDecode(item) as Map<String, dynamic>;
        return {
          "title": mapa["title"].toString(),
          "url": mapa["url"].toString(),
          "date": mapa["date"].toString(),
        };
      }).toList();
      _carregando = false;
    });
  }

  // Função que apaga de verdade do banco de dados
  Future<void> _confirmarExclusao(int index) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Remover do histórico?"),
          content: const Text(
            "Deseja realmente remover este link? O arquivo baixado continuará no seu celular, mas o link sumirá daqui.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                // 1. Remove da tela
                setState(() {
                  _downloadHistory.removeAt(index);
                });
                Navigator.pop(context);

                // 2. Remove do Banco de Dados
                final prefs = await SharedPreferences.getInstance();
                final listaSalva =
                    prefs.getStringList('playkeeper_history') ?? [];
                listaSalva.removeAt(index); // Remove a mesma posição
                await prefs.setStringList('playkeeper_history', listaSalva);

                // 3. Aviso visual
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Link removido do histórico."),
                      backgroundColor: Colors.black87,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const Text(
                "Sim, remover",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Histórico de Downloads",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _downloadHistory.isEmpty
          ? const Center(
              child: Text(
                "Seu histórico está vazio.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : SafeArea(
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _downloadHistory.length,
                  itemBuilder: (context, index) {
                    final item = _downloadHistory[index];
                    return Card(
                      elevation: 0,
                      color: Colors.black.withOpacity(0.02),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, color: Colors.green),
                        ),
                        title: Text(
                          item["title"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          "${item["url"]!}\nBaixado em: ${item["date"]!}",
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => _confirmarExclusao(index),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
