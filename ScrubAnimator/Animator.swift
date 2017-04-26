//
//  Animator.swift
//  Knips
//
//  Created by Simen Lie on 26.04.2017.
//  Copyright © 2017 liite. All rights reserved.
//

import UIKit

struct AnimatorResult {
    var frame : CGRect
    var cornerRadius : CGFloat
}

enum Direction {
    case forward
    case backward
}

class Animator: NSObject {
    var duration : CGFloat
    var currentScrub : CGFloat = 0
    var initialValue : CGRect?
    var valuesKV = [CGFloat : AnimatorResult]()
    var percentageSorted = [CGFloat]()
    var isLoggingEnabled = false
    var cornerRadiusView : UIView?
    
    init(duration : CGFloat) {
        self.duration = duration
        super.init()
    }
    
    func endResult() -> AnimatorResult
    {
        if let endBuilder = valuesKV[percentageSorted[percentageSorted.count - 1]] {
            return endBuilder
        }
        fatalError("KeyFrames not setup correctly")
    }
    
    func beginResult() -> AnimatorResult
    {
        if let startBuilder = valuesKV[percentageSorted[0]]{
            return startBuilder
        }
        fatalError("KeyFrames not setup correctly")
    }
    
    //Public functions
    
    func getDuration() -> TimeInterval
    {
        return TimeInterval(self.duration * (1 - currentScrub))
    }
    
    func addKeyframe(percentage : CGFloat, frame : CGRect, cornerRadius : CGFloat? = nil)
    {
        valuesKV[percentage] = AnimatorResult(frame: frame, cornerRadius: cornerRadius ?? 0)
        percentageSorted.append(percentage)
    }
    
    func animate(direction: Direction, changed : @escaping ((AnimatorResult) -> Void))
    {
        animate(direction: direction, once: false, changed: changed)
    }
    
    func step(direction : Direction, changed : @escaping ((AnimatorResult) -> Void)){
        animate(direction: direction, once: true, changed: changed)
    }
    
    func scrubAnimation(keyFrame : CGFloat) -> AnimatorResult
    {
        currentScrub = keyFrame
        //Takes the values in the keyframes, and animates it from there
        var first : CGFloat = 0
        var next : CGFloat = 0
        var index = 0
        for percentage in percentageSorted {
            if keyFrame <= percentage {
                //iF the current percentage is smaller than this, we know
                //that we should use this value and the previous to interpolation
                if index > 0 {
                    first = percentageSorted[index - 1]
                }
                next = percentage
                break
            }
            index += 1
        }
        let firstBuilder = valuesKV[first]
        let nextBuilder = valuesKV[next]
        let firstRect = firstBuilder?.frame
        let nextRect = nextBuilder?.frame
        
        if first == next {
            if let nextBuilder = nextBuilder {
                return nextBuilder
            }
        }
        
        //value inside arbitrary range
        var nextPercentage = (keyFrame - first) * (first/next)
        nextPercentage = (keyFrame - first)/(next - first)
        if first == 0 {
            //nextPercentage = nextTest
        }
        
        if let firstRect = firstRect {
            if let nextRect = nextRect {
                let frame = interpolateValue(startFrame: firstRect, endFrame: nextRect, percentage: nextPercentage)
                let cornerRadius = interpolateValues(firstFloat: (firstBuilder?.cornerRadius)!, nextFloat: (nextBuilder?.cornerRadius)!, percentage: nextPercentage)
                if isLoggingEnabled {
                    printLog(currentPercentage: keyFrame,
                             first: first,
                             next: next,
                             firstRect: firstRect,
                             nextRect: nextRect,
                             nextPercentage: nextPercentage,
                             interpolatedFrame: frame)
                }
                return AnimatorResult(frame: frame, cornerRadius: cornerRadius)
            }
        }
        return AnimatorResult(frame: CGRect(), cornerRadius: 0)
    }
    
    //Private functions
    
