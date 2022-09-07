//
//  ContentTabViewController.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 02/09/2022.
//

import AppKit
import UserNotifications
import UniformTypeIdentifiers


// MARK: - ContentTabViewController
class ContentTabViewController: NSViewController {
    
    // MARK: Fields
	
    override var nibName: NSNib.Name? {
        return "ContentTabView"
    }
    @IBOutlet private var titleTextField: NSTextField!
    @IBOutlet private var subtitleTextField: NSTextField!
    @IBOutlet private var bodyTextView: NSTextView!
    @IBOutlet private var badgeTextField: NSTextField!
    @IBOutlet private var incrementBadgeCheckbox: NSButton!
    @IBOutlet private var defaultSoundCheckbox: NSButton!
    @IBOutlet private var attachmentPathControl: NSPathControl!
    @IBOutlet private var attachmentClearButton: NSButton!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
		log("ContentTab loaded")
        
        badgeTextField.formatter = IntegerFormatter()
        
        setupUi()
    }
    
    
    // MARK: Public API
    
    public func getMessageContent() -> UNNotificationContent {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = titleTextField.stringValue
        notificationContent.subtitle = subtitleTextField.stringValue
        notificationContent.body = bodyTextView.string
        
        notificationContent.badge = getBadgeCount()
        if incrementBadgeCheckbox.state == .on {
            incrementBadgeCount()
        }
        
        if defaultSoundCheckbox.state == .on {
            notificationContent.sound = .default
        }
        
        if let attachmentUrl = attachmentPathControl.url {
            do {
                let notificationAttachment = try UNNotificationAttachment(identifier: "attachment", url: attachmentUrl)
                notificationContent.attachments = [ notificationAttachment ]
            } catch {
                log("Failed to create notification attachment. Error: \(error.localizedDescription)")
            }
        }
        
        return notificationContent
    }
    
    
    // MARK: Actions
    
    @IBAction private func onChooseAttachmentButtonClicked(_ sender: NSButton) {
        log("chooseAttachmentButton clicked")
        
        let (userSelectedFile, attachmentUrl) = getAttachmentFileUrl()
		if userSelectedFile {
			attachmentPathControl.url = attachmentUrl
			attachmentClearButton.isHidden = attachmentUrl == nil
		}
    }
    
    @IBAction private func onAttachmentClearButtonClicked(_ sender: NSButton) {
        log("attachmentClearButton clicked")
        attachmentPathControl.url = nil
        attachmentClearButton.isHidden = true
    }

    
    // MARK: Private methods
    
    private func setupUi() {
        // set the default URL in the path control
        attachmentPathControl.url = Bundle.main.url(forResource: "avatar", withExtension: "png")
    }
    
    private func incrementBadgeCount() {
        let currentBadgeCount = getBadgeCount()
        let newBadgeCount = NSNumber(value: currentBadgeCount.intValue + 1)
        
        guard let integerFormatter = badgeTextField.formatter as? IntegerFormatter else { return }
        badgeTextField.stringValue = integerFormatter.string(from: newBadgeCount)!
    }
    
    private func getBadgeCount() -> NSNumber {
        guard let integerFormatter = badgeTextField.formatter as? IntegerFormatter else { return 0 }
        return integerFormatter.number(from: badgeTextField.stringValue) ?? 0
    }
    
    private func getAttachmentFileUrl() -> (Bool, URL?) {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a file to attach to notifications"
        dialog.showsResizeIndicator = true
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.canChooseFiles = true
        if #available(macOS 11.0, *) {
            dialog.allowedContentTypes = [ UTType.png ]
        } else {
            dialog.allowedFileTypes = ["png"]
        }
        
		
		
        guard dialog.runModal() == .OK else { return (false, nil) }
        guard let resultUrl = dialog.url else { return (true, nil) }
        
        return (true, resultUrl)
    }
}
