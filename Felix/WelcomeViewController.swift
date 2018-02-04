//
//  WelcomeViewController.swift
//  Felix
//
//  Created by Kevin Tan on 2/3/18.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private var m_welcomeIndex = 0
    
    @IBOutlet var felixImageView: UIImageView!
    @IBOutlet var hereToHelpLabel: UILabel!
    @IBOutlet var tapToContinueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scale = CGAffineTransform(scaleX: 1.05, y: 1.05)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: [.curveEaseInOut, .autoreverse, .repeat], animations: {
            self.tapToContinueLabel.alpha = 0
            self.felixImageView.transform = scale
        }, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if m_welcomeIndex == 0 {
            UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
                self.hereToHelpLabel.alpha = 1
            }, completion: nil)
            
            m_welcomeIndex += 1
        }
        
        else {
            self.performSegue(withIdentifier: "toName", sender: nil)
        }
    }
    
}
