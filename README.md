# GitHubReposApp

Git Hub Repos App は**GitHubAPI**を使い、ユーザーを検索し、リポジトリの情報を閲覧することができるアプリです。  
**RxSwift** を使い**MVVMアーキテクチャ**パターンによる実装を行いました。  

**RxDataSource**を使うことでTablevViewと表示データのバインド処理を実装しました。  


SearchUser画面ではサーチバーからユーザーを検索し検索結果を表示します。取得したユーザーの一覧と検索結果の件数を表示するようになっています。  
UserRepos画面では検索したユーザーのリポジトリ情報を一覧で取得し、一覧表示します。  


ActivityIndicatorを実装しデータ取得中はローディングアニメーションが表示されるようにしました。  

![AppPreview](https://user-images.githubusercontent.com/52379412/108257654-76ff1000-71a2-11eb-8cbe-d3903d79adbb.gif)


