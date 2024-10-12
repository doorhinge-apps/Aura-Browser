import SwiftUI
import SwiftData

@Model
class UrlInfo {
    var urlString: String
    var title: String?
    var id: String?
    
    init(urlString: String, title: String? = nil, id: String? = nil) {
        self.urlString = urlString
        self.title = title
        self.id = id
    }
}

@Model
class SpaceStorage {
    var spaceIndex: Int = 0
    var spaceName: String = ""
    var spaceIcon: String = ""
    @Relationship(deleteRule: .cascade) var favoritesUrls: [UrlInfo] = []
    @Relationship(deleteRule: .cascade) var pinnedUrls: [UrlInfo] = []
    @Relationship(deleteRule: .cascade) var tabUrls: [UrlInfo] = []
    var startHex: String = ""
    var endHex: String = ""
    var browseForMe: Bool? = false
    var browseForMeSearch: String? = ""
    var browseForMeResponse: String? = ""
    
    init(spaceIndex: Int = 0, spaceName: String = "", spaceIcon: String = "", startHex: String = "8A3CEF", endHex: String = "84F5FE", browseForMe: Bool? = false, browseForMeSearch: String = "", browseForMeResponse: String? = "") {
        self.spaceIndex = spaceIndex
        self.spaceName = spaceName
        self.spaceIcon = spaceIcon
        self.startHex = startHex
        self.endHex = endHex
        self.browseForMe = browseForMe
        self.browseForMeSearch = browseForMeSearch
        self.browseForMeResponse = browseForMeResponse
    }
}
