
import Foundation

final class DateHelper {
    
    static var commonDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = .init(identifier: .gregorian)
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    static var gregorianCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale.current
        calendar.timeZone = TimeZone.current
        return calendar
    }()
    
    //禁用初始化方法
    @available(*, unavailable)
    init() {
        fatalError("DateHelper-init is unavailable")
    }
    
    
    /// Return `Date?` from given yyyyMMdd style string
    /// - Parameter from: yyyyMMdd style string
    class func dateFromyyyMMdd(_ dateString: String) -> Date? {
        commonDateFormatter.dateFormat = "yyyyMMdd"
        let date = commonDateFormatter.date(from: dateString)
        return date
    }
    
    /// 获取当前日期 无时间差
    class func nowDate() -> Date {
//        let secondFromGMT: TimeInterval = TimeInterval(TimeZone.current.secondsFromGMT(for: Date()))
 //       let nowDate = Date().addingTimeInterval(secondFromGMT)
        return Date()
        
    }
    
    /// 是否同一天
    class func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        let comparisonResult = gregorianCalendar.compare(lhs, to: rhs, toGranularity: .day)
        return comparisonResult == .orderedSame
    }
    
    /// 是否同一月
    class func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
        let comparisonResult = gregorianCalendar.compare(lhs, to: rhs, toGranularity: .month)
        return comparisonResult == .orderedSame
    }
    
    
    /// get age from yyyyMMdd
    class func getAge(_ dateString: String) -> Int {
        guard let date = self.dateFromyyyMMdd(dateString) else {
            Logger.debug("无法通过 \(dateString) 获取 Date 实例。")
            return -1
        }
        // 出生时间 年月日
        let birthYear = gregorianCalendar.component(.year, from: date)
        let birthMouth = gregorianCalendar.component(.month, from: date)
        let birthDay = gregorianCalendar.component(.day, from: date)
        
        // 当前时间 年月日
        let currentYear = gregorianCalendar.component(.year, from: Date())
        let currentMouth = gregorianCalendar.component(.month, from: Date())
        let currentDay = gregorianCalendar.component(.day, from: Date())
        
        var age: Int = currentYear - birthYear
        //如果当前日月<出生日月
        if ((birthMouth > currentMouth) || (birthMouth == currentMouth && birthDay > currentDay)){
            age -= 1
        }

        return age
    }
    
}

extension DateHelper {
    
//    判断未成年是否可以玩
    class func minorCanPaly(_ date: Date) -> Bool {
        
        let dayCanPlay = DateHelper.isUseDay(date)
        if !dayCanPlay {
            return false
        }
    
        let hour = gregorianCalendar.component(.hour, from: date)
        let minute = gregorianCalendar.component(.minute, from: date)
        
