import Foundation

nonisolated enum CharacterTheme: String, CaseIterable, Sendable {
    case germs
    case rabbit
    case dog
    case cat
    case rice
    case bread
    case star
    case apple

    var displayName: String {
        switch self {
        case .germs: return "ばい菌"
        case .rabbit: return "うさぎ"
        case .dog: return "わんこ"
        case .cat: return "にゃんこ"
        case .rice: return "おにぎり"
        case .bread: return "パン"
        case .star: return "おほしさま"
        case .apple: return "りんご"
        }
    }

    var appearMessage: String {
        switch self {
        case .germs: return "ばい菌はっけん！"
        case .rabbit: return "うさぎが あそびにきたよ！"
        case .dog: return "わんこが あそびにきたよ！"
        case .cat: return "にゃんこが あそびにきたよ！"
        case .rice: return "おにぎりが あそびにきたよ！"
        case .bread: return "パンが あそびにきたよ！"
        case .star: return "おほしさまが あそびにきたよ！"
        case .apple: return "りんごが あそびにきたよ！"
        }
    }

    var escapeMessage: String {
        switch self {
        case .germs: return "ばい菌があわてて にげてる！"
        case .rabbit: return "うさぎが ぴょんぴょん にげてる！"
        case .dog: return "わんこが わんわん にげてる！"
        case .cat: return "にゃんこが にゃー！と にげてる！"
        case .rice: return "おにぎりが ころころ にげてる！"
        case .bread: return "パンが ふわふわ にげてる！"
        case .star: return "おほしさまが キラキラ にげてる！"
        case .apple: return "りんごが ころころ にげてる！"
        }
    }

    var completionMessage: String {
        switch self {
        case .germs: return "ばい菌たいじ せいこう！"
        default: return "みんな バイバイしたよ！"
        }
    }

    var symbolName: String {
        switch self {
        case .germs: return "sparkles"
        case .rabbit: return "hare.fill"
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .rice: return "fork.knife"
        case .bread: return "fork.knife"
        case .star: return "star.fill"
        case .apple: return "leaf.fill"
        }
    }

    var imageNames: [String] {
        switch self {
        case .germs: return ["germ_mint", "germ_purple", "germ_blue"]
        case .rabbit: return ["char_rabbit"]
        case .dog: return ["char_dog"]
        case .cat: return ["char_cat"]
        case .rice: return ["char_rice"]
        case .bread: return ["char_bread"]
        case .star: return ["char_star"]
        case .apple: return ["char_apple"]
        }
    }

    static var surpriseThemes: [CharacterTheme] {
        CharacterTheme.allCases.filter { $0 != .germs }
    }
}
