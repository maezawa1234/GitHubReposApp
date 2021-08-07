# GitHubReposApp

Git Hub Repos App は**GitHubAPI**を使い、ユーザーを検索し、リポジトリの情報を閲覧することができるアプリです。  
**RxSwift** を使い**MVVMアーキテクチャ**パターンによる実装を行いました。  

**RxDataSource**を使うことでTablevViewと表示データのバインド処理を実装しました。APIから取得したデータの差分管理、アニメーションによる画面への表示等をこのRxDataSourceライブラリによって実装しています。


SearchUser画面ではサーチバーからユーザーを検索し検索結果を表示します。取得したユーザーの一覧と検索結果の件数を表示するようになっています。  
UserRepos画面では検索したユーザーのリポジトリ情報を一覧で取得し、一覧表示します。  
RepoDetail画面では選択したリポジトリのURLからWebページ上で詳細な情報を閲覧することができます。

リポジトリのお気に入り機能を追加しました。お気に入り登録したリポジトリを保存し、リストから閲覧、管理する事が出来ます。

UIの実装について
ActivityIndicatorを実装しデータ取得中はローディングアニメーションが表示されるようにしました。  
ProgressBarを実装し、リポジトリ詳細画面でのWeb表示のローディングアニメーションを実装しました。

![GitHubReposPreview](https://user-images.githubusercontent.com/52379412/128586771-85fdb74e-d848-4986-88fd-abef5663de4f.gif)



