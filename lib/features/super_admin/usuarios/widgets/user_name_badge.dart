import 'package:flutter/material.dart';
import 'package:aiesec_lar_global/core/theme/app_colors.dart';
import 'package:aiesec_lar_global/data/models/usuario/usuario.dart';

class UserNameBadge extends StatelessWidget {
  final Usuario usuario;
  final String? currentUserId;

  const UserNameBadge({
    super.key,
    required this.usuario,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMe = usuario.uid == currentUserId;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            usuario.nome,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isMe)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Text(
              "VOCÊ",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );
  }
}
