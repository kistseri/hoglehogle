-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.**
-keep class com.nhn.android.** { *; }
-keep public class com.navercorp.nid.** { public *; }
-keep class com.naver.** { *; }
-keep class com.nid.** { *; }

# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE
