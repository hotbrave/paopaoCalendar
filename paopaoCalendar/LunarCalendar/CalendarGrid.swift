//
//  CalendarView.swift
//  CalendarCard
//
//  Created by iOS on 2021/1/18.
//

import SwiftUI
import os.log

public struct CalendarGrid<DateView>: View where DateView: View {
    @Environment(\.calendar) var calendar
    
    
    @State private var scrollProxy: ScrollViewProxy?
    @State private var gridHeight: CGFloat = 0   //网格高度
    @State private var gridHeighttemp2: CGFloat = 0   //网格高度
    
    @State private var visibleSectionID: Int? = nil//根据chatgpt加的获取当前屏幕显示的月份的sectionID用的
    
    //@State private var labelText : String = "Hello, World2233!"
    
    let interval: DateInterval   //时间间隔
    let showHeaders: Bool      //是否显示每月的title
    let content: (Date) -> DateView
    
    @Binding var weekLabelText: String
    //let log=OSLog(subsystem: "com.paopaobox.calendar", category: "YourCategory")
    
    public init(interval: DateInterval, showHeaders: Bool = true,weekLabelText: Binding<String>, @ViewBuilder content: @escaping (Date) -> DateView) {
        self.interval = interval
        self.showHeaders = showHeaders
        self.content = content
        self._weekLabelText = weekLabelText
    }
    
    public var body: some View {

        ///添加到可以滚动
        ScrollView(.vertical, showsIndicators: false){
            ///添加滚动监听
            ScrollViewReader { (proxy: ScrollViewProxy) in
                ///生成网格
                LazyVGrid(columns: Array(repeating: GridItem(spacing: 2, alignment: .center), count: 7)) {
                    ///枚举每个月
                    ForEach(arrayMonths, id: \.self) { month in
                        ///以每月为一个Section,添加月份
                        Section(header: getHeader(for: month)) {
                            ///添加日
                            //var loopCount = 0 // 定义一个计数器
                            
                            ForEach(getDays(for: month), id: \.self) { date in
                                ///如果不在当月就隐藏
                                
                                if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                                    content(date).id(date)
                                    
                                } else {
                                    content(date).hidden()//每个月初和月末的空的空格子
                                }

                            }
                        }
                        .id(getYearMonthSectionID(for: month))//修改成用年和月做SectionID
                        
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(key: SectionIDPreferenceKey.self, value: getYearMonthSectionID(for: month))
                            }
                        )
                        
                    }
                }
                .onPreferenceChange(SectionIDPreferenceKey.self) { value in
                    visibleSectionID = value
                   // print("Visible Section ID: \(visibleSectionID ?? -1)")
                    
                    if let visibleSectionIDtemp = visibleSectionID {
                        var year = visibleSectionIDtemp / 100 // 假设整数部分代表年份
                        var month = visibleSectionIDtemp % 100 // 假设百位数代表月份
                        //print("Visible Section Year: \(year), Month: \(month)")
                        
                        if month != 12 {
                            month += 1 // 如果不等于 12，则加 1
                        } else {
                            year += 1
                            month = 1 // 如果等于 12，则设置为 1
                        }
                        
                        //weekLabelText = "\(year)年\(month)月"
                        weekLabelText = "\(year)年"
                        
                    } else {
                        print("Visible Section ID is nil.")
                    }
                    
                }
                .onAppear(){
                    ///当View展示的时候直接滚动到标记好的月份
                    print("当View展示的时候直接滚动到标记好的月份")
                    //os_log("test",log: log,type: .debug)
                    proxy.scrollTo(getYearMonthScroolSectionID() )
                }
                

