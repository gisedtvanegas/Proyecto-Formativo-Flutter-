import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CustomCarousel extends StatelessWidget {
  const CustomCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.8,
        autoPlay: true,
        viewportFraction: 1.0,
      ),
      items: [
        'assets/images/prueba.jpg',
        'assets/images/foto.jpg',
        'assets/images/fotoprueba.jpg',
        'assets/images/prueba.prueba.jpg',
      ].map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Stack(
              children: [
                Image.asset(
                  i,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Positioned(
                  bottom: 50,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "¡Bienvenidos!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Conoce nuestras",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Aquí puedes navegar a otra página
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF84b9df),
                        ),
                        child: const Text("Actividades"),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }
}
