import 'package:flutter/material.dart';
import 'widgets/custom_carousel.dart';
import 'widgets/custom_footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key}); // constructor const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFFBCD4E5), // azul claro
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      // 🔹 Logo + nombre
      Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 40,
          ),
          const SizedBox(width: 8),
          const Text(
            "Casa y Jardín",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Color(0xDD143E5E),
            ),
          ),
        ],
      ),

      // 🔹 Menú de navegación
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Navegar a Inicio
                  },
                  child: const Text("Inicio"),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a Historia
                  },
                  child: const Text("Historia"),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a Actividad
                  },
                  child: const Text("Actividad"),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a Reservas
                  },
                  child: const Text("Reservas"),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a Menú
                  },
                  child: const Text("Menú"),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a Iniciar Sesión
                  },
                  child: const Text("Iniciar Sesión"),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CustomCarousel(), // Carrusel
            const SizedBox(height: 20),

            // 🔹 Sección Historia
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFC5E1A5), // verde claro
                ),
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Historia",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xDD143E5E),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Crecimos con la idea de poder enseñarle a las personas un poco de arte, "
                      "pero también teniendo un rato agradable con familiares y amigos. "
                      "Inicialmente trabajamos con kokedamas, realizando pequeños talleres para "
                      "personas interesadas, luego decidimos implementar nuevos talleres por "
                      "recomendación de nuestros clientes. A partir de ahí tenemos cerámicas "
                      "para pintar de forma libre, tote bags, materas, terrarios con una zona "
                      "especial para que cada cliente tenga una experiencia única.",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xDD143E5E),
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const CustomFooter(), // Footer
          ],
        ),
      ),
    );
  }
}
