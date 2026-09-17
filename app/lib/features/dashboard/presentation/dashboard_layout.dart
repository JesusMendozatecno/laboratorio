import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/responsive/screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../models/app_user.dart';

/// Elemento del menú del dashboard.
class DashboardPage {
  const DashboardPage({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;
}

/// Estructura responsive del panel:
/// - Escritorio (>=1000px): barra lateral completa + barra superior.
/// - Tablet (600-999px): barra de navegación compacta (NavigationRail).
/// - Móvil (<600px): AppBar + menú deslizable (Drawer).
class DashboardLayout extends StatefulWidget {
  const DashboardLayout({
    super.key,
    required this.user,
    required this.pages,
    required this.onLogout,
  });

  final AppUser user;
  final List<DashboardPage> pages;
  final VoidCallback onLogout;

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final current = widget.pages[_index];
    final size = context.screenSize;

    if (size == ScreenSize.mobile) {
      return _buildMobile(current);
    }
    return _buildWide(current, rail: size == ScreenSize.tablet);
  }

  // ===============================
  // MÓVIL
  // ===============================

  Widget _buildMobile(DashboardPage current) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Menú',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(current.label),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: AppDimens.sm),
        ],
      ),
      drawer: Drawer(child: _buildMenu()),
      body: _buildContent(current),
    );
  }

  // ===============================
  // TABLET / DESKTOP
  // ===============================

  Widget _buildWide(DashboardPage current, {required bool rail}) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          rail ? _buildRail() : _buildSidebar(),
          VerticalDivider(width: 1, color: scheme.outlineVariant),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopBar(current),
                const Divider(height: 1),
                Expanded(child: _buildContent(current)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(DashboardPage page) {
    final theme = Theme.of(context);
    return Container(
      height: AppDimens.topBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inicio / ${page.label}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  page.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const ThemeToggleButton(),
          const SizedBox(width: AppDimens.xs),
        ],
      ),
    );
  }

  Widget _buildContent(DashboardPage page) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.xl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppDimens.maxContentWidth),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey<int>(_index),
            child: page.child,
          ),
        ),
      ),
    );
  }

  // ===============================
  // BARRA LATERAL (DESKTOP)
  // ===============================

  Widget _buildSidebar() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: AppDimens.sidebarWidth,
      color: scheme.surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: _buildBrand(),
            ),
            const Divider(height: 1),
            const SizedBox(height: AppDimens.sm),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.sm,
                  vertical: AppDimens.xs,
                ),
                children: [
                  for (var i = 0; i < widget.pages.length; i++)
                    _buildNavItem(i, widget.pages[i]),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: _buildUser(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.sm,
                0,
                AppDimens.sm,
                AppDimens.sm,
              ),
              child: _buildLogout(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrand() {
    final palette = Theme.of(context).extension<BrandPalette>()!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [palette.start, palette.end],
            ),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: const Icon(Icons.science_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.appName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                AppStrings.tagline,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(int index, DashboardPage page) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final selected = index == _index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          onTap: () => setState(() => _index = index),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.md,
              vertical: 11,
            ),
            child: Row(
              children: [
                Icon(
                  page.icon,
                  size: 21,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimens.md),
                Expanded(
                  child: Text(
                    page.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color: selected ? scheme.onPrimaryContainer : scheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUser() {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final rol = UserRoles.labels[widget.user.tipo] ?? widget.user.tipo;
    return Row(
      children: [
        _avatar(),
        const SizedBox(width: AppDimens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.nombreCompleto,
                style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                rol,
                style: text.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogout() {
    return _InkTile(
      icon: Icons.logout,
      label: 'Cerrar Sesión',
      color: AppColors.danger,
      onTap: widget.onLogout,
    );
  }

  Widget _avatar() {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      backgroundColor: scheme.primary.withValues(alpha: 0.14),
      child: Text(
        widget.user.nombre.isNotEmpty
            ? widget.user.nombre[0].toUpperCase()
            : '?',
        style: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===============================
  // RAIL (TABLET)
  // ===============================

  Widget _buildRail() {
    return NavigationRail(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(top: AppDimens.md, bottom: AppDimens.xs),
        child: _avatar(),
      ),
      destinations: [
        for (final page in widget.pages)
          NavigationRailDestination(
            icon: Icon(page.icon),
            selectedIcon: Icon(page.icon),
            label: Text(page.label),
          ),
      ],
      trailing: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Cerrar Sesión',
              icon: const Icon(Icons.logout),
              color: AppColors.danger,
              onPressed: widget.onLogout,
            ),
            const SizedBox(height: AppDimens.sm),
          ],
        ),
      ),
    );
  }

  // ===============================
  // DRAWER (MÓVIL)
  // ===============================

  Widget _buildMenu() {
    final scheme = Theme.of(context).colorScheme;
    final palette = Theme.of(context).extension<BrandPalette>()!;
    final text = Theme.of(context).textTheme;
    final rol = UserRoles.labels[widget.user.tipo] ?? widget.user.tipo;
    final media = MediaQuery.of(context);

    return SafeArea(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.lg,
              AppDimens.lg,
              AppDimens.xl,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [palette.start, palette.end],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                      ),
                      child: const Icon(Icons.science_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: text.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            AppStrings.tagline,
                            style: text.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.lg),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Text(
                        widget.user.nombre.isNotEmpty
                            ? widget.user.nombre[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.nombreCompleto,
                            style: text.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            rol,
                            style: text.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimens.sm),
          for (var i = 0; i < widget.pages.length; i++)
            ListTile(
              leading: Icon(widget.pages[i].icon),
              title: Text(widget.pages[i].label),
              selected: i == _index,
              selectedColor: scheme.onPrimaryContainer,
              selectedTileColor: scheme.primaryContainer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              onTap: () {
                setState(() => _index = i);
                Navigator.of(context).pop();
              },
            ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.danger),
            title: Text('Cerrar Sesión', style: TextStyle(color: AppColors.danger)),
            onTap: () {
              Navigator.of(context).pop();
              widget.onLogout();
            },
          ),
          SizedBox(height: media.padding.bottom + AppDimens.sm),
        ],
      ),
    );
  }
}

/// Fila clicable con icono y texto, usada en el menú lateral.
class _InkTile extends StatelessWidget {
  const _InkTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusSm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.md,
            vertical: 11,
          ),
          child: Row(
            children: [
              Icon(icon, size: 21, color: color),
              const SizedBox(width: AppDimens.md),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}