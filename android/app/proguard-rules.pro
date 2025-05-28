# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

-keep class me.carda.awesome_notifications.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Permitir chamadas reflextivas comuns
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Google services / Firebase (se usar)
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
