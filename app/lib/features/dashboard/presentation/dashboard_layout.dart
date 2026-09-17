import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../../../models/app_user.dart';
import '../widgets/codeclass/institution_picker.dart';

/// Sección a la que pertenece un elemento del menú del dashboard.
enum DashboardSection { tab, menu }

/// Elemento del menú del dashboard.
class DashboardPage {
  const DashboardPage({
    required this.label,
    required this.icon,
    required this.child,
    this.section = DashboardSection.tab,
    this.group,
  });

  final String label;
  final IconData icon;
  final Widget child;
  final DashboardSection section;
  final String? group;
}

/// Permite cambiar de pestaña o sección desde cualquier vista interna
/// (por ejemplo, los accesos rápidos de Inicio).
class DashboardIndex extends InheritedWidget {
  const DashboardIndex({
    super.key,
    required this.controller,
    required super.child,
  });

  final DashboardNavController controller;

  static DashboardNavController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardIndex>()!.controller;

  static DashboardNavController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DashboardIndex>()?.controller;

  @override
  bool updateShouldNotify(DashboardIndex oldWidget) =>
      controller != oldWidget.controller;
}

/// Estado de navegación del panel: índice de página activa y último tab.
class DashboardNavController extends ChangeNotifier {
  DashboardNavController(this.tabCount);

  final int tabCount;
  int _index = 0;
  int _lastTab = 0;

  int get index => _index;
  bool get isMenuPage => _index >= tabCount;

  void selectTab(int i) {
    if (i < 0 || i >= tabCount) return;
    _lastTab = i;
    _index = i;
    notifyListeners();
  }

  void selectMenu(int fullIndex) {
    _index = fullIndex;
    notifyListeners();
  }

  void backToTab() {
    _index = _lastTab.clamp(0, tabCount - 1);
    notifyListeners();
  }
}

