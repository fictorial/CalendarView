//
//  CalendarView.swift
//  CalendarView
//
//  Created by Brian Hammond on 2/12/17.
//  Update to SWIFT5, scaling to visible area W.Schulz 3/24/2020
//
//  Copyright © 2017 Fictorial LLC. All rights reserved.
//

import UIKit

extension Date {
  var weekday: Int {
    return Calendar.current.component(.weekday, from: self)
  }
  
  var firstDayOfTheMonth: Date! {
    return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
  }
}

protocol CalendarViewDataSource {
  func showDotForDate(_ date: Date) -> Bool
}

protocol CalendarViewDelegate {
  func canSelectDate(_ date: Date) -> Bool
  func didSelectDate(_ date: Date)
}

class CalendarCellView: UIView {
  var date: Date! {
    didSet {
      self.textLabel.text = "\(Calendar.current.dateComponents([.day], from: self.date).day!)"
    }
  }
  //consts!?
  let textLabel: UILabel!
  let detailLabel: UILabel!
  
  // (1) was ist der Unterschied: let, var ... das war eigentlich var line = UIBe..()
  // (2) klappt es auch mit UIBez...!  ??, was bedeutet das ! eigentlich?
  let line = UIBezierPath()
  func graph() {
    // horiz.lines
    self.line.move(to: .init(x: 0, y: bounds.height))
    self.line.addLine(to: .init(x: bounds.width, y: bounds.height))
    UIColor.red.setStroke()
    self.line.lineWidth=2
    self.line.stroke()
    // vertical lines
    self.line.move(to: .init(x: bounds.width, y: 0))
    self.line.addLine(to: .init(x: bounds.width, y: bounds.height))
    UIColor.red.setStroke()
    self.line.lineWidth=2
    self.line.stroke()
  }
  
  var selected = false {
    didSet {
      self.backgroundColor = self.selected ? UIColor.init(white: 0.95, alpha: 1.0) : .white
    }
  }
  
  static var formatter: DateFormatter {
    let f = DateFormatter()
    f.dateStyle = .short
    return f
  }
  
  init() {
    self.textLabel = UILabel(frame: CGRect.zero)
    self.textLabel.adjustsFontSizeToFitWidth = true
    self.textLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
    self.textLabel.textAlignment = .center
    
    self.detailLabel = UILabel(frame: CGRect.zero)
    self.detailLabel.adjustsFontSizeToFitWidth = true
    self.detailLabel.font = UIFont.boldSystemFont(ofSize: 10)
    self.detailLabel.textAlignment = .center
    
    super.init(frame: CGRect.zero)
    
    self.layer.borderWidth = 0.5
    self.layer.borderColor = UIColor.lightGray.cgColor
    
    self.isUserInteractionEnabled = true
    
    self.addSubview(self.textLabel)
    self.addSubview(self.detailLabel)
    // nee, klappt nicht. da muss man den draw event überschreiben -> self.addSubview(self.line)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    self.textLabel.frame = self.bounds
    
    self.detailLabel.frame = CGRect(x: 0, y: self.bounds.size.height/2, width: self.bounds.size.width, height: self.bounds.size.height/2)
  }
  
  // 2020-03-23, it seems to be the wrong place to call draw here,
  // as upon re-opening the App, the lines are drawn twice
  override func draw(_ rect: CGRect) {
    //    graph()
  }
}
/*
 protocol TransitionViewDelegate {
 // do something
 }
 */
class CalendarView : UIView {
  var dataSource: CalendarViewDataSource?
  var delegate: CalendarViewDelegate?
  //    var transitionview: TransitionViewDelegate?
  var orientationPortrait: Bool! // variable is unwrapped
  var viewSize: CGSize!
  
  var currentDate: Date! {
    didSet {
      for cell in cells {
        cell.selected = false
      }
    }
  }
  
  var selectedDate: Date? {
    didSet {
      guard let sd = self.selectedDate else {
        for cell in cells {
          cell.selected = false
        }
        return
      }
      
      for cell in cells {
        cell.selected = Calendar.current.compare(sd, to: cell.date, toGranularity: .day) == .orderedSame
      }
      
      delegate?.didSelectDate(sd)
    }
  }
  
  var cells: [CalendarCellView]!
  var monthLabel: UILabel!
  var weekdayLabels: [UILabel]!
  var dotColor: UIColor = .red
  
  // See http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
  
  var monthFormatter: DateFormatter {
    let f = DateFormatter()
    f.dateFormat = "MMM YYYY"
    return f
  }
  
  var weekdayFormatter: DateFormatter {
    let f = DateFormatter()
    f.dateFormat = "EEEEE"
    return f
  }
  
  // 2020-03-24, awakefromNib statt init??
  override func awakeFromNib() {
    //  override func viewDidLoad() {
    orientationPortrait = false
/*
    // https://stackoverflow.com/questions/29476587/cashapelayer-with-uibezierpath
    let path = UIBezierPath()
    path.move(to: .init(x: 0, y: 0))
    path.addLine(to: .init(x: frame.size.width, y: 0))
    path.addLine(to: .init(x: 0, y: frame.size.height))
    path.close()
    
    let shape = CAShapeLayer()
    shape.frame = self.bounds
    shape.path = path.cgPath
    UIColor.red.setStroke()
    self.layer.addSublayer(shape)
    self.layer.mask = shape
  */
    
    
    monthLabel = UILabel(frame: CGRect.zero)
    monthLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    monthLabel.adjustsFontSizeToFitWidth = true
    monthLabel.textAlignment = .center
    self.addSubview(monthLabel)
    
    // We always show Sunday to Saturday left to right
    
    weekdayLabels = [UILabel]()
    for _ in 0..<7 {
      let lbl = UILabel(frame: CGRect.zero)
      lbl.font = UIFont.systemFont(ofSize: 10)
      lbl.adjustsFontSizeToFitWidth = true
      lbl.textAlignment = .center
      lbl.textColor = .lightGray
      self.addSubview(lbl)
      weekdayLabels.append(lbl)
    }
    
    // We always show 6 weeks as some months will require it.
    
    cells = [CalendarCellView]()
    for i in 0..<42 {
      let cell = CalendarCellView()
      cell.tag = i
      
      let tapGR = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
      tapGR.numberOfTapsRequired = 1
      tapGR.numberOfTouchesRequired = 1
      cell.addGestureRecognizer(tapGR)
      
      cells.append(cell)
      self.addSubview(cell)
    }
    
    let today = Date()
    currentDate = today
    layoutIfNeeded()
    selectedDate = today
    
    let swipeLeftGR = UISwipeGestureRecognizer(target: self, action: #selector(advanceOneMonth))
    swipeLeftGR.direction = .left
    self.addGestureRecognizer(swipeLeftGR)
    
    let swipeRightGR = UISwipeGestureRecognizer(target: self, action: #selector(rewindOneMonth))
    swipeRightGR.direction = .right
    self.addGestureRecognizer(swipeRightGR)
    
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(maybeGotoToday(_:)))
    tapGR.numberOfTapsRequired = 2
    tapGR.numberOfTouchesRequired = 1
    self.addGestureRecognizer(tapGR)
  }
  
  func gotoToday() {
    let today = Date()
    currentDate = today
    setNeedsLayout()
    layoutIfNeeded()
    selectedDate = today
  }
  
  @objc func advanceOneMonth() {
    currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)
    setNeedsLayout()
  }
  
  @objc func rewindOneMonth() {
    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)
    setNeedsLayout()
  }
  
  @objc func didTap(_ recognizer: UITapGestureRecognizer) {
    guard let cellView = recognizer.view as? CalendarCellView else { return }
    
    let date = cellView.date!
    
    if delegate?.canSelectDate(date) ?? true {
      selectedDate = date
    }
  }
  
  @objc func maybeGotoToday(_ recognizer: UITapGestureRecognizer) {
    if recognizer.location(in: self).y < 40 {
      gotoToday()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    monthLabel.text = monthFormatter.string(from: currentDate)
    
    let firstWeekday = currentDate.firstDayOfTheMonth.weekday
    var cellDate = Calendar.current.date(byAdding: .day, value: -firstWeekday + 1, to: currentDate.firstDayOfTheMonth)!
    for i in 0..<7 {
      let weekdayDate = Calendar.current.date(byAdding: .day, value: i, to: cellDate)!
      let lbl = weekdayLabels[i]
      lbl.text = weekdayFormatter.string(from: weekdayDate)
    }
    
    let monthNameHeight: CGFloat = 30
    let weekdayHeight: CGFloat = 10
    let headerHeight: CGFloat = monthNameHeight + weekdayHeight
    
    monthLabel.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: monthNameHeight)
    
    // use visible rect to get dimensions of cellviews!
    let visibleRect: CGRect = self.frame.intersection(self.superview!.frame) // ! bedeutet unwrapping
    let columnCount: CGFloat = 7
    let rowCount: CGFloat = 6
    let cellWidth = round(visibleRect.width / columnCount)
    var cellHeight: CGFloat;
    print("cv-b-height:\(self.bounds.size.height)")
    print("cv-fr-height:\(self.frame.size.height)")
    cellHeight = round((visibleRect.height - headerHeight) / rowCount)
    
    var left: CGFloat = 0
    var top: CGFloat = headerHeight
    
    for i in 0..<Int(columnCount) {
      let lbl = weekdayLabels[i]
      lbl.frame = CGRect(x: left, y: monthNameHeight, width: cellWidth, height: weekdayHeight)
      left += cellWidth
    }
    
    left = 0
    var index = 0
    
    for _ in 0..<Int(rowCount) {
      for _ in 0..<Int(columnCount) {
        let cell = cells[index]
        
        cell.date = cellDate
        
        cell.frame = CGRect(x: left, y: top, width: cellWidth, height: cellHeight)
        left += cellWidth
        
        if Calendar.current.isDate(cellDate, equalTo: currentDate, toGranularity: .month) {
          cell.textLabel.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
          cell.textLabel.textColor = .black
        } else {
          cell.textLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
          cell.textLabel.textColor = .lightGray
        }
        
        cell.detailLabel.textColor = dotColor
        cell.detailLabel.text = (dataSource?.showDotForDate(cellDate) ?? false) ? "•" : nil
        
        index += 1
        
        cellDate = Calendar.current.date(byAdding: .day, value: 1, to: cellDate)!
      }
      
      left = 0
      top += cellHeight
    }
  }
  
}
