//
//  ViewController.swift
//  CalendarView
//
//  Created by Brian Hammond on 2/12/17.
//  Copyright © 2017 Fictorial LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("hey!")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // first tried willTransition, but that didn't work (on IPad)
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
      print(UIDevice.current.orientation.isPortrait)
    }
}

