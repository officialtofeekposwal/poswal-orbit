# Poswal Orbit R8 / ProGuard Keep Rules for Release Build

# Flutter Engine & Framework
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Drift / SQLite / sqlite3 Native C-Bindings
-keep class androidx.sqlite.db.** { *; }
-keep class androidx.sqlite.db.framework.** { *; }
-keep class com.simonbinder.sqlite3.** { *; }
-dontwarn com.simonbinder.sqlite3.**

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# Home Widget / Android AppWidgets
-keep class es.antonborri.home_widget.** { *; }
-keep class com.poswal.orbit.OrbitTodayWidgetProvider { *; }
-keep class com.poswal.orbit.OrbitHabitsWidgetProvider { *; }
-keep class com.poswal.orbit.OrbitTasksWidgetProvider { *; }
-keep class android.appwidget.AppWidgetProvider { *; }

# Serialization & Desugaring
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions
