//
//  ViewController.swift
//  ALRadialMenu
//
//  Created by Alex Littlejohn on 2015/04/26.
//  Copyright (c) 2015 zero. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let label = UILabel()
    let radius = 122
    var currentMenu : ALRadialMenu?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(showMenu(_:)))
        gesture.minimumPressDuration = 0.01
        
        view.addGestureRecognizer(gesture)
        view.backgroundColor = UIColor.whiteColor()
        
        label.textColor = UIColor.lightGrayColor()
        label.text = "Tap anywhere"
        label.sizeToFit()
        label.center = view.center
        
        view.addSubview(label)
    }

    func generateButtons() -> [ALRadialMenuButton] {
        
        var buttons = [ALRadialMenuButton]()
        
        for i in 0..<6{
            let button = ALRadialMenuButton(frame: CGRectMake(0, 0, 44, 44))
            button.setImage(UIImage(named: "icon\(i+1)"), forState: UIControlState.Normal)
            buttons.append(button)
        }
        
        return buttons
    }
    
    func checkBoundries(location: CGPoint, radius: CGFloat) -> (startDegree: Int, endDegree: Int, lenth: Int, touchingEdge: Bool){
        
        struct boundsTest {
            var startingDegree: Int
            var endingDegree: Int?
            var length: Int = 0
            var inBounds : Bool
        }
        
        var testArray = [(Int, Bool)]()
        var testString = ""
        var initialRun = boundsTest.init(startingDegree: 1,
                                         endingDegree: nil,
                                        length: 0,
                                        inBounds: true )
        var currentRun : boundsTest?
        var listOfRuns = [boundsTest]()
        var previousTest : Bool?
        

        
        for i in 1...360 {
            let newX = CGFloat(location.x) + CGFloat(radius) * cos(CGFloat(i) * CGFloat(M_PI / 180))
            let newY = CGFloat(location.y) + CGFloat(radius) * sin(CGFloat(i) * CGFloat(M_PI / 180))
            let testPoint = CGPointMake(newX, newY)
            let menuInBounds = CGRectContainsPoint(self.view.frame, testPoint)
            testArray.append((i, menuInBounds))
            
            //Create initial run depending on whether the menu is in or out of bounds
                
            
            if i == 1 {
                if menuInBounds == true {
                    initialRun.inBounds = true
                    currentRun = initialRun
                    currentRun!.length += 1
                    testString = testString + "-"
                }
                else {
                    initialRun.inBounds = false
                    currentRun = initialRun
                    currentRun!.length += 1
                    testString = testString + "x"
                }
            }
            
            
            if i > 1 && i < 360  {
                //Check for switches
                if menuInBounds == previousTest {
                    if listOfRuns.count == 0 {
                        initialRun.length += 1
                    }
                    currentRun!.length += 1
                }
                else {
                //If switched, reset current run
                    if listOfRuns.count == 0 {
                        initialRun.length = i - 1
                        initialRun.endingDegree = i - 1
                    }
                    currentRun!.endingDegree = i - 1
                    listOfRuns.append(currentRun!)
                
                    currentRun = boundsTest.init(startingDegree: i,
                                                endingDegree: nil,
                                                length: 0,
                                                inBounds: menuInBounds)
                    currentRun!.length += 1
                }
            }
            
            if i == 360 {
                // Merge the beginning and end of the circle if they are the same Bool
                if currentRun!.inBounds  == initialRun.inBounds {
                    if listOfRuns.count > 0 {
                        currentRun!.endingDegree = initialRun.endingDegree
                        currentRun!.length = currentRun!.length + initialRun.length + 1
                    }
                    else {
                        currentRun!.endingDegree = 360
                        currentRun!.length += 1
                    }
                    listOfRuns.append(currentRun!)
                }
               /* else {
                    currentRun!.endingDegree = 360
                    listOfRuns.append(currentRun!)
                }*/
            
            }
            previousTest = menuInBounds

        }
        
        var returnStartDegree: Int = 0
        var returnEndDegree: Int = 0
        var returnLength: Int = 0
        var touchingEdge : Bool?

        
        //Grab the longest continuous 'true' run, that will be the best menu settings
        for item in listOfRuns {
            
            
            if item.inBounds == true {
                if item.length > returnLength {
                    returnStartDegree = item.startingDegree
                    returnEndDegree = item.endingDegree!
                    returnLength = item.length
                }
            }
            
            if returnLength == 360 {
                touchingEdge = false
            }
            else {
                touchingEdge = true
            }
        }
        print(returnStartDegree, returnEndDegree, returnLength, touchingEdge!)
        return (returnStartDegree, returnEndDegree, returnLength, touchingEdge!)
    }
    
    func showMenu(sender: UILongPressGestureRecognizer) {
        
        var touchLocation: CGPoint
        var menuCircumference: Double?
        var menuStartAngle: Double?
        
        
        if sender.state == .Began {
            touchLocation = sender.locationInView(self.view)
            
            print("Long press began")
            let menuSettings = checkBoundries(touchLocation, radius: 144)
        
            //Check whether the menu will touch an edge
            if menuSettings.touchingEdge == true {
                menuCircumference = Double(menuSettings.lenth -  30)
                menuStartAngle = Double(menuSettings.startDegree + 15)
            }
                
            else {
                menuCircumference = 360
                menuStartAngle    = 0
            }
            
            
        currentMenu = ALRadialMenu()
            .setButtons(generateButtons())
            .setStartAngle(menuStartAngle!)
            .setRadius(122)
            .setCircumference(menuCircumference!)
            .setDelay(0.05)
            .setAnimationOrigin(sender.locationInView(view))
            .presentInView(view)
        }
        if sender.state == .Ended {
            
            print("Long press ended")

            
            currentMenu!.dismiss()
            
        }

    }
    
    
    override func prefersStatusBarHidden() -> Bool {
         return true
    }
}

