//
//  LoadingFooterView.swift
//  GitHubReposApp
//
//  Created by 前澤健一 on 2021/06/29.
//

import UIKit

class LoadingFooterView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    func configure() {
        let nib = UINib(nibName: "LoadingFooterView", bundle: nil)
        guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return }
        addSubview(view)
    }
}
