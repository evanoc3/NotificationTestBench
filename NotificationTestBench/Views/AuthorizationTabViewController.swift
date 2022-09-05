//
//  AuthorizationTabViewController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 02/09/2022.
//

import AppKit
import UserNotifications


// MARK: - AuthorizationTabViewController
class AuthorizationTabViewController: NSViewController {
    
    // MARK: Fields
    
    override var nibName: NSNib.Name? {
        return "AuthorizationTabView"
    }
    @IBOutlet private var badgeAuthorizationCheckbox: NSButton!
    @IBOutlet private var soundAuthorizationCheckbox: NSButton!
    @IBOutlet private var alertAuthorizationCheckbox: NSButton!
    @IBOutlet private var criticalAuthorizationCheckbox: NSButton!
    @IBOutlet private var criticalAuthorizationAvailabilityLabel: NSTextField!
    @IBOutlet private var provisionalAuthorizationCheckbox: NSButton!
    @IBOutlet private var provisionalAuthorizationAvailabilityLabel: NSTextField!
    @IBOutlet private var timeSensitiveAuthorizationCheckbox: NSButton!
    @IBOutlet private var timeSensitiveAuthorizationAvailabilityLabel: NSTextField!

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
   
    deinit {
        print("AuthorizationTabViewController deinitialized")
    }
    
    
    // MARK: Public API
    
    public func getAuthorizationOptions() -> UNAuthorizationOptions {
        // construct authorization options to request for
        var authorizationOptions: UNAuthorizationOptions = []
        if badgeAuthorizationCheckbox.state == .on { authorizationOptions.insert(.badge) }
        if soundAuthorizationCheckbox.state == .on { authorizationOptions.insert(.sound) }
        if alertAuthorizationCheckbox.state == .on { authorizationOptions.insert(.alert) }
        if #available(macOS 10.14, *) {
            if criticalAuthorizationCheckbox.state == .on { authorizationOptions.insert(.criticalAlert) }
            if provisionalAuthorizationCheckbox.state == .on { authorizationOptions.insert(.provisional) }
        }
        if #available(macOS 12.0, *) {
            if timeSensitiveAuthorizationCheckbox.state == .on { authorizationOptions.insert(.timeSensitive) }
        }
        return authorizationOptions
    }
    
    
    // MARK: Private Methods
    
    private func setupUi() {
        var criticalAndProvisionalAuthorizationAllowed = false
        if #available(macOS 10.14, *) {
            criticalAndProvisionalAuthorizationAllowed = true
        }
        
        var timeSensitiveAuthorizationAllowed = false
        if #available(macOS 12.0, *) {
            timeSensitiveAuthorizationAllowed = true
        }
        
        criticalAuthorizationCheckbox.isEnabled = criticalAndProvisionalAuthorizationAllowed
        criticalAuthorizationCheckbox.state = criticalAndProvisionalAuthorizationAllowed ? .on : .off
        criticalAuthorizationAvailabilityLabel.isHidden = criticalAndProvisionalAuthorizationAllowed
        
        provisionalAuthorizationCheckbox.isEnabled = criticalAndProvisionalAuthorizationAllowed
        provisionalAuthorizationCheckbox.state = criticalAndProvisionalAuthorizationAllowed ? .on : .off
        provisionalAuthorizationAvailabilityLabel.isHidden = criticalAndProvisionalAuthorizationAllowed

        timeSensitiveAuthorizationCheckbox.isEnabled = timeSensitiveAuthorizationAllowed
        timeSensitiveAuthorizationCheckbox.state = timeSensitiveAuthorizationAllowed ? .on : .off
        timeSensitiveAuthorizationAvailabilityLabel.isHidden = timeSensitiveAuthorizationAllowed

    }
}
