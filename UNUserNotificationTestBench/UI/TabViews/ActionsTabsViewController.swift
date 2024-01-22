//
//  ActionsTabsViewController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 28/11/2023.
//

import AppKit
import UserNotifications

let Action1Identifier = "id_action_1"
let NotifiactionCategoryIdentifier = "id_notification_category"


// MARK: - ActionsTabViewController class
class ActionsTabViewController: NSViewController {
    
    // MARK: Outlets
    
    @IBOutlet var hasActionsCheckbox: NSButton!
    @IBOutlet var numberOfCategoriesLabel: NSTextField!
    @IBOutlet var helpButton: NSButton!
    @IBOutlet var helpPopover: NSPopover!
    
    
    // MARK: Fields
    
    override var nibName: NSNib.Name? {
        return "ActionsTabView"
    }
    
    
    // MARK: NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUi()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        reloadNumberOfCategories()
    }
    
    
    // MARK: Actions
    
    @IBAction func onHasActionsCheckboxClicked(_ sender: NSButton) {
        let newState = hasActionsCheckbox.state == .on
        setNotificationCategories(hasActions: newState)
        reloadNumberOfCategories()
    }
    
    @IBAction func onHelpButtonClicked(_ sender: NSButton) {
        showHelpPopover()
    }
    
    
    // MARK: Public API
    
    public func isCategoryRegistered() -> Bool {
        return hasActionsCheckbox.state == .on
    }
    
    
    // MARK: Private Methods
    
    private func setupUi() {
        reloadNumberOfCategories()
    }
    
    private func showHelpPopover() {
        guard let helpPopoverViewController = helpPopover.contentViewController as? HelpPopoverViewController else { return }
        
        helpPopoverViewController.setHelpMessage(to:
            "The actions tab allows you to customize the category and actions which will be available on the notification toasts.\n" +
            "\n" +
            "In order to add actions to a notification toast, you must first register a category and assign actions to that category." +
            "Then you can assign the notification a category when you are creating it's content, and the notification toast will automatically " +
            "show the actions belonging to the assigned category.\n" +
            "\n" +
            "Checking the checkbox on this tab will register a category with a single dummy action and messages sent while this category " +
            "is registered will have the category assigned."
        )
        
        helpPopover.show(relativeTo: helpButton.bounds, of: helpButton, preferredEdge: .minX)
    }
    
    private func setNotificationCategories(hasActions: Bool) {
        if hasActions {
            let action = UNNotificationAction(identifier: Action1Identifier, title: "Action 1")
            let notificationCategory = UNNotificationCategory(identifier: NotifiactionCategoryIdentifier, actions: [action], intentIdentifiers: [], options: [])
            UNUserNotificationCenter.current().setNotificationCategories([ notificationCategory ])
        }
        else {
            UNUserNotificationCenter.current().setNotificationCategories([])
        }
    }
    
    private func reloadNumberOfCategories() {
        UNUserNotificationCenter.current().getNotificationCategories(completionHandler: { [weak self] categories in
            DispatchQueue.main.async { [weak self] in
                self?.hasActionsCheckbox.state = categories.count > 0 ? .on : .off
                self?.numberOfCategoriesLabel.stringValue = "\(categories.count)"
            }
        })
    }
}
