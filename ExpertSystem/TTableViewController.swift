//
//  TTableViewController.swift
//  ExpertSystem
//
//  Created by Georgy on 17.10.2022.
//

import UIKit
import RealmSwift
class TTableViewController: UITableViewController,ExpandableHeaderViewDelegate {
    // Generate a random encryption key
    let app = App(id: "application-0-rvgoc")
    let realm = try! Realm()
   
    let quest = Quest()

    class RealmDBHandler: NSObject {
        let app = App(id: "application-0-rvgoc")
        lazy var user = app.currentUser!
        lazy var partitionValue = "user_id=abcdefg"// Specific to the user id that created
        lazy var configuration = user.configuration(partitionValue: partitionValue)
        static let shared: RealmDBHandler = {
            let instance = RealmDBHandler()
            return instance
        }()
        var realm: Realm? {
          let config = configuration
          print(config.fileURL as Any)
          do {
              return try Realm(configuration: config)
          } catch let error {
            print(error.localizedDescription)
            return nil
          }
        }
    }
    
    class RealmSyncRemoteStore {
        var pdfResult: Results<Quest>?
        var notificationToken: NotificationToken?
        var id: String = ""
        var isReadOnly: Bool = false
        var realmObjectsReady: (() -> Void)?
        lazy var realm: Realm? = RealmDBHandler.shared.realm
        func authenticate() {
            RealmDBHandler.shared.app.login(credentials: Credentials.anonymous) { (result) in
                // Remember to dispatch back to the main thread in completion handlers
                // if you want to do anything on the UI.
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        print("Login failed: \(error)")
                    case .success(let user):
                        print("Login as \(user) succeeded!")
                        self.realm = RealmDBHandler.shared.realm
                        self.openRealm()
                        // Continue below
                    }
                }
            }
        }
        private func openRealm() {
            // Open the realm asynchronously to ensure backend data is downloaded first.
            Realm.asyncOpen(configuration: RealmDBHandler.shared.configuration) { (result) in
                switch result {
                case .failure(let error):
                    print("Failed to open realm: \(error.localizedDescription)")
                    // Handle error...
                case .success(let realm):
                    print("Realm opened")
                    if !self.isReadOnly {
                        self.testCreateObject()
                    }
                    self.fetchObjects()
                    // Realm opened
                }
            }
        }
        private func testCreateObject() {
            if let path = Bundle.main.path(forResource: "sample", ofType: "pdf") {
                if let pdfData = try? Data(contentsOf: URL(fileURLWithPath: path)) {
                    let quest1 = Quest()
                    quest1.ID = 1
                    quest1.Answer = "test"
                    // Bucketing id
                    try? realm?.write {
                        realm?.add(quest1, update: .modified)
                        try? realm?.commitWrite()
                    }
                    print("PDF Data", quest1)
                }
            }
        }
            private func fetchObjects() {
                guard let result = realm?.objects(Quest.self) else {
                    return
                }
                pdfResult = result
                realmObjectsReady?()
            }
    }

