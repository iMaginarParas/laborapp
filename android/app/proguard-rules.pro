# Flutter Specific Rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Prevent R8 from stripping away native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Preserve GSON/JSON models if needed (we use Dio/JSON)
-keep class com.example.flutter_app.shared.models.** { *; }
-keep class com.example.flutter_app.features.**.models.** { *; }
