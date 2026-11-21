import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> OrbitEntry {
        OrbitEntry(date: Date(), completionPercentage: 75, habitsCompleted: 3, habitsTotal: 4, tasksDone: 2, tasksTotal: 3)
    }

    func getSnapshot(in context: Context, completion: @escaping (OrbitEntry) -> ()) {
        let entry = readSharedOrbitData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = readSharedOrbitData()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func readSharedOrbitData() -> OrbitEntry {
        let userDefaults = UserDefaults(suiteName: "group.com.poswal.orbit")
        let percentage = userDefaults?.integer(forKey: "orbit_completion_percentage") ?? 0
        let habitsCompleted = userDefaults?.integer(forKey: "orbit_habits_completed") ?? 0
        let habitsTotal = userDefaults?.integer(forKey: "orbit_habits_total") ?? 0
        let tasksDone = userDefaults?.integer(forKey: "orbit_tasks_done") ?? 0
        let tasksTotal = userDefaults?.integer(forKey: "orbit_tasks_total") ?? 0

        return OrbitEntry(
            date: Date(),
            completionPercentage: percentage,
            habitsCompleted: habitsCompleted,
            habitsTotal: habitsTotal,
            tasksDone: tasksDone,
            tasksTotal: tasksTotal
        )
    }
}

struct OrbitEntry: TimelineEntry {
    let date: Date
    let completionPercentage: Int
    let habitsCompleted: Int
    let habitsTotal: Int
    let tasksDone: Int
    let tasksTotal: Int
}

struct OrbitWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.12)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Orbit Today")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.08, green: 0.84, blue: 0.72)) // Teal accent
                    Spacer()
                    Text("\(entry.completionPercentage)%")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading) {
                        Text("Habits")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.gray)
                        Text("\(entry.habitsCompleted)/\(entry.habitsTotal)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    VStack(alignment: .leading) {
                        Text("Tasks")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Color.gray)
                        Text("\(entry.tasksDone)/\(entry.tasksTotal)")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
        }
    }
}

@main
struct OrbitWidget: Widget {
    let kind: String = "OrbitWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            OrbitWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Poswal Orbit Today")
        .description("Track your daily habits and tasks at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
