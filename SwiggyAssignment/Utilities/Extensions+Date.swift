//
//  Extensions+Date.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//
import Foundation

extension Date {
    func smartFormatted() -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        let calendar = Calendar.current
        
        if timeInterval < 60 {
            return "Just now"
        }
        
        if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        }
        
        if calendar.isDateInToday(self) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Today at \(formatter.string(from: self))"
        }
        
        if calendar.isDateInYesterday(self) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "Yesterday at \(formatter.string(from: self))"
        }
        
        if timeInterval < 7 * 24 * 3600 {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE 'at' h:mm a"
            return formatter.string(from: self)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: self)
    }
}
