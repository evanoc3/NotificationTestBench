//
//  HelpPopoverViewController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 07/09/2022.
//

import AppKit


// MARK: - HelpPopoverViewController
class HelpPopoverViewController: NSViewController {
    
    // MARK: Fields
    
    override var nibName: NSNib.Name? {
        return "HelpPopoverView"
    }
    @IBOutlet private var textView: NSTextView!
    private var bufferedHelpMessage: String?
    
    
    // MARK: Lifecycle
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let helpMessage = bufferedHelpMessage {
            textView.string = helpMessage
        }
    }
    
    
    // MARK: Public API
    
    public func setHelpMessage(to helpMessage: String) {
        if let textView = textView {
            textView.string = helpMessage
            return
        }
        
        bufferedHelpMessage = helpMessage
    }
    
}
