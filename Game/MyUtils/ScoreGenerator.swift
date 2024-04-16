//
//  ScoreGenerator.swift
//  Game
//
//  Created by Nitrotech Asia on 16/04/2024.
//

import Foundation

class ScoreGenerator {
    static let shared = ScoreGenerator()
    static let keyHeightScore = "keyHeightScore"
    static let keyScore = "keyScore"
    private init() {}

    func setScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyScore)
    }

    func getScore(_ score: Int) -> Int {
        UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }

    func setHightScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: ScoreGenerator.keyHeightScore)
    }

    func getHightScore() -> Int {
        UserDefaults.standard.integer(forKey: ScoreGenerator.keyScore)
    }
}
