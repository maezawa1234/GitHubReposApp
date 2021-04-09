import RxDataSources

struct UserReposSectionModel: AnimatableSectionModelType {
    typealias Item = RepoStatus
    
    var items: [Item]
    var header: String
    
    init(header: String, items: [Item]) {
        self.header = header
        self.items = items
    }
    
    init(original: UserReposSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
    
    var identity: String {
        return header
    }
}

// FIXME: SecionModelのItemをRepoStatusに変更
extension Repository: IdentifiableType, Equatable {
    var identity: Int {
        self.id
    }
    
    static func == (lhs: Repository, rhs: Repository) -> Bool {
        return lhs.id == rhs.id
    }
}

extension RepoStatus: IdentifiableType {
    var identity: Int {
        self.repo.id
    }
}

