//
//  Progress.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/18.
//

import Foundation

extension ViewController {
    func configureProgressView() {
        progressView.trackTintColor = .blue
        progressView.progressTintColor = .orange
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        progressView.topAnchor.constraint(equalTo: historyBtn.bottomAnchor, constant: 5).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: view.bounds.width / 3 * 2).isActive = true
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func resetPrg() {
        prg = 0
        progressView.setProgress(0, animated: false)
    }
    
    @objc func pushPrg() {
        prg += 10
        progressView.setProgress(Float(prg) / 100, animated: true)
    }
}
