import Foundation

protocol StatisticService {
    var totalCorrectAnswers: Int { get }
    var totalAmount: Int { get }
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}

final class StatisticServiceImplementation: StatisticService {
    private let userDefaults = UserDefaults.standard
    
    var totalCorrectAnswers: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.correct.rawValue),
            let totalCorrectAnswers = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }

            return totalCorrectAnswers
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.correct.rawValue)
        }
    }
    var totalAmount: Int {
        
        get {
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
            let totalAmount = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }

            return totalAmount
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    var totalAccuracy: Double {
        get {
            guard let data = userDefaults.data(forKey: Keys.totalAccuracy.rawValue),
            let totalAccuracy = try? JSONDecoder().decode(Double.self, from: data) else {
                return 0.0
            }

            return totalAccuracy
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    var gamesCount: Int {
        get {
            guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
            let gamesCount = try? JSONDecoder().decode(Int.self, from: data) else {
                return 0
            }

            return gamesCount
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }

            return record
        }

        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }

            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount, totalAccuracy
    }
    
    func store(correct count: Int, total amount: Int) {
        let currentGame: GameRecord = GameRecord(correct: count, total: amount, date: Date())
        if bestGame.isBetterThan(currentGame) {
            bestGame = currentGame
        }
        
        totalCorrectAnswers += count
        totalAmount += amount
        gamesCount += 1
                
        totalAccuracy = Double(totalCorrectAnswers) / Double(totalAmount) * 100
    }
    
}

