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

extension RepoStatus: IdentifiableType {
    var identity: Int {
        self.repo.id
    }
}

