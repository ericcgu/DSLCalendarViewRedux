//
//  CalendarViewController.swift
//  DSLCalendarViewRedux
//
//  Created by Eric Gu on 5/8/15.
//  Copyright (c) 2015 egu. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, DSLCalendarViewDelegate {

    @IBOutlet var calendarView: DSLCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Calendar View"
        calendarView.delegate = self
    }
    
    func calendarView(calendarView: DSLCalendarView!, didSelectRange range: DSLCalendarRange!) {
        if range != nil {
            println("User selected \(range.startDay) \n to \n \(range.endDay)")
        }
    }
    
    

}
