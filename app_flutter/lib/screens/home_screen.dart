import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_modal.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PlayKeeper",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (context) => const SettingsModal(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Guarde suas mídias",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Cole os links abaixo para salvar no seu dispositivo.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 32),

              DownloadInputWidget(
                hintText: "Cole o link (Baixar Vídeo)",
                isAudio: false,
              ),
              SizedBox(height: 24),
              DownloadInputWidget(
                hintText: "Cole o link (Baixar Áudio)",
                isAudio: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DownloadInputWidget extends StatefulWidget {
  final String hintText;
  final bool isAudio;

  const DownloadInputWidget({
    super.key,
    this.hintText = "Insira a URL aqui...",
    required this.isAudio,
  });

  @override
  State<DownloadInputWidget> createState() => _DownloadInputWidgetState();
}

class _DownloadInputWidgetState extends State<DownloadInputWidget> {
  int _downloadState = 0;
  double _progress = 0.0;
  String _statusText = "";

  final TextEditingController _controller = TextEditingController();
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _controller.dispose();
    _cancelToken?.cancel();
    super.dispose();
  }

  void _iniciarDownload() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _downloadState = 1;
      _progress = 0.0;
      _statusText = "Conectando ao servidor...";
    });

    _cancelToken = CancelToken();

    try {
      final url = Uri.parse('http:// 192.168.0.38:8000/api/extract');
      final tipoMidia = widget.isAudio ? "audio" : "video";

      final resposta = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"url": _controller.text, "media_type": tipoMidia}),
      );

      if (resposta.statusCode != 200) throw Exception("Link não suportado.");

      final dados = jsonDecode(resposta.body);

      // BLINDAGEM CONTRA NULOS: Se vier vazio, coloca um nome padrão
      final rawUrl = dados['url_direta']?.toString() ?? "";
      final rawTitle = dados['titulo']?.toString() ?? "Video_PlayKeeper";

      if (rawUrl.isEmpty) {
        throw Exception("O servidor não retornou um link de download válido.");
      }

      final tituloLimpo = rawTitle
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .trim()
          .replaceAll(' ', '_');
      final extensao = tipoMidia == "video" ? ".mp4" : ".m4a";

      final tempDir = await getTemporaryDirectory();
      final arquivoFinalPath = '${tempDir.path}/$tituloLimpo$extensao';

      final temAcesso = await Gal.requestAccess();
      if (!temAcesso) throw Exception("Permissão da Galeria negada!");

      setState(() => _statusText = "Baixando: $tituloLimpo");

      final dio = Dio();
      await dio.download(
        rawUrl,
        arquivoFinalPath,
        cancelToken: _cancelToken,
        onReceiveProgress: (recebido, total) {
          if (total != -1) {
            setState(() => _progress = recebido / total);
          }
        },
      );

      setState(() => _statusText = "Salvando na Galeria...");

      if (tipoMidia == "video") {
        await Gal.putVideo(arquivoFinalPath);
      } else {
        if (Platform.isAndroid) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            await File(arquivoFinalPath)
                .copy('${downloadDir.path}/$tituloLimpo$extensao');
          }
        }
      }

      // SALVANDO NO BANCO DE DADOS (HISTÓRICO REAL)
      final prefs = await SharedPreferences.getInstance();
      List<String> historicoSalvo =
          prefs.getStringList('playkeeper_history') ?? [];

      final hoje =
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}";
      final novoItem = jsonEncode({
        "title": tituloLimpo,
        "url": _controller.text,
        "date": hoje,
      });

      historicoSalvo.insert(0, novoItem);
      await prefs.setStringList('playkeeper_history', historicoSalvo);

      setState(() {
        _downloadState = 2;
        _statusText = "Download Concluído!";
      });
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        _mostrarAviso("Download cancelado.");
      } else {
        _mostrarAviso("Erro: $e", isError: true);
      }
      setState(() => _downloadState = 0);
    } finally {
      if (_downloadState == 2) {
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _downloadState = 0;
            _progress = 0.0;
            _controller.clear();
          });
        }
      }
    }
  }

  void _cancelarDownload() {
    _cancelToken?.cancel("Cancelado pelo usuário");
    setState(() => _downloadState = 0);
  }

  void _mostrarAviso(String mensagem, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: isError ? Colors.red : Colors.black87,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            widget.isAudio
                ? Icons.audiotrack_rounded
                : Icons.video_library_rounded,
            color: Colors.grey,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: _downloadState != 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _statusText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _downloadState == 2
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: _downloadState == 2
                              ? 1.0
                              : (_progress > 0 ? _progress : null),
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _downloadState == 2
                                ? Colors.green
                                : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  )
                : TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      hintStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          _construirBotaoAcao(),
        ],
      ),
    );
  }

  Widget _construirBotaoAcao() {
    if (_downloadState == 1) {
      return IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.redAccent),
        onPressed: _cancelarDownload,
      );
    } else if (_downloadState == 2) {
      return const IconButton(
        icon: Icon(Icons.check_circle_rounded, color: Colors.green),
        onPressed: null,
      );
    } else {
      return IconButton(
        icon: Icon(
          Icons.download_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPressed: _iniciarDownload,
      );
    }
  }
}
