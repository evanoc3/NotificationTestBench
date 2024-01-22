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
    @IBOutlet private var helpButton: NSButton!
    @IBOutlet private var helpPopover: NSPopover!
    
    
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
    
    @IBAction private func onHelpButtonClicked(_ sender: NSButton!) {
        log()
        
        showHelpPopover()
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
    
    private func showHelpPopover() {
        guard let helpPopoverViewController = helpPopover.contentViewController as? HelpPopoverViewController else { return }
        
        helpPopoverViewController.setHelpMessage(to:
            "The presentation tab contains checkboxes which control which aspects of a notification will be delivered while " +
            "the current application is in focus.\n" +
            "\n" +
            "The banner checkbox (only available in macOS 11 and up) controls whether the notification appears over the desktop.\n" +
            "\n" +
            "The list checkbox (only available in macOS 11 and up) controls whether the notification gets added to the notification " +
            "center.\n" +
            "\n" +
            "The alert checkbox (removed in macOS 11) is the same as both the banner and list checkbox.\n" +
            "\n" +
            "The badge checkbox controls whether a badge will be displayed on the app icon in the dock.\n" +
            "\n" +
            "The sound checkbox controls whether a sound will be played when the notification is delivered."
        )
        
        helpPopover.show(relativeTo: helpButton.bounds, of: helpButton, preferredEdge: .minX)
    }
    
}
