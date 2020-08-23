import Foundation

extension Date {
    private static let dayTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter
    }()

	private static let timeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "HH:mm"
		return formatter
	}()

    private static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func timeStamp() -> String {
        return "\(self.timeIntervalSince1970 * 1_000)"
    }

    func toTimeString() -> String {
        return Date.timeFormatter.string(from: self)
    }

    func toDayString() -> String {
        return Date.dayFormatter.string(from: self)
    }

    func toDayTimeString() -> String {
        return Date.timeFormatter.string(from: self)
    }

    func isSameDay(as date2: Date) -> Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = NSLocale.current
        let day: DateComponents? = calendar.dateComponents([.era, .year, .month, .day], from: self)
        let day2: DateComponents? = calendar.dateComponents([.era, .year, .month, .day], from: date2)
        return (day2?.day! == day?.day! && day2?.month! == day?.month! && day2?.year! == day?.year! && day2?.era! == day?.era!)
    }

    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int? {
        let currentCalendar = Calendar.current

        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return nil }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return nil }

        return abs(end - start)
    }
    

    static func parse(string: String) -> Date? {
        if let date = dayFormatter.date(from: string) {
            return date
        } else if let date = dayTimeFormatter.date(from: string) {
            return date
        } else if let date = timeFormatter.date(from: string) {
            return date
        } else if let date = yearFormatter.date(from: string) {
            return date
        }
        
        return nil
    }
}
