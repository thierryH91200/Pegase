//
//  NVDate.swift
//  NVDate
//
//  Created by Noval Agung Prayogo on 11/10/15.
//  Copyright © 2015 Noval Agung Prayogo. All rights reserved.
//

import AppKit

class NVDate: NSObject {
    
//    public enum DayName: Int {
//        case sunday = 1
//        case monday = 2
//        case tuesday = 3
//        case wednesday = 4
//        case thursday = 5
//        case friday = 6
//        case saturday = 7
//    }
//    private var _dayNames: [DayName] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
    
//    public enum MonthName: Int {
//        case january = 1
//        case february = 2
//        case march = 3
//        case april = 4
//        case may = 5
//        case june = 6
//        case july = 7
//        case august = 8
//        case september = 9
//        case october = 10
//        case november = 11
//        case december = 12
//    }
//    private var _monthsNames: [MonthName] = [.january, .february, .march, .april, .may, .june, .july, .august, .september, .october, .november, .december]
    
    // ============= private props

    fileprivate var _date: Date?
    fileprivate var _dateFormatter: DateFormatter = DateFormatter()
    fileprivate var _calendar = Calendar.current
    fileprivate var _calendarNameDateTime: Set<Calendar.Component> = [.year, .month, .weekOfYear, .weekOfMonth, .weekday, .day, .hour, .minute, .second]
//    fileprivate var _calendarNameDateOnly: Set<Calendar.Component> = [.year, .month, .day]
    fileprivate var _timeZone = NSTimeZone.local
    
    // ============= private funcs
    
    fileprivate func _dateComponentsFromCurrentDate() -> DateComponents {
        return _calendar.dateComponents(_calendarNameDateTime, from: _date!)
    }
    
    fileprivate func _dateComponentsFromCurrentDate(calendarName: Set<Calendar.Component>) -> DateComponents {
        return _calendar.dateComponents(calendarName, from: _date!)
    }
    
    fileprivate func _dateByAddingComponentsToCurrentDate(_ components: DateComponents) -> Date? {
        if _date != nil {
            return _calendar.date(byAdding: components, to: _date!, wrappingComponents: false)
        }
        
        return _date
    }
    
    fileprivate func _dateByAddingDay(days: Int, isForward: Bool) -> NVDate {
        if _date != nil {
            var components = DateComponents()
            components.day = days * (isForward ? 1 : -1)
            _date = _dateByAddingComponentsToCurrentDate(components)
        }
        
        return self
    }
    
//    fileprivate func _dateByAddingWeek(weeks: Int, isForward: Bool) -> NVDate {
//        if _date != nil {
//            var components = DateComponents()
//            components.day = (7 * weeks) * (isForward ? 1 : -1)
//            _date = _dateByAddingComponentsToCurrentDate(components)
//        }
//
//        return self
//    }
    
//    fileprivate func _dateByAddingMonth(months: Int, isForward: Bool) -> NVDate {
//        if _date != nil {
//            var components = DateComponents()
//            components.month = months * (isForward ? 1 : -1)
//            _date = _dateByAddingComponentsToCurrentDate(components)
//        }
//
//        return self
//    }
//
//    fileprivate func _dateByAddingYear(years: Int, isForward: Bool) -> NVDate {
//        if _date != nil {
//            var components = DateComponents()
//            components.year = years * (isForward ? 1 : -1)
//            _date = _dateByAddingComponentsToCurrentDate(components)
//        }
//
//        return self
//    }
    
    // ============= init
    
    override init() {
        super.init()
        
        _dateFormatter.dateStyle = .full
        _dateFormatter.timeStyle = .full
        _dateFormatter.timeZone = _timeZone
        
        _calendar.timeZone = _timeZone
        
        _date = Date()
    }
    
    convenience init(fromString: String, withFormat: String) {
        self.init()
        
        let df = DateFormatter()
        df.dateFormat = withFormat
        
        _dateFormatter.dateFormat = withFormat
        _date = _dateFormatter.date(from: fromString)
    }
    
    convenience init(year: Int, month: Int, day: Int) {
        self.init()
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        
        _date = _calendar.date(from: components)
    }

    convenience init(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        self.init()
        
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.second = second
        
        _date = _calendar.date(from: components)
    }
    
    convenience init(fromDate: Date) {
        self.init()
        
        _date = fromDate
    }
    
    convenience init(fromTimeIntervalSinceReferenceDate: TimeInterval) {
        self.init()
        
        _date = Date(timeIntervalSinceReferenceDate: fromTimeIntervalSinceReferenceDate)
    }
    
    // ============= public functions
    
    func date() -> Date? {
        return _date
    }
    
