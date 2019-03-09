//
//  Util.swift
//  Phind
//
//  Created by Kevin Chang on 2/10/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

/// All the utility / helper functions can be found here, including date formatting and conversion.
class Util {
  
  /// Get the time representing the start of the day in local time.
  /// - parameter date: The date to convert from UTC to local and find the beginning of.
  public static func GetLocalizedDayStart(date: Date) -> Date {
    
    let localizedDate = Util.UTCToLocal(date: date)
    let dayStart = Calendar.current.startOfDay(for: localizedDate)
    return dayStart
    
  }
  
  /// Get a date representing end of day in local time.
  /// - parameter date: The date to convert from UTC to local and find the end of.
  public static func GetLocalizedDayEnd(date: Date) -> Date {
    
    let localizedDate = Util.UTCToLocal(date: date)
    let dayStart = Calendar.current.startOfDay(for: localizedDate)
    var dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
    dayEnd = Calendar.current.date(byAdding: .second, value: -1, to: dayEnd)!
    return dayEnd
    
  }
  
  /// Determine whether a given date object is within the start and end of the localized date - i.e. convert it to local time and see whether the date object relies between the beginning and end times.
  /// - parameter date: The date to check compared to the localized day start and end.
  public static func IsDateToday(date: Date) -> Bool {
    
    let dayStart = Util.GetLocalizedDayStart(date: date)
    let dayEnd = Util.GetLocalizedDayEnd(date: date)
    return date <= dayEnd && date >= dayStart
    
  }
  
  /// Convert date object from UTC to local time.
  /// - parameter date: The date to convert.
  public static func UTCToLocal(date:Date) -> Date {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current
    let localDateString = dateFormatter.string(from: date)
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter.date(from: localDateString)!
    
  }
  
}
