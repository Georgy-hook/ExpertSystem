//
//  QuestTableViewController.swift
//  ExpertSystem
//
//  Created by Georgy on 17.11.2022.
//

import UIKit
import RealmSwift
class QuestTableViewController: UITableViewController {
   // let quest1 = Quest()
    let realm = try! Realm(configuration: .init(schemaVersion: 4))
    let quest2 = try! Realm().objects(Quest.self).sorted(byKeyPath: "Order")
    let cnhg = try! Realm().objects(Changes.self)
    let rules = try! Realm().objects(QuestRules.self)
    var  Order = 0
    var nextquest:Quest?
    
    
    func NoAsk(){
        for ord in Order...quest2.count{
            if quest2[ord].Asked == false {
               nextquest = quest2[ord]
                break
            }
            else {
                Order += 1
            }
        }
    }
    
    func NextQuest() {
        Order += 1
        if quest2[Order].Asked == true{
           NoAsk()
        }
        else{
            nextquest = quest2[Order]
        }

        for rule in 0...rules.count-1 {
            if quest2[Order-1].Parametr == rules[rule].If_Par{
                if cnhg[Order-1].Value == rules[rule].if_Value{
                    nextquest = rules[rule].NextQuest!
                    for i in 0...rules[rule].NoAsk.count-1{
                        try! realm.write{
                            quest2[rules[rule].NoAsk[i]].Asked = true
                            // print(rules[rule].NoAsk[i])
                            
                        }
                    }
                }
            }
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
nextquest = quest2[Order]
//        let quest1 = Quest()
//        quest1.ID = 1
//        quest1.Answer = "Выберите пол"
//        quest1.AnsType = 1
//        quest1.IsThisAtribute = false
//        quest1.Asked = false
//        quest1.Order = 0
//        quest1.Parametr = "sex"
//        quest1.Question = "Choose sex"
//        let realm = try! Realm()
        
    

//        try! realm.write{
//            realm.add(quest1)
//        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nextquest?.Question
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (nextquest?.Answer.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestCell
        cell.textLabel?.text = nextquest!.Answer[indexPath.row]

        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        if Order >= quest2.count {
//            for i in 0...quest2.count-1{
//                try! realm.write {
//                    quest2[i].Asked = false
//                    exit(1)
//                }
//            }
//        }
//        guard Order > quest2.count else{
//            try! realm.write{
//                cnhg.realm?.deleteAll()
//            }
//            exit(1)
//        }
        let chng = Changes()
        
        chng.ID = quest2[Order].ID
        chng.Value = (quest2[Order].Answer[indexPath.row])
        chng.Parametr = quest2[Order].Parametr
        try! realm.write{
            
            realm.add(chng)
            
            }
            DispatchQueue.main.async {
                    self.NextQuest()
                    tableView.reloadData()
        }
        
      
        
    }



}
