import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';

/// Função global para exibir o Bottom Sheet padronizado do App
void showCustomFormSheet({
  required BuildContext context,
  required String title,
  required Widget child,
  required VoidCallback onSave,
  String labelButton = "Salvar Alterações",
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Permite ocupar altura total se necessário
    useSafeArea: true,
    backgroundColor: Colors.white, // <--- GARANTE O FUNDO BRANCO
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      // Padding para lidar com o teclado
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          // Garante fundo branco também no container interno
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          // Limita a altura para não ocupar 100% da tela desnecessariamente
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Barra de arraste (Handle)
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 2. Cabeçalho
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 16, 16), // Ajustei padding direito
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // --- CORREÇÃO DO ERRO DE ESPAÇO ---
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary, // Certifique-se que essa cor existe ou use Colors.black87
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis, // Corta com "..." se for muito grande
                      ),
                    ),
                    const SizedBox(width: 8), // Espaço entre texto e botão
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      // Opcional: Aumentar área de toque
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // 3. Formulário Scrollável
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: child,
                ),
              ),

              // 4. Botão de Salvar Fixo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                child: ElevatedButton(
                  onPressed: onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    labelButton,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}