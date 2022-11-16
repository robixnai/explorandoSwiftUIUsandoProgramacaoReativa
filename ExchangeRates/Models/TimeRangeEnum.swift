//
//  TimeRangeEnum.swift
//  ExchangeRates
//
//  Created by Robson Moreira on 15/11/22.
//

import Foundation

enum TimeRangeEnum {
    case today
    case thisWeek
    case thisMonth
    case thisSemester
    case thisYear
    
    var date: Date {
        switch self {
        case .today: return Date(from: .day, value: 1)
        case .thisWeek: return Date(from: .day, value: 6)
        case .thisMonth: return Date(from: .month, value: 1)
        case .thisSemester: return Date(from: .month, value: 6)
        case .thisYear: return Date(from: .year, value: 1)
        }
    }
}
