import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/styles.dart';
import 'login_custom.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: _introKey,
      pages: [
        PageViewModel(
          title: "¡Bienvenido a Hábitos Diarios! 👋",
          body: "Construye mejores hábitos y alcanza tus metas un día a la vez. ¡Rastrea tu progreso y celebra tus logros!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Crea tus Hábitos 📝",
          body: "Añade hábitos personalizados con diferentes tipos: casillas simples, cantidades o seguimiento de duración. ¡Configura recordatorios y frecuencias!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Rastrea tu Progreso 📊",
          body: "Visualiza tus rachas, consulta estadísticas y monitorea tu mejora con el tiempo con hermosos gráficos e información.",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Gana Recompensas 🎁",
          body: "¡Completa hábitos para ganar monedas! Canjéalas por recompensas reales. ¡Cuanto más consistente seas, más ganarás!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Únete a Retos 🏆",
          body: "Compite con amigos, únete a retos de la comunidad y escala en las clasificaciones. ¡Mantente motivado junto a otros!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Comienza tu Viaje ✨",
          body: "Puedes comenzar a usar la app de inmediato, o iniciar sesión para sincronizar tus datos entre dispositivos. ¡Construyamos mejores hábitos!",
          image: _buildImage('assets/images/icon.png'),
          decoration: _getPageDecoration(),
          footer: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => _onFinish(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarys,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Comenzar', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => _onSkip(context),
                  child: const Text('Saltar Tutorial'),
                ),
              ],
            ),
          ),
        ),
      ],
      onDone: () => _onFinish(context),
      onSkip: () => _onSkip(context),
      showSkipButton: true,
      skip: const Text('Saltar', style: TextStyle(fontWeight: FontWeight.w600)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Listo', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: AppColors.primarys,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Widget _buildImage(String assetName) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Image.asset(
        assetName,
        width: 200,
        height: 200,
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.bold,
      ),
      bodyTextStyle: const TextStyle(fontSize: 18.0),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Colors.white,
      imagePadding: const EdgeInsets.only(top: 40),
    );
  }

  Future<void> _onFinish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginCustomScreen()),
    );
  }

  Future<void> _onSkip(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginCustomScreen()),
    );
  }
}
