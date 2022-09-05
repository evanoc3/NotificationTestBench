//
//  AppDelegate.swift
//  NotificationTestBench
//
//  Created by Evan O'Connor on 29/08/2022.
//

import Cocoa

@main class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    // MARK: Fields
    
    private var mainWindowController: MainWindowController?
    private var aboutWindowController: AboutWindowController?

    
    // MARK: NSApplicationDelegate Methods
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showMainWindow()
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        showMainWindow()
        return true
    }
    
    
    // MARK: NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        guard let window = notification.object as? NSWindow else { return }
        
        if let mainWindow = mainWindowController?.window, window == mainWindow {
            print("MainWindow closing")
            return
        }
        if let aboutWindow = aboutWindowController?.window, window == aboutWindow {
            print("AboutWindow closing")
            return
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func aboutMenuItemClicked(_ sender: NSMenuItem) {
        print("About menu item clicked")
        showAboutWindow()
    }
    
    @IBAction func quitMenuItemClicked(_ sender: NSMenuItem) {
        print("Quit menu item clicked")
        NSApp.terminate(sender)
    }
    
    
    // MARK: Private Methods
    
    private func showMainWindow() {
        if mainWindowController == nil {
            mainWindowController = MainWindowController()
        }
        mainWindowController?.showWindow(self)
        mainWindowController?.window?.delegate = self
    }
    
    private func showAboutWindow() {
        if aboutWindowController == nil {
            aboutWindowController = AboutWindowController()
        }
        aboutWindowController?.showWindow(self)
        aboutWindowController?.window?.delegate = self
    }

}
