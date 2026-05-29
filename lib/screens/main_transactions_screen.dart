import 'package:flutter/material.dart';
import 'package:the_finxup_app/screens/consumer_transaction_screen.dart';
import 'package:the_finxup_app/screens/transaction_list_screen.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class MainTransactionsScreenV3 extends StatefulWidget {
  const MainTransactionsScreenV3({super.key});

  @override
  State<MainTransactionsScreenV3> createState() =>
      _MainTransactionsScreenV3State();
}

class _MainTransactionsScreenV3State extends State<MainTransactionsScreenV3> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeHSL.background,
      body: Column(
        children: [
          // Header personalizado
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppThemeHSL.background, AppThemeHSL.backgroundDeep],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Título y acciones

                  // Selector de página personalizado
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        FittedBox(
                        fit: BoxFit.scaleDown,
                        child:_buildPageSelector(
                          title: 'Transacciones',
                          icon: Icons.receipt_long,
                          isSelected: _currentPage == 0,
                          onTap: () {
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        )),
                        // const SizedBox(width: 12),
                        FittedBox(
                        fit: BoxFit.scaleDown,
                        child:_buildPageSelector(
                          title: 'Histórico',
                          icon: Icons.history,
                          isSelected: _currentPage == 1,
                          onTap: () {
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        )),
                        // const SizedBox(width: 4),
                        Row(
                          mainAxisAlignment: .start,
                          children: [
                            _buildHeaderButton(Icons.filter_list, () {
                              _showFilterBottomSheet();
                            }),
                            // const SizedBox(width: 4),
                            _buildHeaderButton(Icons.more_vert, () {
                              _showMoreOptions();
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),

          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: const [
                ConsumerTransactionsScreen(),
                HistoricoTransaccionesScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(0),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.transparent,//white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(0),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildPageSelector({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppThemeHSL.textPrimary.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(0),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppThemeHSL.background : Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppThemeHSL.background : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Filtrar por',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Por fecha'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Por categoría'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Por monto'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('Exportar datos'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Ayuda'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
