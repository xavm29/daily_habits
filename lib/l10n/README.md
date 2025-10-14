# Localization Guide / Guía de Localización

## Overview / Descripción General

This app supports multiple languages using Flutter's localization system.
Esta aplicación soporta múltiples idiomas usando el sistema de localización de Flutter.

## Supported Languages / Idiomas Soportados

- English (en)
- Spanish (es)

## How to Use Translations / Cómo Usar las Traducciones

### In Your Widgets / En tus Widgets

```dart
import 'package:daily_habits/l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the localization instance
    final l10n = AppLocalizations.of(context);

    return Text(l10n.home); // Will show "Home" or "Inicio" based on device language
  }
}
```

### Common Translations / Traducciones Comunes

```dart
l10n.home              // "Home" / "Inicio"
l10n.settings          // "Settings" / "Configuración"
l10n.signIn            // "Sign In" / "Iniciar sesión"
l10n.signUp            // "Sign Up" / "Registrarse"
l10n.save              // "Save" / "Guardar"
l10n.cancel            // "Cancel" / "Cancelar"
l10n.delete            // "Delete" / "Eliminar"
l10n.create            // "Create" / "Crear"
```

## Adding New Translations / Agregar Nuevas Traducciones

### Step 1: Add to app_localizations.dart

```dart
abstract class AppLocalizations {
  // ...
  String get myNewKey;
}
```

### Step 2: Add to app_localizations_en.dart

```dart
class AppLocalizationsEn extends AppLocalizations {
  // ...
  @override
  String get myNewKey => 'My English Text';
}
```

### Step 3: Add to app_localizations_es.dart

```dart
class AppLocalizationsEs extends AppLocalizations {
  // ...
  @override
  String get myNewKey => 'Mi Texto en Español';
}
```

## Available Translation Keys / Claves de Traducción Disponibles

### App General
- `appName`, `home`, `settings`, `profile`, `logout`
- `cancel`, `save`, `delete`, `edit`, `create`
- `loading`, `error`, `success`, `confirm`, `yes`, `no`

### Authentication
- `welcomeBack`, `signIn`, `signUp`
- `email`, `password`
- `continueWithGoogle`, `skipForNow`
- `alreadyHaveAccount`, `dontHaveAccount`

### Goals & Habits
- `createGoal`, `editGoal`, `goalTitle`
- `daily`, `weekly`, `monthly`
- `checkbox`, `quantitative`, `duration`
- `target`, `track`, `completed`

### Challenges
- `challenges`, `activeChallenges`, `completedChallenges`
- `createCustomChallenge`, `joinChallenge`, `leaveChallenge`
- `daysLeft`, `participants`, `active`

### Rewards & Achievements
- `rewards`, `achievements`
- `myCoins`, `availableCoins`
- `redeemReward`, `cost`

### Statistics
- `statistics`, `currentStreak`, `longestStreak`
- `totalCompleted`, `completionRate`
- `thisWeek`, `thisMonth`, `allTime`

### Messages & Errors
- `greatJob`, `keepItUp`, `perfectDay`
- `errorLoadingData`, `errorSavingData`
- `errorNetwork`, `errorUnknown`

## Testing Different Languages / Probando Diferentes Idiomas

### On Android Emulator:
1. Open Settings → System → Languages & input
2. Add Spanish (or your target language)
3. Drag it to the top of the list

### On iOS Simulator:
1. Open Settings → General → Language & Region
2. Add Spanish (or your target language)
3. Set it as preferred language

### Programmatically (for testing):
The app automatically detects the device language. To force a specific language:

```dart
// In MaterialApp
locale: const Locale('es'), // Force Spanish
// or
locale: const Locale('en'), // Force English
```

## File Structure / Estructura de Archivos

```
lib/
  l10n/
    app_localizations.dart     // Base abstract class
    app_localizations_en.dart  // English translations
    app_localizations_es.dart  // Spanish translations
    README.md                  // This file
```

## Best Practices / Mejores Prácticas

1. **Always use translation keys** instead of hardcoded strings
   **Siempre usa claves de traducción** en lugar de texto hardcodeado

2. **Keep translations short and concise** for UI elements
   **Mantén las traducciones cortas y concisas** para elementos de UI

3. **Test both languages** before releasing
   **Prueba ambos idiomas** antes de publicar

4. **Use context-appropriate translations** - some words translate differently based on context
   **Usa traducciones apropiadas al contexto** - algunas palabras se traducen diferente según el contexto

## Example Screen / Pantalla de Ejemplo

```dart
import 'package:flutter/material.dart';
import 'package:daily_habits/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.darkMode),
            trailing: Switch(value: false, onChanged: null),
          ),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text('English / Español'),
          ),
          ListTile(
            title: Text(l10n.notifications),
            trailing: Switch(value: true, onChanged: null),
          ),
        ],
      ),
    );
  }
}
```

## Need Help? / ¿Necesitas Ayuda?

If you need to add a new translation or language support, refer to the Flutter documentation:
Si necesitas agregar una nueva traducción o soporte de idioma, consulta la documentación de Flutter:

https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization
