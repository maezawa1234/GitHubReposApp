import Foundation

struct RepoStatus: Equatable {
    let repo: Repository
    let isFavorite: Bool
    
    // リポジトリが同じであればtrue
    static func == (lhs: RepoStatus, rhs: RepoStatus) -> Bool {
        return lhs.repo == rhs.repo
    }
}

extension Array where Element == RepoStatus {
    init(repos: [RepoStatus], )
}

var list: [RepoStatus] = [RepoStatus]([repos: , likes[:]])
