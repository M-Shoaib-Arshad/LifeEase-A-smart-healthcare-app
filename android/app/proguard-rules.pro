# ProGuard rules for LifeEase Healthcare App

# Keep Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Flutter Play Store Split Compatibility (optional feature)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firestore specific rules
-keep class com.google.firebase.firestore.** { *; }
-keepclassmembers class com.google.firebase.firestore.** {
    *;
}

# Firebase Auth rules
-keep class com.google.firebase.auth.** { *; }
-keepclassmembers class com.google.firebase.auth.** {
    *;
}

# Google Sign In rules
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Agora RTC Engine rules
-keep class io.agora.** { *; }
-dontwarn io.agora.**
-keep class io.agora.rtc.** { *; }
-keep class io.agora.rtc2.** { *; }
-keep class io.agora.base.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Image Picker rules
-keep class io.flutter.plugins.imagepicker.** { *; }

# Shared Preferences rules
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Permission Handler rules
-keep class com.baseflow.permissionhandler.** { *; }

# Flutter Secure Storage rules
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep model classes (adjust package name if needed)
-keep class com.shoaib.lifeease.models.** { *; }

# Gson rules (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# OkHttp rules (used by many plugins)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Remove logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Keep line numbers for better crash reports
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