//    func useRealm(realm:Realm, user: User){
//        let quest = Quest(name: "Do laundry", ownerId: user.id)
//        try! realm.write {
//            realm.add(quest)
//        }
//    }
//   func openSyncedRealm(user: User) async {
//        do {
//            var config = user.flexibleSyncConfiguration()
//            // Pass object types to the Flexible Sync configuration
//            // as a temporary workaround for not being able to add a
//            // complete schema for a Flexible Sync app.
//            config.objectTypes = [Quest.self]
//            let realm = try await Realm(configuration: config, downloadBeforeOpen: .always)
//            // You must add at least one subscription to read and write from a Flexible Sync realm
//            let subscriptions = realm.subscriptions
//            try await subscriptions.update {
//                subscriptions.append(
//                    QuerySubscription<Quest> {
//                        $0.ownerId == user.id
//                    })
//            }
//            await useRealm(realm: realm, user: user)
//        } catch {
//            print("Error opening realm: \(error.localizedDescription)")
//        }
//    }
    
    @IBOutlet var ItemsTableView: UITableView!
    
    override func viewDidLoad(){
        
//        let queue = DispatchQueue.global(qos: .utility)
//        queue.async{
//            do {
//                let user = try await app.login(credentials: Credentials.anonymous)
//                print("Successfully logged in user: \(user)")
//                await openSyncedRealm(user: user)
//            } catch {
//                print("Error logging in: \(error.localizedDescription)")
//            }
//        }
        
        
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        print(realm)
        super.viewDidLoad()
        ItemsTableView.dataSource = self
        quest.ID = 1
        quest.AnsType = 0
        quest.Answer = "How are you?"
        quest.Asked = false
        try! realm.write {
            realm.add(quest)
        }

        sections = [
            Sections(Filter: "Question 1", FilterFill: ["\(quest.ID)","\(quest.Answer)","\(quest.AnsType)"], Expanded: false),
            Sections(Filter: "Question 2", FilterFill: ["500-1000$","1000-2000$","2000$-3000$"], Expanded: false),
            Sections(Filter: "Question 3", FilterFill: ["1-2m","2-3m","3-4m"], Expanded: false)
        ]
    }

    // MARK: - Table view data source
    
    func ToogleSections(header: ExpandableHeaderView, section: Int) {
        sections[section].Expanded.toggle()
        ItemsTableView.beginUpdates()
        for row in 0..<sections[section].Filter.count{
            ItemsTableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
        }
        ItemsTableView.endUpdates()
    }
    
    
    var sections = [
        Sections(Filter: "Question 1", FilterFill: ["","Apple","Huawei"], Expanded: false),
        Sections(Filter: "Question 2", FilterFill: ["500-1000$","1000-2000$","2000$-3000$"], Expanded: false),
        Sections(Filter: "Question 3", FilterFill: ["1-2m","2-3m","3-4m"], Expanded: false)
    ]
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
       return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sections[section].FilterFill.count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if sections[indexPath.section].Expanded{
            return 44
        }
        return 0
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 2
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = ExpandableHeaderView()
        header.setup(withTitle: sections[section].Filter, Section: section, delegate: self)
       return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        if cell.TextQuest.text == ""{
            cell.textLabel?.text = sections[indexPath.section].FilterFill[indexPath.row]
            switch indexPath.row{
            case 0:
                cell.TextQuest.text = quest.Answer
                return cell
            case 1:
                cell.TextQuest.text = "\(quest.ID)"
                return cell
            case 2:
                cell.TextQuest.text = "\(quest.AnsType)"
                return cell
            default:
                return cell
            }
        }
        else {
            switch indexPath.row{
            case 0:
                try! realm.write {
                quest.Answer = cell.TextQuest.text ?? ""
                realm.add(quest)
                }
                return cell
            case 1:
//                cell.TextQuest.text = "\(quest.ID)"
                return cell
            case 2:
//                cell.TextQuest.text = "\(quest.AnsType)"
                return cell
            default:
                return cell
            }
        }
    }
    
    
    
    @IBAction func ChangeTableView(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            sections = [
                Sections(Filter: "now  ", FilterFill: ["Samsung","Apple","Huawei","test"], Expanded: false),
                Sections(Filter: "we   ", FilterFill: ["500-1000$","1000-2000$","2000$-3000$"], Expanded: false),
                Sections(Filter: "go", FilterFill: ["1-2m","2-3m","3-4m"], Expanded: false)
            ]
        case 1:
            sections = [
                Sections(Filter: "be", FilterFill: ["Samsung","Apple","Huawei"], Expanded: false),
                Sections(Filter: "carefully", FilterFill: ["500-1000$","1000-2000$","2000$-3000$"], Expanded: false),
                Sections(Filter: "man", FilterFill: ["1-2m","2-3m","3-4m"], Expanded: false)
            ]
        case 2:
            sections = [
                Sections(Filter: "Brand", FilterFill: ["Samsung","Apple","Huawei"], Expanded: false),
                Sections(Filter: "Price", FilterFill: ["500-1000$","1000-2000$","2000$-3000$"], Expanded: false),
                Sections(Filter: "Size", FilterFill: ["1-2m","2-3m","3-4m"], Expanded: false)
            ]
        default:
            return
        }
        ItemsTableView.reloadData()
    }

    @IBAction func InsertItem(_ sender: UIButton) {
        sections.append(Sections(Filter: "test", FilterFill:Array(repeating: "Z", count: sections[0].FilterFill.count), Expanded: false))
        ItemsTableView.reloadData()
    }
    
    @IBAction func ChangingItem(_ sender: UITextField) {
//        if let cell = ItemsTableView.dequeueReusableCell(withIdentifier: "cell") as? TableViewCell{
//            print(ItemsTableView.indexPath(for: cell))
//        }
//        if let cell = tableView(ItemsTableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? TableViewCell {
//            print(cell.TextQuest.text)
//        }
        ItemsTableView.reloadData()
    }
}
