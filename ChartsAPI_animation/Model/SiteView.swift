//
//  SiteView.swift
//  ChartsAPI_animation
//
//  Created by yk on 2023/03/16.
//

import SwiftUI


//example
struct SiteView: Identifiable {
    var id = UUID().uuidString
    var hour: Date
    var views: Double
    var animate: Bool = false
}

extension Date{
    
    //MARK: To update hour for particular Hour
    func updateHour(value: Int) -> Date{
        let calender = Calendar.current
        return calender.date(bySettingHour: value, minute: 0, second: 0, of: self) ?? .now
    }
}

var sample_analytics: [SiteView] = [
    SiteView(hour: Date().updateHour(value: 8), views: 1500),
    SiteView(hour: Date().updateHour(value: 9), views: 2200),
    SiteView(hour: Date().updateHour(value: 10), views: 2650),
    SiteView(hour: Date().updateHour(value: 11), views: 3540),
    SiteView(hour: Date().updateHour(value: 12), views: 4320),
    SiteView(hour: Date().updateHour(value: 13), views: 4302),
    SiteView(hour: Date().updateHour(value: 14), views: 1234),
    SiteView(hour: Date().updateHour(value: 15), views: 6543),
    SiteView(hour: Date().updateHour(value: 16), views: 9234),
    SiteView(hour: Date().updateHour(value: 17), views: 1345),
    SiteView(hour: Date().updateHour(value: 18), views: 6432),
    SiteView(hour: Date().updateHour(value: 19), views: 7522),
    SiteView(hour: Date().updateHour(value: 20), views: 4234),
//    SiteView(hour: Date().updateHour(value: 8), views: 8234),
//    SiteView(hour: Date().updateHour(value: 8), views: 9020),
//    SiteView(hour: Date().updateHour(value: 8), views: 6429),
//    SiteView(hour: Date().updateHour(value: 8), views: 5023),
//    SiteView(hour: Date().updateHour(value: 8), views: 1063),
//    SiteView(hour: Date().updateHour(value: 8), views: 6293),
//    SiteView(hour: Date().updateHour(value: 8), views: 4087),
//    SiteView(hour: Date().updateHour(value: 8), views: 8076),
//    SiteView(hour: Date().updateHour(value: 8), views: 7542),
//    SiteView(hour: Date().updateHour(value: 8), views: 0972),
//    SiteView(hour: Date().updateHour(value: 8), views: 5623),
//    SiteView(hour: Date().updateHour(value: 8), views: 2348),
]

