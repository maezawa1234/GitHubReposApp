import RxDataSources

struct SearchUserSectionModel: AnimatableSectionModelType {
    typealias Item = UserCellData
    
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
