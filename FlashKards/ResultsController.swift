//
//  ResultsController.swift
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-24.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

import UIKit

class ResultsController: UIViewController {
    @IBOutlet weak var exitControllerBtn: UIButton!
    @IBOutlet var sepLine: UIView!
    @IBOutlet weak var sepLineWidthConstraint: NSLayoutConstraint!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        exitControllerBtn.tag = 0
        exitControllerBtn.addTarget(self, action: "buttonPressed:", forControlEvents: .TouchUpInside)
        sepLineWidthConstraint.constant = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        sepLineWidthConstraint.constant = self.view.frame.width - 30
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (complete) -> Void in
            
        }
    }
    
    func configureWithResults(results: NSDictionary, andCollection collection: FlashCardCollection) {
        
    }
    
    func buttonPressed(sender: UIButton){
        switch(sender.tag){
        case 0:
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
