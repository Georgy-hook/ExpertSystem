//
//  ExpandableHeaderView.swift
//  Ecomercie concept
//
//  Created by Georgy on 21.09.2022.
// Протокол раскрывающиегося списка на основе tableView для фильтров

import UIKit
protocol ExpandableHeaderViewDelegate {
    func ToogleSections(header: ExpandableHeaderView, section:Int)
}
class ExpandableHeaderView: UITableViewHeaderFooterView {
    var delegate: ExpandableHeaderViewDelegate?
    var Section: Int?
    
    func setup(withTitle title:String, Section: Int, delegate: ExpandableHeaderViewDelegate){
        self.delegate = delegate
        self.Section = Section
        self.textLabel?.text = title
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.textColor = .black
        contentView.backgroundColor = .white
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
    }
   
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func selectHeaderAction(gesterRecognizer: UITapGestureRecognizer){
        let cell = gesterRecognizer.view as! ExpandableHeaderView
        delegate?.ToogleSections(header: self, section: cell.Section!)
    }
}
