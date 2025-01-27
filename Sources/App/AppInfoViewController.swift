//
//  Example
//  man.li
//
//  Created by man.li on 11/11/2018.
//  Copyright © 2020 man.li. All rights reserved.
//

import UIKit
import MessageUI

class AppInfoViewController: UITableViewController {
    
    @IBOutlet weak var labelVersionNumber: UILabel!
    @IBOutlet weak var labelBuildNumber: UILabel!
    @IBOutlet weak var labelBundleName: UILabel!
    @IBOutlet weak var labelScreenResolution: UILabel!
    @IBOutlet weak var labelDeviceModel: UILabel!
    @IBOutlet weak var labelCrashCount: UILabel!
    @IBOutlet weak var labelBundleID: UILabel!
    @IBOutlet weak var labelserverURL: UILabel!
    @IBOutlet weak var labelIOSVersion: UILabel!
    @IBOutlet weak var labelHtml: UILabel!
    @IBOutlet weak var crashSwitch: UISwitch!
    @IBOutlet weak var logSwitch: UISwitch!
    @IBOutlet weak var resetLogButton: UIButton!
    @IBOutlet weak var networkSwitch: UISwitch!
    @IBOutlet weak var webViewSwitch: UISwitch!
    @IBOutlet weak var slowAnimationsSwitch: UISwitch!
    @IBOutlet weak var naviItem: UINavigationItem!
    @IBOutlet weak var rnSwitch: UISwitch!
    @IBOutlet weak var fpsSwitch: UISwitch!
    
    var naviItemTitleLabel: UILabel?
    
    //MARK: - init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        naviItemTitleLabel = UILabel.init(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        naviItemTitleLabel?.textAlignment = .center
        naviItemTitleLabel?.textColor = Color.mainGreen
        naviItemTitleLabel?.font = .boldSystemFont(ofSize: 20)
        naviItemTitleLabel?.text = "App"
        naviItem.titleView = naviItemTitleLabel
        
        labelCrashCount.frame.size = CGSize(width: 30, height: 20)
        
        labelVersionNumber.text = CocoaDebugDeviceInfo.sharedInstance().appVersion
        labelBuildNumber.text = CocoaDebugDeviceInfo.sharedInstance().appBuiltVersion
        labelBundleName.text = CocoaDebugDeviceInfo.sharedInstance().appBundleName
        
        labelScreenResolution.text = "\(Int(CocoaDebugDeviceInfo.sharedInstance().resolution.width))" + "*" + "\(Int(CocoaDebugDeviceInfo.sharedInstance().resolution.height))"
        labelDeviceModel.text = "\(CocoaDebugDeviceInfo.sharedInstance().getPlatformString)"
        
        labelBundleID.text = CocoaDebugDeviceInfo.sharedInstance().appBundleID
        
        labelserverURL.text = CocoaDebugSettings.shared.serverURL
        labelIOSVersion.text = UIDevice.current.systemVersion
        
        if UIScreen.main.bounds.size.width == 320 {
            labelHtml.font = UIFont.systemFont(ofSize: 15)
        }
        
        logSwitch.isOn = CocoaDebugSettings.shared.enableLogMonitoring
        networkSwitch.isOn = !CocoaDebugSettings.shared.disableNetworkMonitoring
        rnSwitch.isOn = CocoaDebugSettings.shared.enableRNMonitoring
        webViewSwitch.isOn = CocoaDebugSettings.shared.enableWKWebViewMonitoring
        slowAnimationsSwitch.isOn = CocoaDebugSettings.shared.slowAnimations
        crashSwitch.isOn = CocoaDebugSettings.shared.enableCrashRecording
        fpsSwitch.isOn = CocoaDebugSettings.shared.enableFpsMonitoring

