package com.breakcount.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

private const val TAG = "BreakCountWidget"

// ---------------------------------------------------------------------------
// Data holder — populated from SharedPreferences written by the Flutter side
// ---------------------------------------------------------------------------
private data class WidgetData(
    val daysUntilBreak: Int,
    val nextBreakName: String,
    val yearProgress: Int,
    val daysUntilSummer: Int,
    val isOnBreak: Boolean,
    val vibeEmoji: String,
    val vibeCopy: String,
    val currentClass: String?,
    val currentClassTime: String?,
    val nextClass: String?,
    val nextClassTime: String?
)

private fun loadData(ctx: Context): WidgetData {
    return try {
        val prefs = HomeWidgetPlugin.getData(ctx)
        WidgetData(
            daysUntilBreak    = prefs.getInt("days_until_break", -1),
            nextBreakName     = prefs.getString("next_break_name", null) ?: "",
            yearProgress      = prefs.getInt("year_progress", 0),
            daysUntilSummer   = prefs.getInt("days_until_summer", -1),
            isOnBreak         = prefs.getBoolean("is_on_break", false),
            vibeEmoji         = prefs.getString("vibe_emoji", null) ?: "📅",
            vibeCopy          = prefs.getString("vibe_copy", null) ?: "",
            currentClass      = prefs.getString("current_class", null),
            currentClassTime  = prefs.getString("current_class_time", null),
            nextClass         = prefs.getString("next_class", null),
            nextClassTime     = prefs.getString("next_class_time", null)
        )
    } catch (e: Exception) {
        Log.e(TAG, "loadData failed", e)
        WidgetData(
            daysUntilBreak = -1,
            nextBreakName = "",
            yearProgress = 0,
            daysUntilSummer = -1,
            isOnBreak = false,
            vibeEmoji = "📅",
            vibeCopy = "",
            currentClass = null,
            currentClassTime = null,
            nextClass = null,
            nextClassTime = null
        )
    }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
private fun formatDays(days: Int, isOnBreak: Boolean): String =
    when {
        isOnBreak -> "On"
        days < 0  -> "--"
        else      -> days.toString()
    }

private fun formatBreakLabel(name: String, isOnBreak: Boolean): String =
    if (isOnBreak) "ON BREAK!" else name.ifEmpty { "No data" }

private fun formatSummer(days: Int): String = if (days < 0) "--" else "★ $days days to summer"

private fun formatProgress(progress: Int): String = "$progress%"

// ---------------------------------------------------------------------------
// 2x1 Provider  (2 cols wide x 1 row tall)
// ---------------------------------------------------------------------------
class BreakCountWidget2x1Provider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "2x1 onUpdate, ids=${appWidgetIds.contentToString()}")
        try {
            val data = loadData(context)
            for (id in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.breakcount_widget_2x1)
                views.setTextViewText(R.id.tv_days, formatDays(data.daysUntilBreak, data.isOnBreak))
                views.setTextViewText(R.id.tv_break_label, formatBreakLabel(data.nextBreakName, data.isOnBreak))
                views.setTextViewText(R.id.tv_progress, formatProgress(data.yearProgress))
                views.setTextViewText(R.id.tv_vibe_emoji, data.vibeEmoji)
                appWidgetManager.updateAppWidget(id, views)
                Log.d(TAG, "2x1 updated id=$id")
            }
        } catch (e: Exception) {
            Log.e(TAG, "2x1 onUpdate FAILED", e)
        }
    }
}

// ---------------------------------------------------------------------------
// 2x2 Provider  (2 cols wide x 2 rows tall)
// ---------------------------------------------------------------------------
class BreakCountWidget2x2Provider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "2x2 onUpdate, ids=${appWidgetIds.contentToString()}")
        try {
            val data = loadData(context)
            for (id in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.breakcount_widget_2x2)
                views.setTextViewText(R.id.tv_days, formatDays(data.daysUntilBreak, data.isOnBreak))
                views.setTextViewText(R.id.tv_break_label, formatBreakLabel(data.nextBreakName, data.isOnBreak))
                views.setTextViewText(R.id.tv_progress, formatProgress(data.yearProgress))
                views.setProgressBar(R.id.progress_bar, 100, data.yearProgress, false)
                views.setTextViewText(R.id.tv_summer_days, formatSummer(data.daysUntilSummer))
                views.setTextViewText(R.id.tv_vibe_copy, data.vibeCopy)
                appWidgetManager.updateAppWidget(id, views)
                Log.d(TAG, "2x2 updated id=$id")
            }
        } catch (e: Exception) {
            Log.e(TAG, "2x2 onUpdate FAILED", e)
        }
    }
}

// ---------------------------------------------------------------------------
// 4x1 Provider  (4 cols wide x 1 row tall)
// ---------------------------------------------------------------------------
class BreakCountWidget4x1Provider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "4x1 onUpdate, ids=${appWidgetIds.contentToString()}")
        try {
            val data = loadData(context)
            for (id in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.breakcount_widget_4x1)
                views.setTextViewText(R.id.tv_days, formatDays(data.daysUntilBreak, data.isOnBreak))
                views.setTextViewText(R.id.tv_break_label, formatBreakLabel(data.nextBreakName, data.isOnBreak))
                views.setTextViewText(R.id.tv_progress, formatProgress(data.yearProgress))
                views.setProgressBar(R.id.progress_bar, 100, data.yearProgress, false)
                views.setTextViewText(R.id.tv_summer_days, formatSummer(data.daysUntilSummer))
                views.setTextViewText(R.id.tv_vibe_copy, data.vibeCopy)
                appWidgetManager.updateAppWidget(id, views)
                Log.d(TAG, "4x1 updated id=$id")
            }
        } catch (e: Exception) {
            Log.e(TAG, "4x1 onUpdate FAILED", e)
        }
    }
}

// ---------------------------------------------------------------------------
// 4x2 Provider  (4 cols wide x 2 rows tall) — reuses 4x1 layout
// ---------------------------------------------------------------------------
class BreakCountWidget4x2Provider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d(TAG, "4x2 onUpdate, ids=${appWidgetIds.contentToString()}")
        try {
            val data = loadData(context)
            for (id in appWidgetIds) {
                val views = RemoteViews(context.packageName, R.layout.breakcount_widget_4x1)
                views.setTextViewText(R.id.tv_days, formatDays(data.daysUntilBreak, data.isOnBreak))
                views.setTextViewText(R.id.tv_break_label, formatBreakLabel(data.nextBreakName, data.isOnBreak))
                views.setTextViewText(R.id.tv_progress, formatProgress(data.yearProgress))
                views.setProgressBar(R.id.progress_bar, 100, data.yearProgress, false)
                views.setTextViewText(R.id.tv_summer_days, formatSummer(data.daysUntilSummer))
                views.setTextViewText(R.id.tv_vibe_copy, data.vibeCopy)
                appWidgetManager.updateAppWidget(id, views)
                Log.d(TAG, "4x2 updated id=$id")
            }
        } catch (e: Exception) {
            Log.e(TAG, "4x2 onUpdate FAILED", e)
        }
    }
}
