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

# flutter_local_notifications — alarm receivers must survive R8
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Gson — used by flutter_local_notifications to persist scheduled notifications
# to SharedPreferences. Without these rules R8 renames TypeToken to 'a' and
# loadScheduledNotifications() crashes with com.google.gson.reflect.a.<init>.
-keep class com.google.gson.** { *; }
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

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
