
import Foundation

let kPaymentLimitAlertTitle: String = "健康消费提示"

/// 弹窗类型
public enum AlertType {
    /// 无限制
//    case unlimited
    /// 游戏时长限制
    case timeLimitAlert
    /// 支付限制
    case payLimitAlert
}

extension AlertType {
    enum TimeLimitAlertContent {
        case guestLogin
        case guestGameOver(minutes: Int)
        case minorGameOver(minutes: Int = 0, canPlay: Bool)
        
        var title: String {
            return "健康游戏提示"
        }
        
        var body: String {
            let dayStr = AntiAddictionKit.configuration.minorPlayDay.joined(separator: "、")
         
            switch self {
            case .guestLogin:
                    return "您的账号未完成实名认证，为了符合国家相关规定，不影响您的游戏体验，请尽快完善实名信息。"
                
            case .guestGameOver(let minutes):
                let maxMinutes = max(1, minutes)
                return "您的游戏体验时长已达 \(maxMinutes) 分钟。登记实名信息后可深度体验。"
            case .minorGameOver(let minutes, let canplay):
                let maxMinutes = max(1, minutes)
                if canplay {
                    return "您当前为未成年账号，已被纳入防沉迷系统。根据国家相关规定，\(dayStr)及法定节假日 \(DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayStart).hour) 点 - \(DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayEnd).hour)  点之外为健康保护时段。您今日游戏时间还剩余 \(maxMinutes)分钟，请注意适当休息。 "
                } else {
                    return "您当前为未成年账号，已被纳入防沉迷系统。根据国家相关规定，\(dayStr)及法定节假日 \(DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayStart).hour) 点 -  \(DateHelper.timeSetFromMinorPlayTimeString(AntiAddictionKit.configuration.minorPlayEnd).hour) 点之外为健康保护时段。当前时间段无法游玩，请合理安排时间"
                }
            }
        }
        
    }
}

public struct AlertData {
    var type: AlertType
    var title: String
    var body: String
    var remainTime: Int
    
    init() {
        type = .timeLimitAlert
        title = ""
        body = ""
        remainTime = .max
    }
    
    init(type: AlertType, title: String, body: String, remainTime: Int = .max) {
        self.init()
        self.type = type
        self.title = title
        self.body = body
        self.remainTime = remainTime
    }
}
