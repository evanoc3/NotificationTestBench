//
//  AboutWindowController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 02/09/2022.
//

import AppKit


// MARK: - AboutWindowController
class AboutWindowController: NSWindowController {
    
    // MARK: Fields
    
    override var windowNibName: NSNib.Name? {
        return "AboutWindow"
    }
    
    
    // MARK: Lifecycle
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        log("Showing AboutWindow")
        
        window?.level = .floating
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        log("AboutWindow loaded")
    }
}
