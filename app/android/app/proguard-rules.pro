# Reglas de ProGuard/R8 para la aplicación del Laboratorio.
#
# Se conservan las clases de Flutter, Firebase y Play Services para evitar
# que la optimización elimine código usado por reflexión o por los plugins.

-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod

-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.unefa.laboratorio.** { *; }

# Plugins que usan JNI/reflexión.
-keep class androidx.biometric.** { *; }

-dontwarn io.flutter.embedding.**
