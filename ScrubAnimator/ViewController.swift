//
//  ViewController.swift
//  ScrubAnimator
//
//  Created by Simen Lie on 26.04.2017.
//  Copyright © 2017 liite. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var animationBtn: UIButton!
    
    let animator = Animator(duration: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.outerView.layer.cornerRadius = self.outerView.frame.size.width/2
        
        let size2 = outerView.frame.size.width/4
        let size3 = outerView.frame.size.width*4
        
        let frame1 = outerView.frame
        let frame2 = CGRect(x: self.view.frame.size.width/2 - size2/2,
                            y: 30,
                            width: size2,
                            height: size2)
        
        let frame3 = CGRect(x: self.view.frame.size.width/2 - size3/2,
                            y: self.view.frame.size.height/2 - size3/2,
                            width: size3,
                            height: size3)
        
        animator.cornerRadiusView = self.outerView
        
        animator.addKeyframe(percentage: 0, frame: frame1, cornerRadius: frame1.size.width/2)
        animator.addKeyframe(percentage: 0.3, frame: frame2, cornerRadius: frame2.size.width/2)
        animator.addKeyframe(percentage: 0.9, frame: frame1, cornerRadius: frame1.size.width/2)
        animator.addKeyframe(percentage: 1, frame: frame3, cornerRadius: frame3.size.width/2)
        
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        let result = animator.scrubAnimation(keyFrame: CGFloat(slider.value))
        self.outerView.frame = result.frame
        self.outerView.layer.cornerRadius = result.cornerRadius
    }
    
    @IBAction func animationTap(_ sender: Any) {
        let backwards = animator.currentScrub == 1
        animator.animate(direction: backwards ? .backward : .forward,
                         changed: {(result : AnimatorResult) in
                            self.outerView.frame = result.frame
                            self.slider.value = Float(self.animator.currentScrub)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func previousTap(_ sender: Any) {
        animator.step(direction: .backward, changed: {(result : AnimatorResult) in
            self.outerView.frame = result.frame
            self.slider.value = Float(self.animator.currentScrub)
        })
    }
    
    @IBAction func nextTap(_ sender: Any) {
        animator.step(direction: .forward, changed: {(result : AnimatorResult) in
            self.outerView.frame = result.frame
            self.slider.value = Float(self.animator.currentScrub)
        })
    }
    
}

