import RxDataSources

struct SearchUserSectionModel: AnimatableSectionModelType {
    typealias Item = User
    
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

extension User: IdentifiableType, Equatable {
    var identity: Int {
        return self.id
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return rhs.id == rhs.id
    }
}

