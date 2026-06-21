import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// Asegúrate de usar las rutas correctas de tu proyecto
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/providers/debts_filter_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class BuildUiDebtOverlay extends ConsumerStatefulWidget {
  const BuildUiDebtOverlay({super.key});

  @override
  ConsumerState<BuildUiDebtOverlay> createState() => _BuildUiDebtOverlayState();
}

class _BuildUiDebtOverlayState extends ConsumerState<BuildUiDebtOverlay> {
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  // 👈 Controlador persistente para evitar bugs de cursor y foco
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    // Inicializamos el controlador con el valor actual del provider
    _searchController = TextEditingController(
      text: ref.read(debtSearchQueryProvider),
    );
  }

  @override
  void dispose() {
    // Liberamos la memoria del controlador correctamente
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentFilter = ref.watch(debtFilterProvider);
    // Escuchamos la query para que el botón del AppBar se actualice visualmente
    final searchQuery = ref.watch(debtSearchQueryProvider);

    // Sincronizamos el texto si cambia externamente
    if (_searchController.text != searchQuery) {
      _searchController.text = searchQuery;
    }

    return Expanded(
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔍 Cápsula Izquierda: Buscador (Lanzador del BottomSheet)
                Expanded(
                  child: _buildGlassCapsule(
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: AppThemeHSL.textHint,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            readOnly: true, // Bloquea escritura directa aquí
                            onTap: () => _showSearchBottomSheet(
                              context,
                            ), // Abre el panel
                            style: TextStyle(
                              color: Colors.transparent,
                              fontSize: 14,
                            ),
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar deuda...',
                              hintStyle: TextStyle(
                                color: AppThemeHSL.textHint,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        // Botón rápido para limpiar la búsqueda desde afuera si tiene texto
                        if (searchQuery.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              ref.read(debtSearchQueryProvider.notifier).state =
                                  '';
                            },
                            child: Icon(
                              Icons.close,
                              color: AppThemeHSL.textHint,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // 🎛️ Cápsula Derecha: Menú de Filtros Avanzados
                _buildGlassCapsule(
                  child: SizedBox(
                    height: 30,
                    width: 24,
                    child: PopupMenuButton<DebtFilter>(
                      initialValue: currentFilter,
                      splashRadius: 28,
                      popUpAnimationStyle: AnimationStyle(
                        curve: Curves.easeInOutQuart,
                        duration: const Duration(milliseconds: 400),
                        reverseCurve: Curves.easeIn,
                        reverseDuration: const Duration(milliseconds: 200),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: AppThemeHSL.surfaceLight,
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.filter_list,
                        color: AppThemeHSL.textPrimary,
                        size: 24,
                      ),
                      onSelected: (DebtFilter selectedFilter) {
                        ref.read(debtFilterProvider.notifier).state =
                            selectedFilter;
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: DebtFilter.all,
                          child: Row(
                            children: [
                              Icon(Icons.list, color: AppThemeHSL.accentGold),
                              const SizedBox(width: 10),
                              Text(
                                "Mostrar Todas",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: DebtFilter.porCobrar,
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_upward,
                                color: AppThemeHSL.incomeLight,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Por Cobrar (Te deben)",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: DebtFilter.esDeuda,
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_downward,
                                color: AppThemeHSL.expenseLight,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Por Pagar (Debes)",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),

                        PopupMenuItem(
                          value: DebtFilter.pagado,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: AppThemeHSL.income,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Completadas / Pagadas",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // debido al reverse: true en el ListView.builder de DebtAgendaView
                        PopupMenuItem(
                          value: DebtFilter.menorPrestamo,
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: AppThemeHSL.incomeLight,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Más alta (inicial)",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: DebtFilter.mayorPrestamo,
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_down,
                                color: AppThemeHSL.expenseLight,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Más baja (inicial)",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: DebtFilter.menorRestante,
                          child: Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: AppThemeHSL.incomeLight,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Más alta (restante)",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: DebtFilter.mayorRestante,
                          child: Row(
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: AppThemeHSL.expenseLight,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Más baja (restante)",
                                style: TextStyle(
                                  color: AppThemeHSL.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeHSL.surfaceMid,
      // 👇 Añade esta línea para oscurecer el fondo (80% de opacidad negra)
      barrierColor: Colors.black.withValues(alpha: 0.7),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final allDebts = ref.watch(debtListProvider);
            final searchQuery = ref.watch(debtSearchQueryProvider);

            // Filtrado local optimizado
            final searchResults = allDebts.where((debt) {
              return debt.nombre.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 12,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador visual superior del BottomSheet
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppThemeHSL.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buscador activo dentro del BottomSheet
                  TextField(
                    autofocus: true,
                    style: TextStyle(color: AppThemeHSL.textPrimary),
                    controller:
                        _searchController, // 👈 Reutiliza el controlador persistente
                    decoration: InputDecoration(
                      hintText: 'Buscar deuda...',
                      hintStyle: TextStyle(color: AppThemeHSL.textHint),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppThemeHSL.textHint,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              color: AppThemeHSL.textHint,
                              onPressed: () {
                                _searchController.clear();
                                ref
                                        .read(debtSearchQueryProvider.notifier)
                                        .state =
                                    '';
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppThemeHSL.surfaceLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppThemeHSL.accentGold),
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(debtSearchQueryProvider.notifier).state = value;
                    },
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Resultados encontrados (${searchResults.length})',
                    style: TextStyle(
                      color: AppThemeHSL.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                    ),
                    child: searchResults.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 32),
                            child: Center(
                              child: Text(
                                'No hay coincidencias.',
                                style: TextStyle(color: AppThemeHSL.textMuted),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: searchResults.length,
                            separatorBuilder: (context, index) => Divider(
                              color: AppThemeHSL.surfaceLight,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final debt = searchResults[index];
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                title: Text(
                                  debt.nombre,
                                  style: TextStyle(
                                    color: AppThemeHSL.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                subtitle: Text(
                                  dateFormat.format(debt.fecha),
                                  style: TextStyle(
                                    color: AppThemeHSL.textMuted,
                                    fontSize: 13,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${debt.cantidad.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: debt.esDeuda
                                            ? AppThemeHSL.expenseLight
                                            : AppThemeHSL.incomeLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      debt.pagado ? 'Pagado' : 'Pendiente',
                                      style: TextStyle(
                                        color: debt.pagado
                                            ? AppThemeHSL.income
                                            : AppThemeHSL.expense,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // Acción opcional al presionar un elemento de la lista
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGlassCapsule({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppThemeHSL.surfaceLighter.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}
