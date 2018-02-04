//
//  SettingsViewController.swift
//  Felix
//
//  Created by Christine Sun on 04/02/2018.
//  Copyright © 2018 Felix Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet var regularView: UIView!
    
    @IBOutlet var helpLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let padding: CGFloat = 10
        let labelHeight: CGFloat = 50
        let aboutHeight: CGFloat = 300
        let helpHeight: CGFloat = 200
        
        var yOrigin = padding
        let screenWidth = self.view.frame.width

        // add name section later?
        
        // About this app
        
        let titleLabel0 = UILabel()
        titleLabel0.font = UIFont(name: "Poppins-Bold", size: 18)
        titleLabel0.text = "About"
        titleLabel0.sizeToFit()
        titleLabel0.frame = CGRect(x: screenWidth/2 - titleLabel0.frame.width/2, y: yOrigin, width: titleLabel0.frame.width, height: labelHeight)
        
        regularView.addSubview(titleLabel0)
        yOrigin += labelHeight
        
        // Help description
        
        let aboutTextView = UITextView(frame: CGRect(x: 20, y: yOrigin, width: view.frame.width - 40, height: aboutHeight))
        
        aboutTextView.font = UIFont(name: "Poppins-Regular", size: 14)
        aboutTextView.text = "Val utilizes cognitive behavioural therapy (CBT) to help users as much as possible! CBT is a mental exercise proven to be one of the best methods to improve daily mood and overall health. The key steps in CBT is to: identify and get to know automatic negative thoughts that are spontaneously triggered, ask whether there is concrete evidence or good reason to feel the way you do, challenge your initial thoughts by doubting your instincts, and find an alternative to view the thought or situation."
        
        regularView.addSubview(aboutTextView)
        yOrigin += aboutHeight
        
        // Title Label
        
        let titleLabel1 = UILabel()
        titleLabel1.font = UIFont(name: "Poppins-Bold", size: 18)
        titleLabel1.text = "For More Help"
        titleLabel1.sizeToFit()
        titleLabel1.frame = CGRect(x: screenWidth/2 - titleLabel1.frame.width/2, y: yOrigin, width: titleLabel1.frame.width, height: labelHeight)
        
        regularView.addSubview(titleLabel1)
        yOrigin += labelHeight
        
        // Help description
        
        let helpTextView = UITextView(frame: CGRect(x: 20, y: yOrigin, width: view.frame.width - 40, height: helpHeight))
        
        helpTextView.font = UIFont(name: "Poppins-Regular", size: 14)
        helpTextView.text = "Valerian is not a replacement for a real therapist or psychologist. If you ever need to talk to someone for anonymous emotional support, please call (212) 673-3000. Free, immediately accessible, confidential, 24/7."
        
        regularView.addSubview(helpTextView)
    }
}
