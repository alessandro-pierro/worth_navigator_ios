import Foundation

@objc @objcMembers class MapHandler: NSObject
{
  static let shared = MapHandler()
  
  var timer = Timer()
  var started = false

  func loadFileFromDocumentsFolder() {
    started = true
    
    let formatter = DateFormatter ()
    let decoder   = JSONDecoder   ()
    
    decoder.dateDecodingStrategy = .formatted(formatter)

    let store = UserDefaults(suiteName: WorthGlobal.group_worth.rawValue)
    let data = store!.value(forKey: WorthSession.stored_maps.rawValue) as? Data
    
    if data != nil
    {
      do{
          let maps = try decoder.decode([WorthMap].self, from: data! )
          for map in maps
          {
            self.store(withURL: map.path, name: map.name)
          }
          registerMaps()
        
      }catch{
        print("ERROR \(error)")
      }
    }
  }

  func store(withURL: URL, name: String) {
    let documentsPath = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
    let logsPath = documentsPath.appendingPathComponent( WorthGlobal.maps_folder.rawValue )

    do {
      
      if(!FileManager.default.fileExists(atPath: logsPath!.path))
      {
        try FileManager.default.createDirectory(atPath: logsPath!.path, withIntermediateDirectories: true, attributes: nil)
      }
      
      do
      {
        deleteIfExist(del: logsPath!.appendingPathComponent(name))
        let newPath = logsPath!.appendingPathComponent(name)
        if(FileManager.default.fileExists(atPath: withURL.path))
        {
          try FileManager.default.copyItem(at: withURL, to: newPath)
        }
        removeElement(key: name)
      }catch _ as NSError  {}
    }catch _ as NSError  {}
  }

  public func registerMaps()
  {
    WorthMapHelper.registerMaps()
    started = false
  }

  func deleteIfExist(del: URL)
  {
      if(FileManager.default.fileExists(atPath: del.path))
      {
          do
          {
              try FileManager.default.removeItem(at: del)
          }catch _ as NSError {}
      }
  }
  
  func removeElement(key: String)
  {
    let store = UserDefaults(suiteName: WorthGlobal.group_worth.rawValue )

      let formatter = DateFormatter()
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .formatted(formatter)
      let data = store!.value(forKey: WorthSession.stored_maps.rawValue ) as? Data
      if data != nil
      {
        do{
            var maps = try decoder.decode([WorthMap].self, from: data! )
            var i = 0
            for map in maps
            {
                if(map.name == key)
                {
                  maps.remove(at: i)
                  if let data = try? JSONEncoder().encode(maps) {
                      store!.set(data, forKey: WorthSession.stored_maps.rawValue)
                  }
                  return
                }
                i = i + 1
            }
        }catch {}
      }
  }


}

