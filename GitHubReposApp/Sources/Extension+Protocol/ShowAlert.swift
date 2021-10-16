//
//  ShowAlert.swift
//  GitHubReposApp
//
//  Created by 前澤健一 on 2021/06/29.
//

import UIKit

protocol ShowAlert {}

extension ShowAlert where Self: UIViewController{
    ///エラーアラートを表示
    func showErrorAlert(title: String?, message: String) {
        let actionAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "閉じる", style: UIAlertAction.Style.cancel, handler: nil)
        actionAlert.addAction(cancelAction)
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    func showErrorAlert(title: String?, message: String, completion: @escaping () -> ()) {
        let actionAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { action in
            //OKボタンがタップされたときの処理
            completion()
        }
        actionAlert.addAction(okAction)
        self.present(actionAlert, animated: true, completion: nil)
    }
    
    ///確認アラートを表示
    func showAlertDialog(message: String?, okButtonOperating: @escaping () -> ()) {
        guard let message = message else { return }
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: UIAlertController.Style.alert)
        //OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: .default){ (action: UIAlertAction) in
            //OKボタンがタップされたときの処理
            okButtonOperating()
        }
        alertController.addAction(okAction)
        //cancelボタンを追加
        let cancelButton = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        alertController.addAction(cancelButton)
        //アラートダイアログを表示
        self.present(alertController, animated: true, completion: nil)
    }
}

