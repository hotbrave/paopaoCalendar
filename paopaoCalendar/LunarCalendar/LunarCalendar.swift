
import SwiftUI

public struct LunarCalendar : View{
    @Environment(\.calendar) var calendar
    @Environment(\.presentationMode) var mode
    
    /**
     获取今年的时间间隔用于展示日历，需要修改
     */
    private var currentyear: DateInterval {
        calendar.dateInterval(of: .year, for: Date())!
    }
    //改成获取最近10年的时间间隔
    private var lastTenYears: DateInterval {
        let currentDate = Date()
        let calendar = Calendar.current
        let tenYearsAgo = calendar.date(byAdding: .year, value: -1, to: currentDate)!
        let tenYearsLater = calendar.date(byAdding: .year, value: 1, to: currentDate)!
        return DateInterval(start: tenYearsAgo, end: tenYearsLater)
    }
    
    private let onSelect: (Date) -> Void
    
    public init(select: @escaping (Date) -> Void) {
      self.onSelect = select
    }
    
    public var body: some View {
        
        VStack(alignment: .center, spacing: 0, content: {
            CalendarWeek()
                .frame(height: 30.0)
            
            //这里初始化日历启动时显示的时间范围
            CalendarGrid(interval: lastTenYears) { date in
                
                CalenderDay(day: Tool.getDay(date: date),
                            lunar: Tool.getInfo(date: date),
                            isToday: calendar.isDateInToday(date),
                            isWeekDay: Tool.isWeekDay(date: date))
                    .onTapGesture {//点击视图的事件
                        mode.wrappedValue.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.onSelect(date)
                            print("Clicked date: \(date)") // 打印点击的日期
                        }
                    }
            }
        })
        .padding([.leading, .trailing], 10.0)
        
    }
}

struct LunarCalendar_Previews: PreviewProvider {
    static var previews: some View {
        LunarCalendar(select: {_ in
            
        })
    }
}
