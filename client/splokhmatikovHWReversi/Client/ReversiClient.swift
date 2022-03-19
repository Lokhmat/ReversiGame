//
//  ReversiClient.swift
//  splokhmatikovHWReversi
//
//  Created by Sergey Lokhmatikov on 19.03.2022.
//

import UIKit

class ReversiClient{
    
    static func getBest(table: Table){
        let URL = URL(string: "http://127.0.0.1:8000/reversi/get_best_score?username=\(UIDevice.current.identifierForVendor!)")!
        let task = URLSession.shared.dataTask(with: URL) { data, response, error in
            if let jsonData = String(data:data ?? Data(), encoding: String.Encoding.ascii)?.data(using: String.Encoding.utf8)  {
                do {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Int]
                    if (json != nil){
                        if (json!["User"] ?? -1 > table.bestPlayerOne ?? -1){
                            table.bestPlayerOne = json!["User"]
                            table.bestPlayerTwo = json!["Iphone"]
                            table.saveMaxResult()
                        }
                    }
                } catch{
                    print("Kek")
                }
            }
        }
        task.resume()
    }
    
    static func postBest(score: (Int, Int)){
        let URL = URL(string: "http://127.0.0.1:8000/reversi/post_best_score?username=\(UIDevice.current.identifierForVendor!)&phone_score=\(score.1)&user_score=\(score.0)")!
        let task = URLSession.shared.dataTask(with: URL) {_,_,_ in }
        task.resume()
    }
}
