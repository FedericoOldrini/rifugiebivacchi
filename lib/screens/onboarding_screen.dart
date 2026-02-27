import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isRequestingPermission = false;

  String _resolveAuthError(BuildContext context, String errorCode) {
    final l10n = AppLocalizations.of(context)!;
    if (errorCode.startsWith('google_login_error:') ||
        errorCode.startsWith('apple_login_error:')) {
      return l10n.errorLoginGeneric;
    }
    return l10n.error;
  }

  List<OnboardingPage> _getPages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingPage(
        title: l10n.onboardingWelcomeTitle,
        description: l10n.onboardingWelcomeDesc,
        icon: Icons.hiking,
        color: Color(0xFF2D5016),
      ),
      OnboardingPage(
        title: l10n.onboardingSearchTitle,
        description: l10n.onboardingSearchDesc,
        icon: Icons.search,
        color: Color(0xFF4A7C3C),
      ),
      OnboardingPage(
        title: l10n.onboardingMapTitle,
        description: l10n.onboardingMapDesc,
        icon: Icons.map,
        color: Color(0xFF87CEEB),
      ),
      OnboardingPage(
        title: l10n.onboardingAccountTitle,
        description: l10n.onboardingAccountDesc,
        icon: Icons.person,
        color: Color(0xFF6B4423),
        isLoginPage: true,
      ),
      OnboardingPage(
        title: l10n.onboardingLocationTitle,
        description: l10n.onboardingLocationDesc,
        icon: Icons.location_on,
        color: Color(0xFFFF8C42),
        isPermissionPage: true,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isRequestingPermission = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _completeOnboarding();
      } else if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
      } else {
        // Permission negato ma può essere richiesto di nuovo
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.permissionDeniedSnack),
              duration: Duration(seconds: 3),
            ),
          );
        }
        // Continua comunque
        await _completeOnboarding();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequestingPermission = false;
        });
      }
    }
  }

  void _showPermissionDeniedDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionDenied),
        content: Text(l10n.permissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _completeOnboarding();
            },
            child: Text(l10n.continueWithoutPermission),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              // Apri le impostazioni del sistema
              await Geolocator.openAppSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _skipToPermissionPage(int pageCount) {
    _pageController.animateToPage(
      pageCount - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildLoginPage(OnboardingPage page) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icona
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(page.icon, size: 60, color: page.color),
          ),
          const SizedBox(height: 48),

          // Titolo
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Descrizione
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Bottoni di login
          if (authProvider.isLoading)
            const CircularProgressIndicator()
          else ...[
            // Google Sign In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final success = await authProvider.signInWithGoogle();
                  if (success && mounted) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.g_mobiledata, size: 24),
                ),
                label: Text(
                  AppLocalizations.of(context)!.continueWithGoogleOnboarding,
                  style: const TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Apple Sign In (solo su iOS/macOS)
            FutureBuilder<bool>(
              future: authProvider.isAppleSignInAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final success = await authProvider
                                .signInWithApple();
                            if (success && mounted) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          icon: const Icon(Icons.apple, size: 24),
                          label: Text(
                            AppLocalizations.of(
                              context,
                            )!.continueWithAppleOnboarding,
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: colorScheme.outlineVariant),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Continua senza account
            TextButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                AppLocalizations.of(context)!.continueWithoutAccountOnboarding,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],

          // Messaggio di errore
          if (authProvider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _resolveAuthError(context, authProvider.errorMessage!),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(context);
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Indicatori pagina
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? pages[index].color
                          : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),

            // Contenuto pagine
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];

                  // Pagina login speciale
                  if (page.isLoginPage) {
                    return _buildLoginPage(page);
                  }

                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icona
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon, size: 60, color: page.color),
                        ),
                        const SizedBox(height: 48),

                        // Titolo
                        Text(
                          page.title,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: page.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Descrizione
                        Text(
                          page.description,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottoni navigazione
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pulsante Salta (solo se non è l'ultima pagina)
                  if (_currentPage < pages.length - 1)
                    TextButton(
                      onPressed: () => _skipToPermissionPage(pages.length),
                      child: Text(l10n.skip),
                    )
                  else
                    const SizedBox(width: 80),

                  // Pulsante Avanti/Fine
                  FilledButton(
                    onPressed: _isRequestingPermission
                        ? null
                        : () {
                            if (_currentPage < pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // Ultima pagina - richiedi permesso
                              _requestLocationPermission();
                            }
                          },
                    child: _isRequestingPermission
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage < pages.length - 1
                                    ? l10n.next
                                    : l10n.allowLocation,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage < pages.length - 1
                                    ? Icons.arrow_forward
                                    : Icons.check,
                                size: 20,
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isPermissionPage;
  final bool isLoginPage;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isPermissionPage = false,
    this.isLoginPage = false,
  });
}