                Text("LazyVGrid Height: \(gridHeight)")
                Text("LazyVGrid gridHeighttemp2: \(gridHeighttemp2)")
                // 在闭包外部输出 month 变量的值
                /*
                let monthsString = arrayMonths.map { month in
                    return "\(month)"
                }
                Text("所有月份的值：\(monthsString)")
                */
            }
        }
        
    }

    
    ///获取当前是几年几月,并进行滚动到那里
    private func getYearMonthScroolSectionID() -> Int {
        var year = calendar.component(.year, from: Date())
        var month = calendar.component(.month, from: Date())
        
        //year=2025
        //month=1
        
        if month != 12 {
            month += 1 // 如果不等于 12，则加 1
        } else {
            year += 1
            month = 1 // 如果等于 12，则设置为 1
        }
        print("当前GMT格林尼治标准时间日期是：\(Date())")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current // 使用当前时区

        let localDate = dateFormatter.string(from: Date())
        print("当前本地日期是：\(localDate)")
        
        // 将年和月组合成一个唯一的整数作为滚动标记的 section ID
        let sectionID = year * 100 + month
        print("getYearMonthScroolSectionID====\(sectionID)")
        return sectionID
    }
    
    
    
    ///根据月份生成SectionID，可能废弃不用了
    /*
    private func getSectionID(for month: Date) -> Int {
        let component = calendar.component(.month, from: month)
        print("componentget===\(component)")//这个就是实际的月份，不用+1
        return component
    }
    */
    
    /// 根据年月生成 Section ID
    private func getYearMonthSectionID(for date: Date) -> Int {
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        // 将年和月组合成一个唯一的整数作为 Section ID
        let sectionID = year * 100 + month
        //print("sectionID====\(sectionID)")
        return sectionID
    }
    
    
    ///获得年间距的月份日期的第一天,生成数组
    private var arrayMonths: [Date] {
        calendar.getGenerateDates(
            inside: interval,
            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
        )
    }
    
    
    ///创建一个简单的SectionHeader
    private func getHeader(for month: Date) -> some View {
        let component = calendar.component(.month, from: month)
        let formatter = component == 1 ? DateFormatter.getDFmonthAndYear : .getDFmonth
        
        return Group {
            if showHeaders {
                Text(formatter.string(from: month))
                    .font(.title)
                    .padding()
            }
        }
    }
    
    
    ///获取每个月,网格范围内的起始结束日期数组
    private func getDays(for month: Date) -> [Date] {
        ///重点讲解
        ///先拿到月份间距,例如1号--31号
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        ///先获取第一天所在周的周一到周日
        let monthFirstWeek = monthInterval.start.getWeekStartAndEnd(isEnd: false)
        ///获取月最后一天所在周的周一到周日
        let monthLastWeek = monthInterval.end.getWeekStartAndEnd(isEnd: true)
        ///然后根据月初所在周的周一为0号row 到月末所在周的周日为最后一个row生成数组
        return calendar.getGenerateDates(
            inside: DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end),
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }

}






//根据chatgpt加的获取当前屏幕显示的月份的sectionID用的
struct SectionIDPreferenceKey: PreferenceKey {
    static var defaultValue: Int? = nil

    static func reduce(value: inout Int?, nextValue: () -> Int?) {
        value = value ?? nextValue()
    }
}


extension Date {
    
    func getWeekDay() -> Int{
        let calendar = Calendar.current
        ///拿到现在的week数字
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday!
    }
    
    ///获取当前Date所在周的周一到周日
    func getWeekStartAndEnd(isEnd: Bool) -> DateInterval{
        var date = self
        ///因为一周的起始日是周日,周日已经算是下一周了
        ///如果是周日就到退回去两天
        if isEnd {
            if date.getWeekDay() <= 2 {
                date = date.addingTimeInterval(-60 * 60 * 24 * 2)
            }
        }else{
            if date.getWeekDay() == 1 {
                date = date.addingTimeInterval(-60 * 60 * 24 * 2)
            }
        }
        ///使用处理后的日期拿到这一周的间距: 周日到周六
        let week = Calendar.current.dateInterval(of: .weekOfMonth, for: date)!
        ///处理一下周日加一天到周一
        let monday = week.start.addingTimeInterval(60 * 60 * 24)
        ///周六加一天到周日
        let sunday = week.end.addingTimeInterval(60 * 60 * 24)
        ///生成新的周一到周日的间距
        let interval = DateInterval(start: monday, end: sunday)
        return interval
    }
}

extension DateFormatter {
    
    static var getDFmonth: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        return formatter
    }
    
    static var getDFmonthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }
}

extension Calendar {
    func getGenerateDates(inside interval: DateInterval, matching components: DateComponents) -> [Date] {
        var dates: [Date] = []
        
        dates.append(interval.start)
        
        enumerateDates(startingAfter: interval.start, matching: components, matchingPolicy: .nextTime) { date, _, stop in
            if let date = date {
                if date < interval.end {
                    dates.append(date)
                } else {
                    stop = true
                }
            }
        }
        return dates
    }
}

// 根据当前设备显示模式返回对应的颜色方案
/*
func schemeForCurrentDisplayMode() -> ColorScheme {
    if UITraitCollection.current.userInterfaceStyle == .dark {
        return .dark // 如果当前是 Dark Mode，则返回 Dark 颜色方案
    } else {
        return .light // 如果当前是 Light Mode，则返回 Light 颜色方案
    }
}
*/
