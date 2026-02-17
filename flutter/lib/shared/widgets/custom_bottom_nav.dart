import 'package:flutter/material.dart';

class CustomBottomNav extends StatelessWidget {
  final ShellRouteState state;

  const CustomBottomNav({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: state.currentIndex,
      onTap: (index) => state.onTabChanged(index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today_outlined),
          label: 'Eventos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Clientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_outlined),
          label: 'Inventario',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search_outlined),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: 'Ajustes',
        ),
      ],
    );
  }
}

class ShellRouteState {
  int currentIndex;
  Function(int) onTabChanged;

  ShellRouteState({
    required this.currentIndex,
    required this.onTabChanged,
  });
}
