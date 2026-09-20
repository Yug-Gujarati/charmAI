# WorkManager / Room rules to prevent crash in release builds
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class androidx.work.impl.background.systemjob.SystemJobService { *; }
-keep class androidx.work.impl.background.systemalarm.SystemAlarmService { *; }
-keep class androidx.work.impl.background.systemalarm.ConstraintProxy { *; }
-keep class androidx.work.impl.background.systemalarm.ConstraintProxy$* { *; }
-keep class androidx.work.impl.background.systemalarm.RescheduleReceiver { *; }
-keep class androidx.work.impl.background.systemalarm.UpdateJobService { *; }
-keep class androidx.work.impl.diagnostics.DiagnosticsReceiver { *; }
-keep class androidx.work.impl.utils.ForceStopRunnable$BroadcastReceiver { *; }

-keep class * extends androidx.room.RoomDatabase
-keepclassmembers class * extends androidx.room.RoomDatabase {
    <init>(...);
}

# Keep the specific WorkDatabase generated implementation
-keep class androidx.work.impl.WorkDatabase { *; }

# Google Mobile Ads
-keep public class com.google.android.gms.ads.** {
   public *;
}

# For Flutter plugins
-keep class io.flutter.plugins.** { *; }
