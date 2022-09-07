//
//  MainWindowController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 29/08/2022.
//

import AppKit


// MARK: - MainWindowController
class MainWindowController: NSWindowController {
    
    // MARK: Fields

    override var windowNibName: NSNib.Name? {
        return "MainWindow"
    }
    private var mainViewController: MainViewController!

    
    // MARK: Lifecycle
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        log("Showing MainWindow")
        window?.makeKeyAndOrderFront(nil)
    }
    
    override func windowDidLoad() {
        log("MainWindow loaded")
        
        mainViewController = MainViewController()
        window?.contentViewController = mainViewController
    }

}