    private func animate(direction: Direction, once : Bool, changed : @escaping ((AnimatorResult) -> Void))
    {
        var array : [CGFloat] = [CGFloat]()
        if direction == .forward {
            for percent in percentageSorted {
                if currentScrub < percent {
                    array.append(percent)
                }
            }
        }
        else{
            for percent in percentageSorted {
                if percent < currentScrub {
                    array.append(percent)
                }
            }
            array = array.reversed()
        }
        if array.count > 0 {
            animateKeyFrame(array: array, changed: changed, index: 0, once: once)
        }
    }
    
    private func animateKeyFrame(array : [CGFloat], changed : @escaping ((AnimatorResult) -> Void), index : Int, once : Bool)
    {
        let value = array[index]
        var previous : CGFloat = currentScrub
        if index > 0 {
            previous = array[index - 1]
        }
        
        let calc = (value - previous) * duration
        let result = scrubAnimation(keyFrame: value)
        let duration2 = TimeInterval(abs(calc))
        print("Stuff: ", calc, value, previous)
        
        if let cornerRadiusView = cornerRadiusView {
            let animation = CABasicAnimation(keyPath:"cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fromValue = cornerRadiusView.layer.cornerRadius
            animation.toValue = result.cornerRadius
            animation.duration = duration2
            //animation.fillMode = kCAFillModeForwards
            cornerRadiusView.layer.add(animation, forKey: "cornerRadius")
            cornerRadiusView.layer.cornerRadius = result.cornerRadius
            
            
            UIView.animate(withDuration: duration2,
                           animations: {
                            changed(result)
            },
                           completion: {(finished : Bool) in
                            if finished {
                                cornerRadiusView.layer.removeAnimation(forKey: "cornerRadius")
                                cornerRadiusView.layer.cornerRadius = result.cornerRadius
                                if index < array.count - 1 {
                                    self.currentScrub = value
                                    if !once{
                                        self.animateKeyFrame(array: array, changed: changed, index: index + 1, once: once)
                                    }
                                }
                            }
            })
        }
    }
    
    
    
    
    
    private func interpolateValues(firstFloat : CGFloat, nextFloat : CGFloat, percentage : CGFloat) -> CGFloat
    {
        let newPercentage = 1 - percentage
        let computedWidth = ((firstFloat - nextFloat) * newPercentage) + nextFloat
        return computedWidth
    }
    
    private func interpolateValue(startFrame : CGRect, endFrame: CGRect, percentage : CGFloat) -> CGRect
    {
        let startWidth : CGFloat = startFrame.size.width
        let startHeight : CGFloat = startFrame.size.height
        let startX : CGFloat = startFrame.origin.x
        let startY : CGFloat = startFrame.origin.y
        
        let endWidth : CGFloat = endFrame.size.width
        let endHeight : CGFloat = endFrame.size.height
        let endX : CGFloat = endFrame.origin.x
        let endY : CGFloat = endFrame.origin.y
        
        let computedWidth = interpolateValues(firstFloat: startWidth, nextFloat: endWidth, percentage: percentage)
        let computedHeight = interpolateValues(firstFloat: startHeight, nextFloat: endHeight, percentage: percentage)
        let computedX = interpolateValues(firstFloat: startX, nextFloat: endX, percentage: percentage)
        let computedY = interpolateValues(firstFloat: startY, nextFloat: endY, percentage: percentage)
        
        return CGRect(x: computedX, y: computedY, width: computedWidth, height: computedHeight)
    }
    
    private func printLog(currentPercentage : CGFloat, first : CGFloat, next : CGFloat, firstRect : CGRect, nextRect : CGRect, nextPercentage : CGFloat, interpolatedFrame : CGRect)
    {
        print("######################")
        print("Percentage ", currentPercentage)
        print("KeyFrames ", first, next)
        
        print("firstRect ", NSStringFromCGRect(firstRect))
        print("nextRect ", NSStringFromCGRect(nextRect))
        print("Next Percentage scale: ", nextPercentage)
        print("ComputedRect ", NSStringFromCGRect(interpolatedFrame))
        print("######################")
    }
}
