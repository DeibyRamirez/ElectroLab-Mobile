// ignore_for_file: file_names, deprecated_member_use

import 'dart:ui';
import 'package:flutter/material.dart';

class BlurContent extends StatefulWidget {
  final Widget child;
  final int cost;
  final int userCredits;

  /// Acción externa (Firebase, Firestore, etc.)
  final Future<void> Function() onUnlock;

  const BlurContent({
    super.key,
    required this.child,
    required this.userCredits,
    required this.onUnlock,
    this.cost = 5,
  });

  @override
  State<BlurContent> createState() => _BlurContentState();
}

class _BlurContentState extends State<BlurContent> {
  bool _isUnlocked = false;
  bool _isProcessing = false;

  Future<void> _handleUnlock() async {
    if (_isProcessing) return;

    if (widget.userCredits < widget.cost) {
      _mostrarError();
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await widget.onUnlock();

      setState(() {
        _isUnlocked = true; // 🔓 AQUÍ SE DESBLOQUEA
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });

      debugPrint('Error al desbloquear: $e');
    }
  }

  void _mostrarError() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Créditos insuficientes'),
        content: Text(
          'Necesitas ${widget.cost} créditos.\n'
          'Disponibles: ${widget.userCredits}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool locked = !_isUnlocked;

    return Stack(
      alignment: Alignment.center,
      children: [
        // ========= CONTENIDO =========
        ImageFiltered(
          imageFilter: locked
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Opacity(
            opacity: locked ? 0.5 : 1,
            child: IgnorePointer(
              ignoring: locked,
              child: widget.child,
            ),
          ),
        ),

        // ========= OVERLAY =========
        if (locked)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(20),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 56, color: Colors.blue),
                        const SizedBox(height: 16),
                        const Text(
                          'Contenido Bloqueado',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Desbloquea los resultados completos',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          '${widget.cost} créditos',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Disponibles: ${widget.userCredits}',
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.userCredits >= widget.cost
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),

                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isProcessing ? null : _handleUnlock,
                            icon: _isProcessing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.lock_open),
                            label: Text(
                              _isProcessing
                                  ? 'Procesando...'
                                  : 'Desbloquear Ahora',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
