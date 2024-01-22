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
    @IBOutlet private var authorizationTitleLabel: NSTextField!
    @IBOutlet private var badgeAuthorizationCheckbox: NSButton!
    @IBOutlet private var badgeAuthorizationStatusLabel: NSTextField!
    @IBOutlet private var soundAuthorizationCheckbox: NSButton!
    @IBOutlet private var soundsAuthorizationStatusLabel: NSTextField!
    @IBOutlet private var alertAuthorizationCheckbox: NSButton!
    @IBOutlet private var alertsAuthorizationStatusLabel: NSTextField!
    @IBOutlet private var criticalAuthorizationCheckbox: NSButton!
    @IBOutlet private var criticalAuthorizationStatusLabel: NSTextField!
    @IBOutlet private var criticalAuthorizationAvailabilityLabel: NSTextField!
    @IBOutlet private var provisionalAuthorizationContainer: NSStackView!
    @IBOutlet private var provisionalAuthorizationCheckbox: NSButton!
    @IBOutlet private var provisionalAuthorizationAvailabilityLabel: NSTextField!
    @IBOutlet private var timeSensitiveAuthorizationCheckbox: NSButton!
    @IBOutlet private var timeSensitiveAuthorizationStatusLabel: NSTextField!
    @IBOutlet private var timeSensitiveAuthorizationAvailabilityLabel: NSTextField!
    @IBOutlet private var helpButton: NSButton!
    @IBOutlet private var helpPopover: NSPopover!

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
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
    
    public func authorizationCheckTimerCallback() {
        setupUi()
    }
    
    
    // MARK: Actions
    
    @IBAction private func onHelpButtonClicked(_ sender: NSButton!) {
        log()
        showHelpPopover()
    }
    
    
    // MARK: Private Methods
    
    private func setupUi() {
        NotificationManager.shared.hasAuthorizationBeenRequested(callback: { [weak self] authorizationHasBeenRequested in
            if authorizationHasBeenRequested {
                self?.setupStatusLabels()
            }
            else {
                self?.setupCheckboxes()
            }
        })
        
        helpPopover.delegate = self
    }
    
    private func setCheckboxAndLabelVisibility(checkboxesHidden: Bool, labelsHidden: Bool) {
        if !checkboxesHidden {
            authorizationTitleLabel.stringValue = "Request authorization for:"
        }
        else {
            authorizationTitleLabel.stringValue = "Authorization requested for:"
        }

        badgeAuthorizationCheckbox.isHidden = checkboxesHidden
        badgeAuthorizationStatusLabel.isHidden = labelsHidden
        
        soundAuthorizationCheckbox.isHidden = checkboxesHidden
        soundsAuthorizationStatusLabel.isHidden = labelsHidden
        
        alertAuthorizationCheckbox.isHidden = checkboxesHidden
        alertsAuthorizationStatusLabel.isHidden = labelsHidden
        
        criticalAuthorizationCheckbox.isHidden = checkboxesHidden
        criticalAuthorizationStatusLabel.isHidden = labelsHidden
        criticalAuthorizationAvailabilityLabel.isHidden = checkboxesHidden
        
        provisionalAuthorizationContainer.isHidden = checkboxesHidden
        
        timeSensitiveAuthorizationCheckbox.isHidden = checkboxesHidden
        timeSensitiveAuthorizationStatusLabel.isHidden = labelsHidden
        timeSensitiveAuthorizationAvailabilityLabel.isHidden = checkboxesHidden
    }
    
    private func setupStatusLabels() {
        NotificationManager.shared.checkNotificationsAuthorization(callback: { [weak self] notificationSettings in
            DispatchQueue.main.async(execute: { [weak self]() in
                self?.setCheckboxAndLabelVisibility(checkboxesHidden: true, labelsHidden: false)
                
                self?.badgeAuthorizationStatusLabel.stringValue = "\(notificationSettings.badgeSetting.toEmoji) Badges"
                self?.soundsAuthorizationStatusLabel.stringValue = "\(notificationSettings.soundSetting.toEmoji) Sounds"
                self?.alertsAuthorizationStatusLabel.stringValue = "\(notificationSettings.alertSetting.toEmoji) Alerts"
                self?.criticalAuthorizationStatusLabel.stringValue = "\(notificationSettings.criticalAlertSetting.toEmoji) Critical"
                self?.timeSensitiveAuthorizationStatusLabel.stringValue = "\(notificationSettings.timeSensitiveSetting.toEmoji) Time sensitive"
            })
        })

    }
    
    private func setupCheckboxes() {
        DispatchQueue.main.async(execute: { [weak self]() in
            self?.setCheckboxAndLabelVisibility(checkboxesHidden: false, labelsHidden: true)
            
            var criticalAndProvisionalAuthorizationAllowed = false
            if #available(macOS 10.14, *) {
                criticalAndProvisionalAuthorizationAllowed = true
            }
            
            var timeSensitiveAuthorizationAllowed = false
            if #available(macOS 12.0, *) {
                timeSensitiveAuthorizationAllowed = true
            }
            
            self?.criticalAuthorizationCheckbox.isEnabled = criticalAndProvisionalAuthorizationAllowed
            self?.criticalAuthorizationCheckbox.state = criticalAndProvisionalAuthorizationAllowed ? .on : .off
            self?.criticalAuthorizationAvailabilityLabel.isHidden = criticalAndProvisionalAuthorizationAllowed
            
            self?.provisionalAuthorizationCheckbox.isEnabled = criticalAndProvisionalAuthorizationAllowed
            self?.provisionalAuthorizationCheckbox.state = criticalAndProvisionalAuthorizationAllowed ? .on : .off
            self?.provisionalAuthorizationAvailabilityLabel.isHidden = criticalAndProvisionalAuthorizationAllowed

            self?.timeSensitiveAuthorizationCheckbox.isEnabled = timeSensitiveAuthorizationAllowed
            self?.timeSensitiveAuthorizationCheckbox.state = timeSensitiveAuthorizationAllowed ? .on : .off
            self?.timeSensitiveAuthorizationAvailabilityLabel.isHidden = timeSensitiveAuthorizationAllowed
        })

    }
    
    private func showHelpPopover() {
        guard let helpPopoverViewController = helpPopover.contentViewController as? HelpPopoverViewController else { return }
        
        helpPopoverViewController.setHelpMessage(to:
            "The authorization tab contains controls and labels relevant to the process of an application requesting authorization " +
            "for user notifications.\n" +
            "\n" +
            "If authorization has not been requested yet, then the authorization tab will contain checkboxes allowing you to customize " +
            "the specific aspects of notifications that you want to request authorization for." +
            "If authorization has already been requested, then it will instead show labels indicating whether each of the aspects is " +
            "enabled (✅), disabled (❌), or not supported by the platform (↩️).\n" +
            "\n" +
            "Once authorization has been requested, You must delete the authorization before it can be re-requested again. To do this, find " +
            "'NotificationTestBench' in the 'Notifications' tab in System Preferences, select it and press backspace (⌫). This will delete the " +
            "previous authorization, and you will have to request again. The authorization tab will automatically update to show the checkboxes again."
        )
        
        helpPopover.show(relativeTo: helpButton.bounds, of: helpButton, preferredEdge: .minX)
    }
}


// MARK: - NSPopoverDelegate Extension
extension AuthorizationTabViewController: NSPopoverDelegate {
    
    func popoverDidClose(_ notification: Notification) {
        log()
    }
    
}
