import Foundation

struct RepoStatus: Equatable {
    let repo: Repository
    let isFavorite: Bool
    
    // リポジトリが同じであればtrue
    static func == (lhs: RepoStatus, rhs: RepoStatus) -> Bool {
        return lhs.repo == rhs.repo && lhs.isFavorite == rhs.isFavorite
    }
}

extension Array where Element == RepoStatus {
    init(repos: [Repository], favoriteStatuses: [Int: Bool]) {
        self = repos.map { repo in
            RepoStatus(
                repo: repo,
                isFavorite: favoriteStatuses[repo.id] ?? false
            )
        }
    }
}

struct RepoStatusList {
    enum Error: Swift.Error {
        case notFoundRepo(ofID: Int)
    }
    
    private(set) var statuses: [RepoStatus]
    
    mutating func append(repos: [Repository], favoriteStatuses: [Int: Bool]) {
        let newStatusesMayNotUnique = self.statuses + Array(repos: repos, favoriteStatuses: favoriteStatuses)
        
        statuses = newStatusesMayNotUnique
            .unique { _, _ in .removeOldOne }
    }
    
    init(repos: [Repository], favoriteStatuses: [Int: Bool], isOnlyFavorite: Bool = false) {
        self.statuses = Array(repos: repos, favoriteStatuses: favoriteStatuses)
            .unique(resolve: { _, _ in .ignoreNewOne})
        if isOnlyFavorite {
            self.statuses = statuses.filter { $0.isFavorite }
        }
        print("XXXXXXXXXXXXXXXXXXXX")
        print(self.statuses.map { $0.isFavorite })
    }
    
    mutating func set(isFavorite: Bool, for id: Int) throws {
        guard let index = statuses.firstIndex(where: { $0.repo.id == id }) else {
            //throw Error.notFoundRepo(ofID: id)
            return
        }
        let currentStatus = statuses[index]
        statuses[index] = RepoStatus(
            repo: currentStatus.repo,
            isFavorite: isFavorite
        )
    }
    
    subscript(id: Int) -> RepoStatus? {
        return statuses.first(where: { $0.repo.id == id })
    }
}