    func asString() -> String {
        if _date != nil {
            return _dateFormatter.string(from: _date!)
        }
        
        return ""
    }
    
    func asString(withFormat: String) -> String {
        let localDateFormatter = _dateFormatter.copy() as! DateFormatter
        localDateFormatter.dateFormat = withFormat
        
        if _date != nil {
            return localDateFormatter.string(from: _date!)
        }
        
        return ""
    }
    
//    func setTimeAsZero() -> NVDate {
//        if _date != nil {
//            var components = _dateComponentsFromCurrentDate(calendarName: _calendarNameDateOnly)
//            components.hour = 0
//            components.minute = 0
//            components.second = 0
//
//            _date = _calendar.date(from: components)
//        }
//
//        return self
//    }
    
    func dateFormat() -> String {
        return _dateFormatter.dateFormat
    }
    
    func dateFormat(setFormat: String) {
        _dateFormatter.dateFormat = setFormat
    }
    
    func dateStyle() -> DateFormatter.Style {
        return _dateFormatter.dateStyle
    }
    
    func dateStyle(setStyle: DateFormatter.Style) {
        _dateFormatter.dateStyle = setStyle
    }
    
    func timeStyle() -> DateFormatter.Style {
        return _dateFormatter.timeStyle
    }
    
    func timeStyle(setStyle: DateFormatter.Style) {
        _dateFormatter.timeStyle = setStyle
    }
    
    func timeZone() -> TimeZone {
        return _timeZone
    }
    
    func timeZone(setTimeZone: TimeZone) {
        _timeZone = setTimeZone
        _calendar.timeZone = setTimeZone
        _dateFormatter.timeZone = setTimeZone
    }
    
    // ================ date and time related functions
    
    func nextDays(days: Int) -> NVDate {
        return _dateByAddingDay(days: days, isForward: true)
    }
    
    func nextDay() -> NVDate {
        return nextDays(days: 1)
    }
    
    func tomorrow() -> NVDate {
        return nextDay()
    }
    
    func previousDays(diff: Int) -> NVDate {
        return _dateByAddingDay(days: diff, isForward: false)
    }
    
    func previousDay() -> NVDate {
        return previousDays(diff: 1)
    }
    
