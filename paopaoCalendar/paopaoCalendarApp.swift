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
                print("这里返回的居然是用户点击的日期的时间,好像目前没什么用==\(date)")
            })
        }
    }
}
