//
//  paopaoCalendarApp.swift
//  paopaoCalendar
//
//  Created by Ethan on 3/24/24.
//

import SwiftUI

@main
struct paopaoCalendarApp: App {
    var body: some Scene {
        WindowGroup {
            //ContentView()
            LunarCalendar(select: { date in
                print("启动显示时间==\(date)")
            })
        }
    }
}