    func yesterday() -> NVDate {
        return previousDay()
    }
    
//    func nextWeeks(diff: Int) -> NVDate {
//        return _dateByAddingWeek(weeks: diff, isForward: true)
//    }
    
//    func nextWeek() -> NVDate {
//        return nextWeeks(diff: 1)
//    }
    
//    func previousWeeks(diff: Int) -> NVDate {
//        return _dateByAddingWeek(weeks: diff, isForward: false)
//    }
    
//    func previousWeek() -> NVDate {
//        return previousWeeks(diff: 1)
//    }
    
//    func nextMonths(diff: Int) -> NVDate {
//        return _dateByAddingMonth(months: diff, isForward: true)
//    }
    
//    func nextMonth() -> NVDate {
//        return nextMonths(diff: 1)
//    }
    
//    func previousMonths(diff: Int) -> NVDate {
//        return _dateByAddingMonth(months: diff, isForward: false)
//    }
    
//    func previousMonth() -> NVDate {
//        return previousMonths(diff: 1)
//    }
    
//    func nextYears(diff: Int) -> NVDate {
//        return _dateByAddingYear(years: diff, isForward: true)
//    }
    
//    func nextYear() -> NVDate {
//        return nextYears(diff: 1)
//    }
    
//    func previousYears(diff: Int) -> NVDate {
//        return _dateByAddingYear(years: diff, isForward: false)
//    }
    
//    func previousYear() -> NVDate {
//        return previousYears(diff: 1)
//    }
    
//    func firstDayOfMonth() -> NVDate {
//        if _date != nil {
//            var components = _dateComponentsFromCurrentDate()
//            components.day = 1
//            _date = _calendar.date(from: components)
//        }
//        return self
//    }
//
//    func lastDayOfMonth() -> NVDate {
//        if _date != nil {
//            var components = _dateComponentsFromCurrentDate()
//            components.day = 1
//            _date = _calendar.date(from: components)
//
//            components = DateComponents()
//            components.month = 1
//            _date = _dateByAddingComponentsToCurrentDate(components)
//
//            components = DateComponents()
//            components.day = -1
//            _date = _dateByAddingComponentsToCurrentDate(components)
//        }
//
//        return self
//    }
    
//    func firstMonthOfYear() -> NVDate {
//        if _date != nil {
//            var components = _dateComponentsFromCurrentDate()
//            components.month = MonthName.january.rawValue
//            _date = _calendar.date(from: components)
//        }
//
//        return self
//    }
//
//    func lastMonthOfYear() -> NVDate {
//        if _date != nil {
//            var components = _dateComponentsFromCurrentDate()
//            components.month = MonthName.december.rawValue
//            _date = _calendar.date(from: components)
//        }
//
//        return self
//    }
    
//    func nearestPreviousDay(_ dayName: DayName) -> NVDate {
//        if _date != nil {
//
//            var components = _dateComponentsFromCurrentDate()
//            if let currentWeekDay = components.weekday {
//
//                if currentWeekDay == dayName.rawValue {
//                    return self.previousWeek()
//                }
//
//                components = DateComponents()
//
//                if currentWeekDay > dayName.rawValue {
//                    components.day = -(currentWeekDay - dayName.rawValue)
//                } else {
//                    components.day = -currentWeekDay - (7 - dayName.rawValue)
//                }
//
//                _date = _dateByAddingComponentsToCurrentDate(components)
//            }
//        }
//
//        return self
//    }
//
//    func nearestNextDay(_ dayName: DayName) -> NVDate {
//        if _date != nil {
//
//            var components = _dateComponentsFromCurrentDate()
//            if let currentWeekDay = components.weekday {
//
//                if currentWeekDay == dayName.rawValue {
//                    return self.nextWeek()
//                }
//
//                components = DateComponents()
//
//                if currentWeekDay < dayName.rawValue {
//                    components.day = dayName.rawValue - currentWeekDay
//                } else {
//                    components.day = 7 - (currentWeekDay - dayName.rawValue)
//                }
//
//                _date = _dateByAddingComponentsToCurrentDate(components)
//            }
//        }
//
//        return self
//    }
    
//    func thisDayName() -> DayName {
//        if _date != nil {
//            let components = _dateComponentsFromCurrentDate()
//
//            for dayName in _dayNames {
//                if dayName.rawValue == components.weekday {
//                    return dayName
//                }
//            }
//        }
//
//        return DayName.sunday
//    }

//    func todayName() -> DayName {
//        return thisDayName()
//    }
    
//    func isThisDayName(_ dayName: DayName) -> Bool {
//        if _date != nil {
//            let components = _dateComponentsFromCurrentDate()
//            return components.weekday == dayName.rawValue
//        }
//
//        return false
//    }
    
//    func isTodayName(_ dayName: DayName) -> Bool {
//        return isThisDayName(dayName)
//    }
    
//    func thisMonthName() -> MonthName {
//        if _date != nil {
//            let components = _dateComponentsFromCurrentDate()
//
//            for monthName in _monthsNames {
//                if monthName.rawValue == components.month {
//                    return monthName
//                }
//            }
//        }
//
//        return MonthName.january
//    }
    
//    func isThisMonthName(_ monthName: MonthName) -> Bool {
//        let components = _dateComponentsFromCurrentDate()
//        return components.month == monthName.rawValue
//    }
    
    func year() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.year!
    }
    
    func year(setYear: Int) {
        var components = _dateComponentsFromCurrentDate()
        components.year = setYear
        
        _date = _calendar.date(from: components)
    }
    
    func month() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.month!
    }
    
    func month(setMonth: Int) {
        var components = _dateComponentsFromCurrentDate()
        components.month = setMonth
        
        _date = _calendar.date(from: components)
    }
    
    func weekOfYear() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.weekOfYear!
    }
    
    func weekOfMonth() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.weekOfMonth!
    }
    
    func day() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.day!
    }
    
    func day(setDay: Int) {
        var components = _dateComponentsFromCurrentDate()
        components.day = setDay
        
        _date = _calendar.date(from: components)
    }
    
    func hour() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.hour!
    }
    
    func hour(setHour: Int) {
        var components = _dateComponentsFromCurrentDate()
        components.hour = setHour
        
        _date = _calendar.date(from: components)
    }
    
    func minute() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.minute!
    }
    
    func minute(setMinute: Int) {
        var components = _dateComponentsFromCurrentDate()
        components.minute = setMinute
        
        _date = _calendar.date(from: components)
    }
    
    func second() -> Int {
        let components = _dateComponentsFromCurrentDate()
        return components.second!
    }
    
    func second(setSecond: Int) {
        var components = _dateComponentsFromCurrentDate()
        components.second = setSecond
        
        _date = _calendar.date(from: components)
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the amount of nanoseconds from another date
    func nanoseconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.nanosecond], from: date, to: self).nanosecond ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        if nanoseconds(from: date) > 0 { return "\(nanoseconds(from: date))ns" }
        return ""
    }
}


