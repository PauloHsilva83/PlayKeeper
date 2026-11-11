import 'package:flutter/material.dart';

import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SafeArea garante que o layout não fique debaixo da câmera (notch) ou barra inferior
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              // Um espaço flexível para empurrar o conteúdo principal para o centro
              const Spacer(),

              // LOGO DO APP (usando um ícone vetorial do Flutter temporariamente)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_download_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),

              // FRASE DE IMPACTO
              Text(
                "Baixe seus vídeos\nfavoritos",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontSize: 28, height: 1.2),
              ),
              const SizedBox(height: 12),
              Text(
                "Com facilidade, rapidez e sem complicações.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              // Mais espaço flexível para empurrar o botão para o rodapé
              const Spacer(),

              // BOTÃO "COMEÇAR"
              ElevatedButton(
                onPressed: () {
                  // Ao clicar, faz a transição suave para a Tela Principal
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                child: const Text(
                  "Começar",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
