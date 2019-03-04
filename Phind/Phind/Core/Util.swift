//
//  Util.swift
//  Phind
//
//  Created by Kevin Chang on 2/10/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import UIKit

// All the utility / helper functions can be found here.

class Util {
  
  public static func GetLocalizedDayStart(date: Date) -> Date {
    let localizedDate = Util.UTCToLocal(date: date)
    let dayStart = Calendar.current.startOfDay(for: localizedDate)
    return dayStart
  }
  
  public static func GetLocalizedDayEnd(date: Date) -> Date {
    
    let localizedDate = Util.UTCToLocal(date: date)
    let dayStart = Calendar.current.startOfDay(for: localizedDate)
    var dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart)!
    dayEnd = Calendar.current.date(byAdding: .second, value: -1, to: dayEnd)!
    return dayEnd
    
  }
  
  public static func IsDateToday(date: Date) -> Bool {
    let dayStart = Util.GetLocalizedDayStart(date: date)
    let dayEnd = Util.GetLocalizedDayEnd(date: date)
    return date <= dayEnd && date >= dayStart
  }
  
  public static func UTCToLocal(date:Date) -> Date {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current
    let localDateString = dateFormatter.string(from: date)
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    return dateFormatter.date(from: localDateString)!
    
  }
  
}
