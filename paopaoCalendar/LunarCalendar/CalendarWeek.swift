//
//  CalendarWeek.swift
//  CalendarCard
//
//  Created by iOS on 2021/1/19.
//

import SwiftUI

public struct CalendarWeek: View {
    
    //@State private var labelText = "Hello, World!"
    var labelText: String
    public var body: some View {

        //Text(Tool.getDay(date: Date())+"年")
        Text(String(labelText))
        //CalendarGrid()
        HStack{
            ForEach(1...7, id: \.self) { count in
                Text(Tool.getWeek(week: count))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
}


