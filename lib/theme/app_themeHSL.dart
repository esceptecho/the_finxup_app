import 'package:flutter/material.dart';

class AppThemeHSL {
	// 🎨 HELPER: Convierte HSL a Color de Flutter
	static Color _hsl(double h, double s, double l) => 
	HSLColor.fromAHSL(1.0, h, s / 100, l / 100).toColor();
  
  // Nota técnica: He usado una función helper _hsl para que el código sea limpio. Recuerda que en Flutter,
  // HSLColor requiere valores de saturación y luminosidad entre 0.0 y 1.0, por eso los divido entre 100 para que tú 
  // puedas usar porcentajes (0-100) que son más naturales de leer.
  
  static Color getStatusColor(double balance, {bool darkVariation = false}) {
    if (balance >= 0) {
      // Si es positivo, usamos la base de 'income' (Hue 168)
      return darkVariation ? incomeDark : income;
    } else {
      // Si es negativo, usamos la base de 'expense' (Hue 352)
      return darkVariation ? expenseDark : expense;
    }
  }
  
  // EXTRA: Si quieres que el color se vuelva más intenso según la cifra
  static Color getIntensityColor(double balance) {
    final isPositive = balance >= 0;
    final double hue = isPositive ? 168 : 352;
    
    // Limitamos la saturación entre 40% y 100% según el monto (ejemplo hasta 1000$)
    double amount = balance.abs().clamp(0, 1000);
    double saturation = 40 + (amount / 1000 * 60); 
    
    return _hsl(hue, saturation, 50);
  }
	
	// ==============================
	// 🍷 BURGUNDY (Hue: 354°)
	// ==============================
	static final Color primary           = _hsl(354, 77, 22); // Base
	static final Color primaryDark       = _hsl(354, 77, 14); // -8% Lightness
	static final Color primaryLight      = _hsl(354, 68, 33); 
	static final Color primaryExtraLight = _hsl(354, 57, 46);
	
	// ==============================
	// 🥂 ACENTOS (Hue: 40° Gold / 30° Champagne)
	// ==============================
	static final Color accentGold       = _hsl(40, 50, 56);
	static final Color accentGoldSoft   = _hsl(30, 31, 78);
	static final Color accentGoldLight  = _hsl(40, 61, 88);
	static final Color accentGoldBright = _hsl(51, 100, 50);
	
	// ==============================
	// 🌑 DARK MODE (Hue: 0°, Saturation: 0%)
	// ==============================
	static final Color background      = _hsl(0, 0, 5);
	static final Color backgroundDeep  = _hsl(0, 0, 2);
	static final Color surface         = _hsl(0, 0, 9);
	static final Color surfaceMid      = _hsl(0, 0, 12);
	static final Color surfaceLight    = _hsl(0, 0, 15);
	static final Color surfaceLighter  = _hsl(0, 0, 17);
	
	// ==============================
	// 🧾 TEXTO (Escala de grises)
	// ==============================
	static final Color textPrimary   = _hsl(0, 0, 95);
	static final Color textSecondary = _hsl(0, 0, 69);
	static final Color textMuted     = _hsl(0, 0, 45);
	static final Color textHint      = _hsl(0, 0, 38);
	static final Color textDisabled  = _hsl(0, 0, 29);
	
	// ==============================
	// 📊 ESTADOS
	// ==============================
	static final Color income      = _hsl(168, 55, 53);
	static final Color incomeDark  = _hsl(168, 48, 39);
	static final Color incomeLight = _hsl(168, 54, 65);
	
	static final Color expense      = _hsl(352, 71, 37);
	static final Color expenseDark  = _hsl(352, 72, 28);
	static final Color expenseLight = _hsl(352, 54, 51);
	
	// UI ELEMENTS
	static final Color card    = surfaceLight;
	static final Color divider = surfaceLighter;
	static final Color overlay = primary.withOpacity(0.1);
	
	// ==============================
	// 🌗 THEME DATA
	// ==============================
	static ThemeData get darkTheme {
		return ThemeData(
			useMaterial3: true,
			brightness: Brightness.dark,
			scaffoldBackgroundColor: background,
			primaryColor: primary,
			colorScheme: ColorScheme.dark(
				primary: primary,
				secondary: accentGold,
				surface: surfaceMid,
				error: expense,
				onPrimary: Colors.white,
				onSecondary: Colors.black,
				onSurface: textPrimary,
				onError: Colors.white,
			),
			cardColor: card,
			dividerColor: divider,
			textTheme: TextTheme(
				displayLarge: TextStyle(color: accentGold, fontWeight: FontWeight.bold),
								 bodyLarge: TextStyle(color: textPrimary),
								 bodyMedium: TextStyle(color: textSecondary),
								 bodySmall: TextStyle(color: textMuted),
			),
			appBarTheme: AppBarTheme(backgroundColor: surface, elevation: 0),
						 elevatedButtonTheme: ElevatedButtonThemeData(
							 style: ElevatedButton.styleFrom(
								 backgroundColor: primary,
								 foregroundColor: Colors.white,
							 ),
						 ),
		);
	}
}
