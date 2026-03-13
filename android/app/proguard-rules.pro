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
-keep class com.laborgro.app.shared.models.** { *; }
-keep class com.laborgro.app.features.**.models.** { *; }

# Google Play Store Core Library (for deferred components)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.tasks.**
