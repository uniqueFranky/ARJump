//
//  HistoryTableViewCell.swift
//  ARJump
//
//  Created by 闫润邦 on 2022/7/16.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    let scoreLabel = UILabel()
    let timeLabel = UILabel()
    var hasSet = false
    
    func setup(withScore score: Int, time: Date) {
        
        scoreLabel.text = "得分： " + String(score)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y/MM/dd HH:mm:ss"
        timeLabel.text = "时间： " + dateFormatter.string(from: time)
        
        if hasSet {
            return
        }
        hasSet = true
        contentView.addSubview(scoreLabel)
        contentView.addSubview(timeLabel)
        
        scoreLabel.textAlignment = .center
        timeLabel.textAlignment = .center
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        scoreLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        scoreLabel.widthAnchor.constraint(equalToConstant: contentView.bounds.width / 3).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        scoreLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        timeLabel.topAnchor.constraint(equalTo: scoreLabel.topAnchor).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: scoreLabel.bottomAnchor).isActive = true
        timeLabel.leadingAnchor.constraint(equalTo: scoreLabel.trailingAnchor).isActive = true
        timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: true)
        super.setSelected(false, animated: true)
        

        // Configure the view for the selected state
    }

}