        logSwitch.addTarget(self, action: #selector(logSwitchChanged), for: UIControl.Event.valueChanged)
        networkSwitch.addTarget(self, action: #selector(networkSwitchChanged), for: UIControl.Event.valueChanged)
        rnSwitch.addTarget(self, action: #selector(rnSwitchChanged), for: UIControl.Event.valueChanged)
        webViewSwitch.addTarget(self, action: #selector(webViewSwitchChanged), for: UIControl.Event.valueChanged)
        slowAnimationsSwitch.addTarget(self, action: #selector(slowAnimationsSwitchChanged), for: UIControl.Event.valueChanged)
        crashSwitch.addTarget(self, action: #selector(crashSwitchChanged), for: UIControl.Event.valueChanged)
        fpsSwitch.addTarget(self, action: #selector(fpsSwitchChanged), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let count = UserDefaults.standard.integer(forKey: "crashCount_CocoaDebug")
        labelCrashCount.text = "\(count)"
        labelCrashCount.textColor = count > 0 ? .red : .white
    }
    
    //MARK: - alert
    func showAlert() {
        let alert = UIAlertController.init(title: nil, message: "You must restart APP to ensure the changes take effect", preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: "Restart later", style: .cancel, handler: nil)
        let okAction = UIAlertAction.init(title: "Restart now", style: .destructive) { _ in
            exit(0)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - target action
    @objc func fpsSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableFpsMonitoring = fpsSwitch.isOn
        if fpsSwitch.isOn == true {
            WindowHelper.shared.startFpsMonitoring()
        } else {
            WindowHelper.shared.stopFpsMonitoring()
        }
    }
    
    @objc func crashSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableCrashRecording = crashSwitch.isOn
        self.showAlert()
    }
    
    @objc func networkSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.disableNetworkMonitoring = !networkSwitch.isOn
        self.showAlert()
    }
    
    @objc func logSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableLogMonitoring = logSwitch.isOn
        self.showAlert()
    }
    
    @objc func rnSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableRNMonitoring = rnSwitch.isOn
        self.showAlert()
    }
    
    @objc func webViewSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.enableWKWebViewMonitoring = webViewSwitch.isOn
        self.showAlert()
    }
    
    @objc func slowAnimationsSwitchChanged(sender: UISwitch) {
        CocoaDebugSettings.shared.slowAnimations = slowAnimationsSwitch.isOn
    }
    
    @IBAction func resetLogs(_ sender: Any) {
        _OCLogStoreManager.shared()?.resetNormalLogs()
        _OCLogStoreManager.shared()?.resetRNLogs()
        _OCLogStoreManager.shared()?.resetWebLogs()
    }
    
    @IBAction func sendFullReport(_ sender: Any) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "share via email", style: .default) { [weak self] action -> Void in
            if let mailComposeViewController = self?.configureMailComposer() {
                self?.present(mailComposeViewController, animated: true, completion: nil)
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }
    
}


//MARK: - UITableViewDelegate
extension AppInfoViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        if section == 0 {
            return 56
        }
        return 38
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        if indexPath.section == 1 && indexPath.row == 4 {
            if labelserverURL.text == nil || labelserverURL.text == "" {
                return 0
            }
        }
        
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && indexPath.row == 2 {
            UIPasteboard.general.string = CocoaDebugDeviceInfo.sharedInstance().appBundleName
            
            let alert = UIAlertController.init(title: "copied bundle name to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            
            alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 3 {
            UIPasteboard.general.string = CocoaDebugDeviceInfo.sharedInstance().appBundleID
            
            let alert = UIAlertController.init(title: "copied bundle id to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            
            alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        if indexPath.section == 1 && indexPath.row == 4 {
            if labelserverURL.text == nil || labelserverURL.text == "" {return}
            
            UIPasteboard.general.string = CocoaDebugSettings.shared.serverURL
            
            let alert = UIAlertController.init(title: "copied server to clipboard", message: nil, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
            alert.addAction(action)
            
            alert.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension AppInfoViewController: MFMailComposeViewControllerDelegate {
    
    func configureMailComposer(_ copy: Bool = false) -> MFMailComposeViewController? {
        if !MFMailComposeViewController.canSendMail() {
            if copy == false {
                //share via email
                let alert = UIAlertController.init(title: "No Mail Accounts", message: "Please set up a Mail account in order to send email.", preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK", style: .cancel) { _ in
//                    CocoaDebugSettings.shared.responseShakeNetworkDetail = true
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            } else {
                //copy to clipboard
//                CocoaDebugSettings.shared.responseShakeNetworkDetail = true
            }
            
            return nil
        }
        
        if copy == true {
            //copy to clipboard
//            CocoaDebugSettings.shared.responseShakeNetworkDetail = true
            return nil
        }
        
        //3.email recipients
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        //5.body
        
        let body = """
        logs = \(getLogs())
        
        crashes = \(getCrashes())
        """
        
        mailComposeVC.setMessageBody(body, isHTML: false)
        
        //6.subject
        mailComposeVC.setSubject("Genda Report")

        return mailComposeVC
    }
    
    func mailComposeController(
        _ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult,
        error: Error?
    ) {
        controller.dismiss(animated: true)
    }
    
    private func getCrashes() -> String {
        let crashes = CrashStoreManager.shared.crashArray
        .map {$0.toString()}
        .joined(separator: "\n\n\n")
        return crashes
    }
    
    private func getLogs() -> String {
        let logs1 = _OCLogStoreManager
        .shared()?
        .normalLogArray
        .compactMap {($0 as? _OCLogModel)?.content} ?? []
        
        let logs2 = _OCLogStoreManager
            .shared()?
            .rnLogArray
            .compactMap {($0 as? _OCLogModel)?.content} ?? []
        
        let logs3 = _OCLogStoreManager
        .shared()?
        .webLogArray
        .compactMap {($0 as? _OCLogModel)?.content} ?? []
        
        return (logs1+logs2+logs3).joined(separator: "\n\n\n")
    }
}
