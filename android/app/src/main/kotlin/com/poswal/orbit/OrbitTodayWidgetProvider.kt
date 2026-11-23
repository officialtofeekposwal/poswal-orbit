package com.poswal.orbit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class OrbitTodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.orbit_today_widget).apply {
                val completed = widgetData.getString("orbit_completed_habits", "0")
                val total = widgetData.getString("orbit_total_habits", "0")
                val percentStr = widgetData.getString("orbit_progress_percent", "0")
                val percent = percentStr?.toIntOrNull() ?: 0

                setTextViewText(R.id.widget_orbit_title, context.getString(R.string.widget_today_title))
                setTextViewText(R.id.widget_orbit_count, "$completed of $total")
                setTextViewText(R.id.widget_orbit_percent, "$percent%")
                setProgressBar(R.id.widget_orbit_progressbar, 100, percent, false)

                // Launch main app when tapping widget
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingIntent = PendingIntent.getActivity(
                    context,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_container, pendingIntent)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
