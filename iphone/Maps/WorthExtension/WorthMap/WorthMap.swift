import Foundation

class WorthMap: Codable
{
  var path: URL
  var name: String
  
  init(){
    path = URL(fileURLWithPath: "")
    name = ""
  }
}
