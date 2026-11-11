import 'package:flutter/material.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  // Valores iniciais (Padrões do PlayKeeper)
  String _videoQuality = '1080p';
  String _audioFormat = 'MP3';
  String _audioQuality = '320 kbps';

  @override
  Widget build(BuildContext context) {
    // SafeArea garante que não fique por baixo da barrinha de navegação do iPhone/Android
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Faz o modal ocupar apenas o espaço necessário
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aquela "pílula" cinza no topo indicando que pode deslizar para baixo
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Preferências de Download",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // --- SEÇÃO DE VÍDEO ---
            Row(
              children: const [
                Icon(Icons.video_library_rounded, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "VÍDEO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: "Qualidade",
                    value: _videoQuality,
                    items: ['1080p', '720p', '480p'],
                    onChanged: (val) => setState(() => _videoQuality = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: "Formato",
                    value: 'MP4', // Fixo
                    items: ['MP4'],
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- SEÇÃO DE ÁUDIO ---
            Row(
              children: const [
                Icon(Icons.audiotrack_rounded, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  "ÁUDIO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDropdown(
                    label: "Qualidade",
                    value: _audioQuality,
                    items: [
                      '320 kbps',
                      '256 kbps',
                      '192 kbps',
                      '128 kbps',
                      '96 kbps',
                    ],
                    onChanged: (val) => setState(() => _audioQuality = val!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: "Formato",
                    value: _audioFormat,
                    items: ['MP3', 'AAC', 'OGG'],
                    onChanged: (val) => setState(() => _audioFormat = val!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Botão de Confirmar
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Fecha o modal
              },
              child: const Text("Salvar Preferências"),
            ),
          ],
        ),
      ),
    );
  }

  // Componente visual reutilizável para os Menus de Seleção (Dropdowns)
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: items.map((String item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
