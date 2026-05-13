package com.breakcount.app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
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
    val nextClassTime: String?,
    val themePrimaryHex: String,
    val themeBgHex: String,
    val themeSurfaceHex: String,
    val personaTintHex: String,
    val themeDark: Boolean
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
            nextClassTime     = prefs.getString("next_class_time", null),
            themePrimaryHex   = prefs.getString("theme_primary_hex", null) ?: "#6F4E37",
            themeBgHex        = prefs.getString("theme_bg_hex", null) ?: "#FDFAF7",
            themeSurfaceHex   = prefs.getString("theme_surface_hex", null) ?: "#FFFFFF",
            personaTintHex    = prefs.getString("persona_tint_hex", null) ?: "#6F4E37",
            themeDark         = prefs.getBoolean("theme_dark", false)
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
            nextClassTime = null,
            themePrimaryHex = "#6F4E37",
            themeBgHex = "#FDFAF7",
            themeSurfaceHex = "#FFFFFF",
            personaTintHex = "#6F4E37",
            themeDark = false
        )
    }
}

private fun safeParseColor(hex: String, fallback: Int): Int = try {
    Color.parseColor(hex)
} catch (_: Exception) {
    fallback
}

private fun withAlpha(color: Int, alpha: Int): Int =
    Color.argb(alpha, Color.red(color), Color.green(color), Color.blue(color))

/// Applies full theme colors to the widget: background, primary text, accent, secondary text.
private fun applyThemeColors(views: RemoteViews, data: WidgetData) {
    val surface = safeParseColor(data.themeSurfaceHex, Color.WHITE)
    val primary = safeParseColor(data.themePrimaryHex, Color.parseColor("#6F4E37"))
    val accent = safeParseColor(data.personaTintHex, primary)
    val secondary = withAlpha(primary, 153) // ~60% alpha

    // Background
    try { views.setInt(R.id.widget_root, "setBackgroundColor", surface) } catch (_: Exception) {}

    // Primary text
    try { views.setTextColor(R.id.tv_days, primary) } catch (_: Exception) {}
    try { views.setTextColor(R.id.tv_break_label, primary) } catch (_: Exception) {}

    // Accent text (progress)
    try { views.setTextColor(R.id.tv_progress, accent) } catch (_: Exception) {}

    // Secondary text
    try { views.setTextColor(R.id.tv_vibe_copy, secondary) } catch (_: Exception) {}
    try { views.setTextColor(R.id.tv_summer_days, secondary) } catch (_: Exception) {}
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
// 2x1 Provider
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
                applyThemeColors(views, data)
                appWidgetManager.updateAppWidget(id, views)
            }
        } catch (e: Exception) {
            Log.e(TAG, "2x1 onUpdate FAILED", e)
        }
    }
}

// ---------------------------------------------------------------------------
// 2x2 Provider
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
                applyThemeColors(views, data)
                appWidgetManager.updateAppWidget(id, views)
            }
        } catch (e: Exception) {
            Log.e(TAG, "2x2 onUpdate FAILED", e)
        }
    }
}

// ---------------------------------------------------------------------------
// 4x1 Provider
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
                applyThemeColors(views, data)
                appWidgetManager.updateAppWidget(id, views)
            }
        } catch (e: Exception) {
            Log.e(TAG, "4x1 onUpdate FAILED", e)
        }
    }
}

// ---------------------------------------------------------------------------
// 4x2 Provider — reuses 4x1 layout
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
                applyThemeColors(views, data)
                appWidgetManager.updateAppWidget(id, views)
            }
        } catch (e: Exception) {
            Log.e(TAG, "4x2 onUpdate FAILED", e)
        }
    }
}
