import Foundation
import UIKit

fileprivate enum WorthDeepLinkType {
  case navigator
  case addMap
}


@objc enum WorthReturnCode: Int {
  case navigation_ended         = -1
  case navigation_interrupted   = -2
  case navigate_back            =  0
  
}

@objc enum WorthReturnMsg: Int {
  case home
  case alarm
  case resume
  
  func raw () -> String {
      switch self {
        case .home    : return "HOME"
        case .alarm   : return "ALARM"
        case .resume  : return ""
      }
  }
}

enum WorthGlobal: String {
  case group_worth  = "group.safetyisworth"
  case scheme       = "worthapp"
  case path         = "/"
  case maps_folder  = "190910"
}

enum WorthSession: String {
  case saving_position      = "savingPosition"
  case started_from_worth   = "started_from_worth"
  case is_in_navigation     = "is_in_navigation"
  case stored_maps          = "stored_maps"
}

@objc @objcMembers class WorthDeepLinkHandler: NSObject {
  @objc static let shared = WorthDeepLinkHandler()
  
  private func deepLinkType(_ deeplink: URL) -> WorthDeepLinkType? {
      switch deeplink.scheme {
        case "worthnavigator":
          return .navigator
        case "worthaddmap":
          return .addMap
        default:
          return nil
      }
  }

  public func handleInternal(deeplinkURL: URL?) {
    guard let url = deeplinkURL else {
      assertionFailure()
      return
    }
    
    guard let deepLinkType = deepLinkType(url) else { return }

    switch deepLinkType {
      case WorthDeepLinkType.navigator:
      WorthMapHelper.handleNavigatorUrl(url)
      case WorthDeepLinkType.addMap:
        MapHandler.shared.loadFileFromDocumentsFolder()
    }
  }
  
  @objc func goingToWorth(code: WorthReturnCode, msg: WorthReturnMsg)
  {
    
    if(code == WorthReturnCode.navigation_ended)
    {
      let store = UserDefaults(suiteName: WorthGlobal.group_worth.rawValue)
        if let saving = store!.value(forKey: WorthSession.saving_position.rawValue) as? Bool
        {
          if(!saving){return}
        }
    }
    
    var components = URLComponents()
    components.scheme = WorthGlobal.scheme.rawValue
    components.path   = WorthGlobal.path.rawValue

    components.queryItems = [
      URLQueryItem(name: "code" , value: "\(code.rawValue)" ),
      URLQueryItem(name: "msg"  , value:    msg.raw()       ),
    ]
    
    if let url = URL(string: components.url!.absoluteString) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
  }

  @objc func managePowerManager()
  {

    let fileName = "power_manager_config"
    let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)

    let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("")

    let text = "{\"current_state\": [false, false, false, false, false, false, false, false, true, true, true, true], \"scheme\": 3}"
    
    do {
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
      
        WorthMapHelper.loadManager()
    } catch {
        print("failed with error: \(error)")
    }
  }
  
}