        let playTimeStart = DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayStart)
        let playTimeEnd = DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayEnd)
        
        if (hour >= playTimeStart.hour && hour < playTimeEnd.hour) || (hour == playTimeStart.hour && minute > playTimeStart.minute) || (hour == playTimeEnd.hour && minute < playTimeEnd.minute) {
            return true;
        }
        
        return false;
        
    }
    
    
    /// 获取距离下次结束时间的间隔
    /// - Returns: 单位为秒( return >= 0)
    class func intervalForMinorCanPlay(_ date: Date) -> Int {
        let endHour = DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayEnd).hour
        let endMinute = DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayEnd).minute
        
        guard let datePlay = gregorianCalendar.date(bySettingHour: endHour, minute: endMinute, second: 0, of: date) else {
            return Int.max
        }
        
        let interval = Int(max(0, datePlay.timeIntervalSince(date)))
        return interval
        
    }
    
    
    
    
    /// 判断是否宵禁时间
    class func isCurfew(_ date: Date) -> Bool {
        let hour = gregorianCalendar.component(.hour, from: date)
        let minute = gregorianCalendar.component(.minute, from: date)
        
        let curfewStart = DateHelper.timeSetFromNightStrictTimeString(AntiAddictionKit.configuration.nightStrictStart)
        let curfewEnd = DateHelper.timeSetFromNightStrictTimeString(AntiAddictionKit.configuration.nightStrictEnd)
        
        if (curfewStart.hour <= hour) || (hour < curfewEnd.hour) || (curfewStart.hour == hour && minute < curfewStart.minute) || (curfewEnd.hour == hour && minute < curfewEnd.minute) {
            return true
        }
        
        return false
    }
    
    /// 获取距离下一次宵禁的时间间隔
    /// - Returns: 单位为秒( return >= 0)
    class func intervalForNextCurfew() -> Int {
        let now = Date()
        
        //晚上22点的时间 = 24点-2小时
        let startHour = DateHelper.timeSetFromNightStrictTimeString(AntiAddictionKit.configuration.nightStrictStart).hour
        let startMinute = DateHelper.timeSetFromNightStrictTimeString(AntiAddictionKit.configuration.nightStrictStart).minute
        
        //宵禁时间
//        let startOfDay = gregorianCalendar.startOfDay(for: now)
//        var curfewStartDateComponents = gregorianCalendar.dateComponents([.year,.day, .hour, .minute, .second], from: now)
//        curfewStartDateComponents.setValue(startHour, for: .hour)
//        curfewStartDateComponents.setValue(startMinute, for: .minute)
//        curfewStartDateComponents.setValue(0, for: .second)
//        gregorianCalendar.date(from: curfewStartDateComponents)
        guard let curfewStartDate = gregorianCalendar.date(bySettingHour: startHour, minute: startMinute, second: 0, of: now) else {
            // 无法生成宵禁时间，默认返回与宵禁很大的间隔
            return Int.max
        }
        // 宵禁时间与now的时间差，如果是负数，则在宵禁时间内，返回为0。
        let interval = Int(max(0, curfewStartDate.timeIntervalSince(now)))
        return interval
    }
    
    
    /// 将整数小时 `22` 格式的字符串转化成 `时:分`格式，例如 22 -> 22:00
    class func formatCurfewHourToHHmm(_ hour: Int) -> String {
        var timeString = ""
        if hour > 10 {
            timeString = "\(hour):00"
        } else {
            timeString = "0\(hour):00"
        }
        return timeString
    }
    
    /// 将时分 `22:00` 格式的字符串转化成(小时: 22，分: 0)，24小时制
    /// - Parameter timeString: 防沉迷时间格式
    /// - Returns: 小时和分的整数集合 (小时: 22，分: 0)
    typealias NightStrictTimeSet = (hour: Int, minute: Int)
    class func timeSetFromNightStrictTimeString(_ timeString: String) -> NightStrictTimeSet {
        //检查冒号的index
        let array = timeString.components(separatedBy: ":")
        assert(array.count == 2)
        let hString: String = array[safe: 0] ?? "22"
        let mString: String = array[safe: 1] ?? "0"
        let h: Int = Int(hString) ?? 22
        let m: Int = Int(mString) ?? 0
        return NightStrictTimeSet(hour: h, minute: m)
    }
    
    
    /// 将时分 `20:00` 格式的字符串转化成(小时: 20，分: 0)，24小时制
    /// - Parameter timeString: 防沉迷时间格式
    /// - Returns: 小时和分的整数集合 (小时: 20，分: 0)
    typealias minorPlayTimeSet = (hour: Int, minute: Int)
    class func timeSetFromMinorPlayTimeString(_ timeString: String) -> minorPlayTimeSet {
//        检查冒号的index
        let array = timeString.components(separatedBy: ":")
        assert(array.count == 2)
        let hString: String = array[safe: 0] ?? "20"
        let mString: String = array[safe: 1] ?? "0"
        let h: Int = Int(hString) ?? 20
        let m: Int = Int(mString) ?? 0
        return minorPlayTimeSet(hour:h, minute:m)
     
    }
    
    
    
    
    class func isUseDay(_ date : Date) -> Bool {
       
        let holiday = DateHelper.isHoliday(date)
        if holiday {
            return true
        }
        let calendar = Calendar.current
        if let weekday = calendar.dateComponents([.weekday], from: date).weekday {
//            第一天为 周日:1  2:周一 3:周二 4：周三 5：周四 6：周五 7：周六
            let weekDayArr = ["日","一","二","三","四","五","六"]
            let dayArr = AntiAddictionKit.configuration.minorPlayDay
            var useArr = [Int]()
            
            for weekdayStr in weekDayArr {
                for dayStr in dayArr {
                    if dayStr.contains(weekdayStr) {
                        let indexForDay = weekDayArr.firstIndex(of: weekdayStr)  ?? 0
                        useArr.append(indexForDay + 1)
                    }
                }
            }
            
//            当用户可玩天数为空，进行容错处理,默认为：周五、周六、周日
            if useArr == [] {
                if weekday == 1 || weekday == 6 || weekday == 7 {
                    return true
                }
                return false
            }
            if useArr[0] == 0 {
                if weekday == 1 || weekday == 6 || weekday == 7 {
                    return true
                }
                return false
            }
            
            for dayCount in useArr {
                if weekday == dayCount {
                    return true
                }
            }
                
            

        }
        return false
        
    }
    
    
    /// 是否节假日
    class func isHoliday(_ date: Date) -> Bool {
        
        // 是否周末
        // 审核时判定周末!=节假日，因此注释周末判断逻辑
//        if date.compare(.isWeekend) {
//            return true
//        }
        
        // 是否节日
        // - TODO: 目前只有 2020 年法定节假日，新的一年节假日时间需要更新！
        let yyyy = String(gregorianCalendar.component(.year, from: date))
        commonDateFormatter.dateFormat = "MMdd"
        let MMdd = commonDateFormatter.string(from: date)
        let holiday2021: [String] = ["0101", //元旦1天
                                      "0212", "0213", "0214", //春节3天
                                     "0404", //清明1天
                                     "0501", //劳动节1天
                                     "0614", //端午节 1天
                                     "0921",   // 中秋1天
                                     "1001", "1002", "1003" //国庆 3天
            
        ]
        if yyyy == "2021" && holiday2021.contains(MMdd) {
            return true
        }
        
        // 剩余情况
        return false
    }

}
