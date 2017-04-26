# ScrubAnimator

MIT License

# About
ScrubAnimator is a KeyFrame animation library, written in Swift, for iOS, currently supporting animation of CGRect and cornerRadius.
The library makes it easy to create CGRect animations, based on duration and/or a value.

# Features
- **KeyFrame**: for creating animations with a lot of changes
- **Scrub**: Scrub through the animation based on some value. For example a value from UISlider or UIPanGesture

# Limitations
The library currently only support animation of CGRect and cornerRadius.

*More Features are planned, like: borderColor, borderWidth, backgroundColor. In addition a more generic approach, where you can choose just a point, e.g. x or y pos, instead of a CGRect*
# Example
![](https://github.com/simenlie/ScrubAnimator/blob/master/ScrubAnimator-med.gif)

*You can download the project to try the example. The Example code resides in ViewController.swift*

# Usage

```swift
let animator = Animator(duration: 5) //seconds
```

Add KeyFrames with a CGRect
```swift
override func viewDidLoad() {
...

//Setup the keyframes
animator.add(keyFrame: 0, frame: FRAME1)
animator.add(keyFrame: 0.3, frame: FRAME2)
animator.add(keyFrame: 1, frame: FRAME3)

...
}
```
Using the scrub function
```swift
let result = animator.scrubTo(keyFrame: 0.5)
self.myView.frame = result.frame
```
Animate based on the duration (You can also combine scrub and duration, if you scrub to a point, then call animator.animate, it will automatically pick up from where you scrubbed to)
```swift
 animator.animate(direction: .forward,
                         animations: {(result : AnimatorResult) in
                            self.myView.frame = result.frame
        })
```
You can also animate to the next or previous KeyFrame
```swift
 animator.step(direction: .forward, changed: {(result : AnimatorResult) in
            self.myView.frame = result.frame
        })
```