/// Estructura responsive del panel CodeClass:
/// - Compacto (<1000px): AppBar + 5 pestañas inferiores (NavigationBar) +
///   menú lateral deslizable (Drawer) para el resto de secciones.
/// - Escritorio (>=1000px): barra lateral completa + barra superior.
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
  late DashboardNavController _nav;

  List<DashboardPage> get _tabs =>
      widget.pages.where((p) => p.section == DashboardSection.tab).toList();

  List<DashboardPage> get _menu =>
      widget.pages.where((p) => p.section == DashboardSection.menu).toList();

  int _fullIndex(DashboardPage page) => widget.pages.indexOf(page);

  @override
  void initState() {
    super.initState();
    _nav = DashboardNavController(_tabs.length);
  }

  @override
  void didUpdateWidget(DashboardLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pages.length != widget.pages.length) {
      _nav = DashboardNavController(_tabs.length);
    }
  }

  @override
  void dispose() {
    _nav.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1000;

    return DashboardIndex(
      controller: _nav,
      child: ListenableBuilder(
        listenable: _nav,
        builder: (context, _) {
          if (widget.pages.isEmpty) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final current = widget.pages[_nav.index.clamp(0, widget.pages.length - 1)];
          if (compact) {
            return _buildCompact(current);
          }
          return _buildWide(current);
        },
      ),
    );
  }

  // ===============================
  // COMPACTO (MÓVIL / TABLET)
  // ===============================

  Widget _buildCompact(DashboardPage current) {
    final isMenu = _nav.isMenuPage;
    return Scaffold(
      appBar: AppBar(
        leading: isMenu
            ? IconButton(
                tooltip: 'Volver',
                icon: const Icon(Icons.arrow_back),
                onPressed: _nav.backToTab,
              )
            : Builder(
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
      drawer: isMenu ? null : Drawer(child: _buildDrawer()),
      body: _buildContent(current),
      bottomNavigationBar: isMenu ? null : _buildNavigationBar(),
    );
  }

  Widget _buildNavigationBar() {
    final tabs = _tabs;
    if (tabs.isEmpty) return const SizedBox.shrink();
    return NavigationBar(
      selectedIndex: _nav.index.clamp(0, tabs.length - 1),
      onDestinationSelected: _nav.selectTab,
      destinations: [
        for (final page in tabs)
          NavigationDestination(
            icon: Icon(page.icon),
            selectedIcon: Icon(_selectedIcon(page.icon)),
            label: page.label,
          ),
      ],
    );
  }

  IconData _selectedIcon(IconData icon) => icon;

  // ===============================
  // ESCRITORIO
  // ===============================

  Widget _buildWide(DashboardPage current) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSidebar(),
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
                  _nav.isMenuPage
                      ? 'Menú / ${page.label}'
                      : 'CodeClass / ${page.label}',
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
            key: ValueKey<int>(_nav.index),
            child: page.child,
          ),
        ),
      ),
    );
  }

  // ===============================
  // BARRA LATERAL (ESCRITORIO)
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBrand(),
                  const SizedBox(height: AppDimens.md),
                  const InstitutionPicker(),
                ],
              ),
            ),
            const Divider(height: 1),
            const SizedBox(height: AppDimens.sm),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.sm,
                  vertical: AppDimens.xs,
                ),
                children: _buildNavItems(dense: false),
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

  List<Widget> _buildNavItems({required bool dense}) {
    final items = <Widget>[];
    final tabs = _tabs;
    if (tabs.isNotEmpty) {
      items.add(_sectionHeader(dense, 'Principal'));
      for (var i = 0; i < tabs.length; i++) {
        items.add(_buildNavItem(i, tabs[i], dense: dense));
      }
    }
    if (_menu.isNotEmpty) {
      for (final group in [
        if (_menu.any((p) => p.group == null)) _menu.where((p) => p.group == null).toList(),
        for (final name in _groups()) _menu.where((p) => p.group == name).toList(),
      ]) {
        if (group.isEmpty) continue;
        final label = group.first.group ?? 'Más opciones';
        items.add(_sectionHeader(dense, label));
        for (final page in group) {
          items.add(_buildNavItem(_fullIndex(page), page, dense: dense));
        }
      }
    }
    return items;
  }

  List<String> _groups() {
    final names = <String>[];
    for (final p in _menu) {
      if (p.group != null && !names.contains(p.group)) names.add(p.group!);
    }
    return names;
  }

  Widget _sectionHeader(bool dense, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.md,
        dense ? AppDimens.xs : AppDimens.md,
        AppDimens.md,
        4,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, DashboardPage page,
      {required bool dense}) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final selected = index == _nav.index;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          onTap: () {
            if (page.section == DashboardSection.tab) {
              _nav.selectTab(index);
            } else {
              _nav.selectMenu(index);
            }
          },
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
                      color: selected
                          ? scheme.onPrimaryContainer
                          : scheme.onSurface,
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
          child: const Icon(Icons.computer_rounded, color: Colors.white, size: 24),
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
  // DRAWER (COMPACTO)
  // ===============================

  Widget _buildDrawer() {
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
                      child: const Icon(Icons.computer_rounded,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.lg,
              AppDimens.lg,
              AppDimens.lg,
              0,
            ),
            child: InstitutionPicker(
              onChanged: (_) => _nav.selectTab(1),
            ),
          ),
          ..._drawerNavItems(),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.danger),
            title: Text('Cerrar Sesión',
                style: TextStyle(color: AppColors.danger)),
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

  List<Widget> _drawerNavItems() {
    final scheme = Theme.of(context).colorScheme;
    final items = <Widget>[];
    for (final group in [
      if (_menu.any((p) => p.group == null))
        _menu.where((p) => p.group == null).toList(),
      for (final name in _groups()) _menu.where((p) => p.group == name).toList(),
    ]) {
      if (group.isEmpty) continue;
      final label = group.first.group ?? 'Más opciones';
      items.add(_sectionHeader(true, label));
      for (final page in group) {
        final index = _fullIndex(page);
        items.add(ListTile(
          leading: Icon(page.icon),
          title: Text(page.label),
          selected: index == _nav.index,
          selectedColor: scheme.onPrimaryContainer,
          selectedTileColor: scheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          onTap: () {
            _nav.selectMenu(index);
            Navigator.of(context).pop();
          },
        ));
      }
    }
    return items;
  }
}

/// Fila clicable con icono y texto, usada en la barra lateral.
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