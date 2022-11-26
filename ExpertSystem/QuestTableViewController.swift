//
//  QuestTableViewController.swift
//  ExpertSystem
//
//  Created by Georgy on 17.11.2022.
//

import UIKit
import RealmSwift
class QuestTableViewController: UITableViewController {
    let realm = try! Realm(configuration: .init(schemaVersion: 7))
    let quest2 = try! Realm().objects(Quest.self).sorted(byKeyPath: "Order")
    let cnhg = try! Realm().objects(Changes.self)
    let rules = try! Realm().objects(QuestRules.self)
    let typedrink = try! Realm().objects(TypeDrink.self)
    let tripleProductionRules = try! Realm().objects(TripleProduction.self)
    let doubleProductionRules = try! Realm().objects(DoubleProduction.self)
    var  Order = 0
    var nextquest:Quest?
    var drink = ["","",""]
    var result = ""
    
    func ClearFootprint() {
        for i in 0...quest2.count-1{
            try! realm.write {
                quest2[i].Asked = false
            }
        }
        try! realm.write{
            self.realm.delete(cnhg)
        }
    }
    
    func ShowAlert(){
        let alert = UIAlertController(title: "Ваш напиток", message: result, preferredStyle: .alert)
        let OkButton = UIAlertAction(title: "Ok", style: .default)
            let noBtn =  UIAlertAction(title: "Exit", style: .destructive, handler: { (action:UIAlertAction!) -> Void in
                exit(0)
             })
        alert.addAction(OkButton)
        alert.addAction(noBtn)
        present(alert, animated: true)
    }

    func AskNext(){
        for ord in Order...quest2.count-1{
            if quest2[ord].Asked == false {
               nextquest = quest2[ord]
                break
            }
            else {
                Order += 1
            }
        }
        
        if Order >= quest2.count - 1  {
            ResultDrink()
            ShowAlert()
            ClearFootprint()
           
        }
    }
    
    func ResultDrink(){
        for rule in 0...tripleProductionRules.count-1 {
            if cnhg[0].Value == tripleProductionRules[rule].Value1 {
                if cnhg[1].Value == tripleProductionRules[rule].Value2{
                    if cnhg[2].Value == tripleProductionRules[rule].Value3 {
                        drink[0] = tripleProductionRules[rule].ValueAtr
                    }
                }
            }
        }
        for rule in 0...doubleProductionRules.count-1 {
            if drink[0] == doubleProductionRules[rule].Value1{
                if cnhg[doubleProductionRules[rule].ID].Value == doubleProductionRules[rule].Value2{
                    drink[doubleProductionRules[rule].TypeAtr] = doubleProductionRules[rule].ValueAtr
                }
            }
        }
       // print(drink)
        for typ in 0...typedrink.count - 1 {
            if drink[0] == typedrink[typ].Atr1{
                if drink[1] == typedrink[typ].Atr2{
                    if drink[2] == typedrink[typ].Atr3{
                        result = typedrink[typ].Drink
 
                    }
                }
            }
        }
    }
    
    func NextQuest() {
        Order += 1
        if quest2[Order].Asked == true{
            AskNext()
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
