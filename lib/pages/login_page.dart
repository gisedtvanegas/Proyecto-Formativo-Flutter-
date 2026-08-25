import 'package:flutter/material.dart';

import 'widgets/app_background.dart';
import 'widgets/brand_header.dart';

import '../services/auth_service.dart';
import 'mis_reservas_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _hidePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final doc = _documentController.text.trim();
    final pass = _passwordController.text;

    if (doc.isEmpty || pass.isEmpty) {
      setState(() {
        _errorMessage = "Por favor ingrese documento y clave.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Usa LoginResult para obtener error real del backend y nombre del usuario
    final result = await AuthService().login(doc, pass);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MisReservasPage(nombreUsuario: result.nombreUsuario),
        ),
      );
    } else {
      setState(() {
        // Muestra el mensaje exacto del backend (ej: "El documento no existe")
        // o un mensaje genérico si no hubo mensaje específico
        _errorMessage = result.errorMessage ?? "No se pudo iniciar sesión.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      const BrandHeader(title: 'Casa y Jardín'),
                      SizedBox(height: constraints.maxHeight * 0.08),
                      const _WelcomeText(),
                      const SizedBox(height: 24),
                      const _LoginCardTitle(),
                      const SizedBox(height: 18),
                      _LoginCard(
                        hidePassword: _hidePassword,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                        documentController: _documentController,
                        passwordController: _passwordController,
                        onTogglePassword: () {
                          setState(() => _hidePassword = !_hidePassword);
                        },
                        onLogin: _login,
                      ),
                    ],
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

class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Vivero - Café',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF173F5B),
            fontSize: 36,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Inicia sesión para continuar',
          style: TextStyle(
            color: Color(0xFF255D72),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _LoginCardTitle extends StatelessWidget {
  const _LoginCardTitle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      child: const Text(
        'Iniciar Sesión',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF2E3338),
          fontSize: 30,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.hidePassword,
    required this.isLoading,
    required this.errorMessage,
    required this.documentController,
    required this.passwordController,
    required this.onTogglePassword,
    required this.onLogin,
  });

  final bool hidePassword;
  final bool isLoading;
  final String? errorMessage;
  final TextEditingController documentController;
  final TextEditingController passwordController;
  final VoidCallback onTogglePassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
      decoration: BoxDecoration(
        color: const Color(0xFFC8DDED).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9BCB5C).withOpacity(0.32),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            color: Color(0xFF2E3338),
            size: 30,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: documentController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Documento',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            decoration: InputDecoration(
              hintText: 'Clave',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: hidePassword ? 'Mostrar clave' : 'Ocultar clave',
                onPressed: onTogglePassword,
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              onPressed: isLoading ? null : onLogin,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF5F72A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Iniciar Sesión',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: isLoading ? null : () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF255D72),
                side: BorderSide(color: Colors.white.withOpacity(0.8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Registrarse',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
