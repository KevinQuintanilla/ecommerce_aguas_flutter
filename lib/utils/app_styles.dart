import 'package:flutter/material.dart';

class AppStyles {
  // --- PALETA ACTUALIZADA ---
  // Ahora la paleta "principal" es la de la web.
  static const Color primaryColor = Color(0xFF0D47A1);    // Azul oscuro (El antiguo webPrimaryDark)
  static const Color accentColor = Color(0xFFFBC02D);     // Amarillo/Dorado (El antiguo webAccentYellow)
  static const Color darkColor = Color(0xFF0D47A1);       // Azul oscuro
  static const Color textColor = Color(0xFF2C3E50);       // Azul grisáceo oscuro
  static const Color lightTextColor = Color(0xFF7F8C8D);  // Gris texto secundario
  static const Color backgroundColor = Color(0xFFF1F5F9); // Gris pálido (El antiguo webMutedGray)
  static const Color cardColor = Colors.white;            // Blanco puro
  static const Color borderColor = Color(0xFFE0E0E0);     // Gris bordes
  // --- FIN DE LA ACTUALIZACIÓN ---
  
  // (Las variables "web..." que añadimos antes ya no son necesarias y se han eliminado)

  // Colores de estado
  static const Color successColor = Color(0xFF4CAF50);    // Verde éxito
  static const Color warningColor = Color(0xFFFF9800);    // Naranja advertencia
  static const Color errorColor = Color(0xFFF44336);      // Rojo error
  static const Color infoColor = Color(0xFF2196F3);       // Azul información

  // Colores adicionales para estados
  static const Color successLightColor = Color(0xFFE8F5E8); // Verde claro fondo
  static const Color warningLightColor = Color(0xFFFFF3E0); // Naranja claro fondo
  static const Color errorLightColor = Color(0xFFFFEBEE);   // Rojo claro fondo
  static const Color infoLightColor = Color(0xFFE3F2FD);    // Azul claro fondo

  // Text Styles con identidad clásica
  static const TextStyle companyNameStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: darkColor,
    letterSpacing: 1.5,
  );

  static const TextStyle sloganStyle = TextStyle(
    fontSize: 16,
    color: lightTextColor,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle vintageStyle = TextStyle(
    fontSize: 14,
    color: lightTextColor,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.0,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: darkColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle bodyTextStyle = TextStyle(
    fontSize: 16,
    color: textColor,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: lightTextColor,
    fontWeight: FontWeight.w400,
  );

  // Estilos de texto para estados
  static const TextStyle successTextStyle = TextStyle(
    fontSize: 14,
    color: successColor,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle errorTextStyle = TextStyle(
    fontSize: 14,
    color: errorColor,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle warningTextStyle = TextStyle(
    fontSize: 14,
    color: warningColor,
    fontWeight: FontWeight.w500,
  );

  // Botones - Estilo limpio y profesional
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    minimumSize: const Size(double.infinity, 50),
  );

  static ButtonStyle secondaryButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: primaryColor,
    side: const BorderSide(color: primaryColor, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    minimumSize: const Size(double.infinity, 50),
  );

  // Botones de estado
  static ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: successColor,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle errorButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: errorColor,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  static ButtonStyle warningButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: warningColor,
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Input Fields - Estilo minimalista
  static InputDecoration textFieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: textColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  // Input Fields con estados de error
  static InputDecoration textFieldErrorDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: errorColor),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: errorColor),
      ),
      filled: true,
      fillColor: errorLightColor,
    );
  }

  // Cards - Sombra sutil
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
    border: Border.all(color: borderColor, width: 1),
  );

  // Cards para estados
  static BoxDecoration successCardDecoration = BoxDecoration(
    color: successLightColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: successColor.withOpacity(0.3), width: 1),
  );

  static BoxDecoration errorCardDecoration = BoxDecoration(
    color: errorLightColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: errorColor.withOpacity(0.3), width: 1),
  );

  static BoxDecoration warningCardDecoration = BoxDecoration(
    color: warningLightColor,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: warningColor.withOpacity(0.3), width: 1),
  );

  // AppBar Style
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: cardColor,
    elevation: 0,
    foregroundColor: darkColor,
    titleTextStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: darkColor,
    ),
  );

  // Alertas y mensajes
  static SnackBar successSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: successColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static SnackBar errorSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: errorColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  static SnackBar warningSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: warningColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // Spacing
  static const double defaultPadding = 16.0;
  static const double mediumPadding = 24.0;
  static const double largePadding = 32.0;
  static const double smallPadding = 8.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;

  // Icon sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Animation durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
}