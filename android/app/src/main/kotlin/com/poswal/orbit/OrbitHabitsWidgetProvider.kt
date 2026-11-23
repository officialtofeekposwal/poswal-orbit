package com.poswal.orbit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class OrbitHabitsWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.orbit_habits_widget).apply {
                val completed = widgetData.getString("orbit_completed_habits", "0")
                val total = widgetData.getString("orbit_total_habits", "0")
                val habitsJsonStr = widgetData.getString("orbit_habits_json", "[]")

                setTextViewText(R.id.widget_habits_title, context.getString(R.string.widget_habits_title))
                setTextViewText(R.id.widget_habits_count, "$completed of $total")

                val rowIds = intArrayOf(R.id.habit_row_1, R.id.habit_row_2, R.id.habit_row_3, R.id.habit_row_4)
                val checkIds = intArrayOf(R.id.habit_check_1, R.id.habit_check_2, R.id.habit_check_3, R.id.habit_check_4)
                val titleIds = intArrayOf(R.id.habit_title_1, R.id.habit_title_2, R.id.habit_title_3, R.id.habit_title_4)

                try {
                    val jsonArray = JSONArray(habitsJsonStr)
                    if (jsonArray.length() == 0) {
                        setViewVisibility(R.id.widget_habits_empty, View.VISIBLE)
                        for (rowId in rowIds) setViewVisibility(rowId, View.GONE)
                    } else {
                        setViewVisibility(R.id.widget_habits_empty, View.GONE)
                        for (i in 0 until 4) {
                            if (i < jsonArray.length()) {
                                val item = jsonArray.getJSONObject(i)
                                val habitId = item.optString("id", "")
                                val habitName = item.optString("name", "")
                                val isCompleted = item.optBoolean("isCompleted", false)

                                setViewVisibility(rowIds[i], View.VISIBLE)
                                setTextViewText(titleIds[i], habitName)
                                setImageViewResource(
                                    checkIds[i],
                                    if (isCompleted) R.drawable.widget_circle_checked else R.drawable.widget_circle_unchecked
                                )

                                // Tap check circle: triggers background check-off broadcast callback
                                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                                    context,
                                    Uri.parse("orbit://checkin?habitId=$habitId")
                                )
                                setOnClickPendingIntent(checkIds[i], backgroundIntent)

                                // Tap row: launches app to view habit
                                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                                    data = Uri.parse("orbit://habit?id=$habitId")
                                }
                                val openAppPending = PendingIntent.getActivity(
                                    context,
                                    i + 100,
                                    openAppIntent,
                                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                                )
                                setOnClickPendingIntent(titleIds[i], openAppPending)
                            } else {
                                setViewVisibility(rowIds[i], View.GONE)
                            }
                        }
                    }
                } catch (e: Exception) {
                    setViewVisibility(R.id.widget_habits_empty, View.VISIBLE)
                }

                // Default container tap opens app
                val defaultIntent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val defaultPending = PendingIntent.getActivity(
                    context,
                    0,
                    defaultIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_habits_container, defaultPending)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}