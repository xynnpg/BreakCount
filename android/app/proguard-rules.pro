# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Crashlytics — preserve stack traces
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }

# Kotlin reflection & serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses,EnclosingMethod

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# App widget providers (must not be stripped)
-keep class com.breakcount.app.BreakCountWidget** { *; }
-keep class com.breakcount.app.MainActivity { *; }

# home_widget plugin
-keep class es.antonborri.home_widget.** { *; }

# sensors_plus
-keep class dev.fluttercommunity.plus.sensors.** { *; }

# permission_handler
-keep class com.baseflow.permissionhandler.** { *; }

# image_picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# nearby_connections
-keep class com.google.android.gms.nearby.** { *; }

# Suppress common warnings from transitive deps
-dontwarn org.bouncycastle.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**
