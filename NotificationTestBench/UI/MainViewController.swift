//
//  MainViewController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 02/09/2022.
//

import AppKit
import UserNotifications


// MARK: - MainViewController
class MainViewController: NSViewController {
    
    // MARK: Fields
    
    override var nibName: NSNib.Name? {
        return "MainView"
    }
    @IBOutlet private var tabView: NSTabView!
    @IBOutlet weak private var placeholderTabViewItem: NSTabViewItem!
    @IBOutlet private var preferencesButton: NSButton!
    @IBOutlet private var requestAuthorizationButton: NSButton!
    @IBOutlet private var clearNotificationsButton: NSButton!
    @IBOutlet private var sendNotificationButton: NSButton!
    private var authorizationTabViewController: AuthorizationTabViewController!
    private var contentTabViewController: ContentTabViewController!
    private var actionsTabViewController: ActionsTabViewController!
    private var presentationTabViewController: PresentationTabViewController!
    private var historyTabViewController: HistoryTabViewController!
    private var authorizationCheckTimer: Timer?
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        log("MainView loaded")
        
        setupUi()
        
        NotificationCenter.default.addObserver(forName: NSNotification.deliveredNotificationsChanged,
                                               object: NotificationManager.shared,
                                               queue: nil,
                                               using: self.onDeliveredNotificationsChangedHandler(_:))
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        authorizationCheckTimer = Timer.scheduledTimer(timeInterval: 2,
                                                       target: self,
                                                       selector: #selector(self.authorizationCheckTimerCallback),
                                                       userInfo: nil,
                                                       repeats: true)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        authorizationCheckTimer?.invalidate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: Actions
    
    @IBAction private func onPreferencesButtonClicked(_ sender: NSButton) {
        log("preferencesButton clicked")
        
        openSystemNotificationPreferences()
    }
    
    @IBAction private func onRequestAuthorizationButtonClicked(_ sender: NSButton) {
        log("requestAuthorizationButton clicked")
        
        let authorizationOptions = authorizationTabViewController.getAuthorizationOptions()
        NotificationManager.shared.requestAuthorization(for: authorizationOptions)
    }
    
    @IBAction func onClearNotificationsButtonClicked(_ sender: NSButton) {
        log("clearNotificationsButton clicked")
        
        NotificationManager.shared.removePendingAndDeliveredNotifications()
    }
    
    @IBAction func onSendNotificationsButtonClicked(_ sender: NSButton) {
        log("sendNotificationButton clicked")
        
        // now send the notification
        let notificationContent = contentTabViewController.getMessageContent()
        if actionsTabViewController?.isCategoryRegistered() ?? false {
            notificationContent.categoryIdentifier = NotifiactionCategoryIdentifier
        }
        NotificationManager.shared.sendNotification(content: notificationContent)
    }
    
    
    // MARK: Private Methods
    
    private func setupUi() {
        tabView.delegate = self
        
        // remove the placeholder tab view item
        tabView.removeTabViewItem(placeholderTabViewItem)
        
        setupAuthorizationTab()
        setupContentTab()
        setupActionsTab()
        setupPresentationTab()
        setupHistoryTab()
        
        setButtonsEnabledIfAuthorizationRequested()
        setClearNotificationsButtonEnabled()
    }
    
    private func setupAuthorizationTab() {
        authorizationTabViewController = AuthorizationTabViewController()
        let authorizationTabViewItem = NSTabViewItem(viewController: authorizationTabViewController)
        authorizationTabViewItem.label = "Authorization"
        authorizationTabViewItem.identifier = "authorization"
        _ = authorizationTabViewController.view
        tabView.addTabViewItem(authorizationTabViewItem)
        
    }
    
    private func setupContentTab() {
        contentTabViewController = ContentTabViewController()
        let contentTabViewItem = NSTabViewItem(viewController: contentTabViewController)
        contentTabViewItem.label = "Content"
        contentTabViewItem.identifier = "content"
        _ = contentTabViewController.view
        tabView.addTabViewItem(contentTabViewItem)
    }
    
    private func setupActionsTab() {
        actionsTabViewController = ActionsTabViewController()
        let actionsTabViewItem = NSTabViewItem(viewController: actionsTabViewController)
        actionsTabViewItem.label = "Actions"
        actionsTabViewItem.identifier = "actions"
        _ = actionsTabViewController.view
        tabView.addTabViewItem(actionsTabViewItem)
    }
    
    private func setupPresentationTab() {
        presentationTabViewController = PresentationTabViewController()
        let presentationTabViewItem = NSTabViewItem(viewController: presentationTabViewController)
        presentationTabViewItem.label = "Presentation"
        presentationTabViewItem.identifier = "presentation"
        _ = presentationTabViewController.view
        tabView.addTabViewItem(presentationTabViewItem)
    }
    
	private func setupHistoryTab() {
		historyTabViewController = HistoryTabViewController()
		let historyTabViewItem = NSTabViewItem(viewController: historyTabViewController)
		historyTabViewItem.label = "History"
		historyTabViewItem.identifier = "history"
        _ = historyTabViewController.view
		tabView.addTabViewItem(historyTabViewItem)
	}
    
    private func openSystemNotificationPreferences() {
        log("Opening Notifications pane in System preferences")
        NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Notifications.prefPane"))
    }
    
    private func setButtonsEnabledIfAuthorizationRequested() {
        NotificationManager.shared.hasAuthorizationBeenRequested(callback: { [weak self] authorizationHasBeenRequested in
            DispatchQueue.main.async(execute: { [weak self, authorizationHasBeenRequested] in
                self?.requestAuthorizationButton.isEnabled = !authorizationHasBeenRequested
                self?.sendNotificationButton.isEnabled = authorizationHasBeenRequested
            })
        })
    }
    
    private func setClearNotificationsButtonEnabled() {
        clearNotificationsButton.isEnabled = NotificationManager.shared.deliveredNotifications.count > 0
    }
    
    @objc private func authorizationCheckTimerCallback() {
        setButtonsEnabledIfAuthorizationRequested()
        authorizationTabViewController?.authorizationCheckTimerCallback()
    }
    
    private func onDeliveredNotificationsChangedHandler(_ notification: Notification) {
        DispatchQueue.main.async(execute: { [weak self] in
            self?.setClearNotificationsButtonEnabled()
        })
    }
    
}


// MARK: - NSTabViewDelegate
extension MainViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        guard let tabViewIdentifier = tabViewItem?.identifier as? String else { return }
        log("Selected tab: \(tabViewIdentifier)")
    }
    
}
