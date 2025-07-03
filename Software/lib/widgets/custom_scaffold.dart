import 'dart:ui';
import 'package:flutter/material.dart';
import '../main.dart';
import '../verlauf_screen.dart';
import '../zeitplan.dart';
import '../einstellungen.dart';
import 'package:flutter/services.dart';
import '../home_screen.dart';
import 'package:provider/provider.dart';

class CustomScaffold extends StatefulWidget {
  final String title;
  final Widget body;

  const CustomScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  bool _drawerOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFFFD7),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu),
                        onPressed: () {
                          setState(() {
                            _drawerOpen = true;
                          });
                        },
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(child: widget.body),
                ],
              ),
            ),
          ),
          _buildBlurOverlay(),
          _buildDrawer(context),
        ],
      ),
    );
  }

  Widget _buildBlurOverlay() {
    return _drawerOpen
        ? AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _drawerOpen = false;
                });
              },
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildDrawer(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      left: _drawerOpen ? 0 : -240,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(100),
          bottomRight: Radius.circular(100),
        ),
        child: Container(
          color: Colors.white,
          width: 240,
          height: MediaQuery.of(context).size.height,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _drawerOpen = false;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              _drawerItem(context, 'Hauptmenü', Icons.home, () {
                if (widget.title != 'Hauptmenü') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              }),
              _drawerItem(context, 'Verlauf', Icons.history, () {
                if (widget.title != 'Verlauf') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const VerlaufScreen()),
                  );
                }
              }),
              _drawerItem(context, 'Zeitplan', Icons.schedule, () {
               if (widget.title != 'Zeitplan') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const ZeitplanScreen()),
                  );
                }
              }),
              _drawerItem(context, 'Einstellungen', Icons.settings, () {
                if (widget.title != 'Einstellungen') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const EinstellungenScreen()),
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.green.withOpacity(0.3),
          highlightColor: Colors.green.withOpacity(0.1),
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _drawerOpen = false);
            Future.delayed(const Duration(milliseconds: 300), onTap);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.black87),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
