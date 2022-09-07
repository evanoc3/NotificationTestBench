//
//  PresentationViewController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 07/09/2022.
//

import AppKit
import UserNotifications


// MARK: - PresentationTabViewController
class PresentationTabViewController: NSViewController {
    
    // MARK: Fields
    
    override var nibName: NSNib.Name? {
        return "PresentationTabView"
    }
    @IBOutlet private var bannerCheckbox: NSButton!
    @IBOutlet private var listCheckbox: NSButton!
    @IBOutlet private var alertCheckBox: NSButton!
    @IBOutlet private var badgeCheckbox: NSButton!
    @IBOutlet private var soundCheckbox: NSButton!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    
    // MARK: Public API
    
    public func getPresentationOptions() -> UNNotificationPresentationOptions {
        var presentationOptions = UNNotificationPresentationOptions()
        
        if #available(macOS 11.0, *) {
            if bannerCheckbox.state == .on {
                presentationOptions.insert(.banner)
            }
            
            if listCheckbox.state == .on {
                presentationOptions.insert(.list)
            }
        }
        else {
            if alertCheckBox.state == .on {
                presentationOptions.insert(.alert)
            }
        }
        
        if badgeCheckbox.state == .on {
            presentationOptions.insert(.badge)
        }
        
        if soundCheckbox.state == .on {
            presentationOptions.insert(.sound)
        }
        
        return presentationOptions
    }
    
    
    // MARK: Actions
    
    @IBAction private func onCheckboxClicked(_ sender: NSButton!) {
        log("\(sender.title.lowercased())Checkbox clicked")
        
        // first set the presentation options
        NotificationManager.shared.presentationOptions = getPresentationOptions()
    }
    
    // MARK: Private Methods
    
    private func setupUi() {
        var bannerAndListPresentationOptionsAvailable = false
        if #available(macOS 11.0, *) {
            bannerAndListPresentationOptionsAvailable = true
        }
        
        bannerCheckbox.isHidden = !bannerAndListPresentationOptionsAvailable
        bannerCheckbox.state = bannerAndListPresentationOptionsAvailable ? .on : .off
        listCheckbox.isHidden = !bannerAndListPresentationOptionsAvailable
        listCheckbox.state = bannerAndListPresentationOptionsAvailable ? .on : .off
        alertCheckBox.isHidden = bannerAndListPresentationOptionsAvailable
        alertCheckBox.state = !bannerAndListPresentationOptionsAvailable ? .on : .off
    }
    
}
