//
//  ViewController.swift
//  CalendarView
//
//  Created by Brian Hammond on 2/12/17.
//  Copyright © 2017 Fictorial LLC. All rights reserved.
//

// Apple Dokumentation sehr hilfreich zum Verstehen des Zusammenhangs zwischen UIViewController und UIView: https://developer.apple.com/library/archive/referencelibrary/GettingStarted/DevelopiOSAppsSwift/ConnectTheUIToCode.html#//apple_ref/doc/uid/TP40015214-CH22-SW1

import UIKit

class ViewController: UIViewController {
  
  //MARK: properties
  @IBOutlet weak var cal: CalendarView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    print("hey!")
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // first tried willTransition(...), but that didn't work (on IPad)// https://stackoverflow.com/questions/42170373/swift-viewwilltransition-not-called
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    print(UIDevice.current.orientation.isPortrait)
    
    // (a) do some change
///    cal.gotoToday()
    var viewSize: CGSize = self.view.frame.size
    print("h:\(viewSize.height)")
    print("w:\(viewSize.width)")
//    cal.viewSize = viewSize
    cal.orientationPortrait = UIDevice.current.orientation.isPortrait
    // (b) update view
//    cal.layoutSubviews()
  }
  
}

