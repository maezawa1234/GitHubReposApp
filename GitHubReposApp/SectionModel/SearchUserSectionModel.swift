import RxDataSources

struct SearchUserSectionModel: AnimatableSectionModelType {
    typealias Item = SearchUserCellDataType
    
    var header: String
    var items: [Item]
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
    
    init(original: SearchUserSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    var identity: String {
        return header
    }
}

enum SearchUserCellDataType: IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Identity {
        switch self {
        case .userItem(let item):
            return item.identity
        case .footerItem(let item):
            return item.identity
        }
    }
    case userItem(UserCellData)
    case footerItem(FooterCellData)
}

struct UserCellData: IdentifiableType, Equatable {
    var identity: Int {
        return self.id
    }
    
    static func == (lhs: UserCellData, rhs: UserCellData) -> Bool {
        return lhs.id == rhs.id
    }
    let id: Int
    let login: String
    let avatarURL: URL
    let name: String?
    init(user: User) {
        self.id = user.id
        self.login = user.login
        self.avatarURL = user.avatarURL
        self.name = user.name
    }
}

struct FooterCellData: IdentifiableType, Equatable {
    var identity: Int {
        return 1
    }
   
    static func == (lhs: FooterCellData, rhs: FooterCellData) -> Bool {
        return lhs.isAnimation == rhs.isAnimation
    }
    var isAnimation: Bool = true
}

