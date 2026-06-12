import 'package:flutter/material.dart';

class CustomFooter extends StatelessWidget {
  const CustomFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFBCD4E5),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            "Casa y Jardín - Vivero Café",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xDD143E5E),
            ),
          ),
          SizedBox(height: 8),
          Text("Dirección: Calle 123 #45-67, Bogotá"),
          Text("Teléfono: +57 300 123 4567"),
          Text("Email: contacto@casayjardin.com"),
          SizedBox(height: 10),
          Divider(color: Colors.white),
          SizedBox(height: 10),
          Text("Facebook | Instagram | WhatsApp"),
          SizedBox(height: 10),
          Text(
            "© 2025 Casa y Jardín - Vivero Café. Todos los derechos reservados.",
            style: TextStyle(
              fontSize: 12,
              color: Color(0xDD143E5E),
            ),
          ),
        ],
      ),
    );
  }
}
