import 'package:flutter/material.dart';
import '../services/platform_service.dart';

class AdaptiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? web;

  const AdaptiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.web,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isWeb && web != null) {
      return web!;
    }

    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth >= 1200 && desktop != null) {
      return desktop!;
    }

    if (screenWidth >= 600 && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final String title;
  final List<NavigationDestination> destinations;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final List<Widget>? actions;

  const AdaptiveScaffold({
    Key? key,
    required this.title,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (PlatformService.isDesktop) {
      return _buildDesktopScaffold(context);
    }

    if (PlatformService.isWeb) {
      return _buildWebScaffold(context);
    }

    return _buildMobileScaffold(context);
  }

  Widget _buildDesktopScaffold(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            destinations: destinations
                .map((d) => NavigationRailDestination(
                      icon: d.icon,
                      label: Text(d.label),
                    ))
                .toList(),
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // التنقل بين الصفحات
            },
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Widget _buildWebScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: false,
            destinations: destinations
                .map((d) => NavigationRailDestination(
                      icon: d.icon,
                      label: Text(d.label),
                    ))
                .toList(),
            selectedIndex: 0,
            onDestinationSelected: (index) {
              // التنقل بين الصفحات
            },
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  Widget _buildMobileScaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: NavigationBar(
        destinations: destinations,
        selectedIndex: 0,
        onDestinationSelected: (index) {
          // التنقل بين الصفحات
        },
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}