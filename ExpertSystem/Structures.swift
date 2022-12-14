//
//  Structures.swift
//  ExpertSystem
//
//  Created by Georgy on 17.10.2022.
//
import RealmSwift
class Quest: Object {
    @Persisted var ID:Int
    @Persisted var Question:String
    @Persisted var AnsType:Int
    @Persisted var Answer:List<String>
    @Persisted var Asked:Bool
    @Persisted var Parametr:String
    @Persisted var IsThisAtribute:Bool
    @Persisted var Order:Int
    
}
class Answers:Object{
    @Persisted var ID:Int
    @Persisted var QuestID:Int
    @Persisted var Answer:List<String>
}
class Changes: Object{
    @Persisted var ID:Int
    @Persisted var Parametr:String
    @Persisted var Value:String
}
class QuestRules: Object{
    @Persisted var ID:Int
    @Persisted var If_Par:String
    @Persisted var if_Value:String
    @Persisted var NextQuest:Quest?
    @Persisted var NoAsk:List<Int>
}
struct Sections{
    var Filter:String
    var FilterFill: [String]
    var Expanded: Bool
}
