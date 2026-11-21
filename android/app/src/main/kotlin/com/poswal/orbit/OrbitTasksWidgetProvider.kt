package com.poswal.orbit

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class OrbitTasksWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.orbit_tasks_widget).apply {
                val tasksJsonStr = widgetData.getString("orbit_tasks_json", "[]")

                setTextViewText(R.id.widget_tasks_title, "Poswal Orbit · Tasks")

                val rowIds = intArrayOf(R.id.task_row_1, R.id.task_row_2, R.id.task_row_3, R.id.task_row_4)
                val dotIds = intArrayOf(R.id.task_dot_1, R.id.task_dot_2, R.id.task_dot_3, R.id.task_dot_4)
                val titleIds = intArrayOf(R.id.task_title_1, R.id.task_title_2, R.id.task_title_3, R.id.task_title_4)

                try {
                    val jsonArray = JSONArray(tasksJsonStr)
                    setTextViewText(R.id.widget_tasks_count, "${jsonArray.length()} pending")

                    if (jsonArray.length() == 0) {
                        setViewVisibility(R.id.widget_tasks_empty, View.VISIBLE)
                        for (rowId in rowIds) setViewVisibility(rowId, View.GONE)
                    } else {
                        setViewVisibility(R.id.widget_tasks_empty, View.GONE)
                        for (i in 0 until 4) {
                            if (i < jsonArray.length()) {
                                val item = jsonArray.getJSONObject(i)
                                val taskId = item.optString("id", "")
                                val taskTitle = item.optString("title", "")

                                setViewVisibility(rowIds[i], View.VISIBLE)
                                setTextViewText(titleIds[i], taskTitle)

                                // Tap task: opens app to focus on the task
                                val openAppIntent = Intent(context, MainActivity::class.java).apply {
                                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                                    data = Uri.parse("orbit://task?id=$taskId")
                                }
                                val openAppPending = PendingIntent.getActivity(
                                    context,
                                    i + 200,
                                    openAppIntent,
                                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                                )
                                setOnClickPendingIntent(rowIds[i], openAppPending)
                            } else {
                                setViewVisibility(rowIds[i], View.GONE)
                            }
                        }
                    }
                } catch (e: Exception) {
                    setViewVisibility(R.id.widget_tasks_empty, View.VISIBLE)
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
                setOnClickPendingIntent(R.id.widget_tasks_container, defaultPending)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}