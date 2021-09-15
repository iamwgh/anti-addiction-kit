
import Foundation


/// 每分钟60秒
let kSecondsPerMinute: Int = 60
/// Timer 执行间隔
fileprivate let kTimerInterval: Int = 1

final class TimeService {
    
    /// 开始防沉迷时长统计服务
    class func start() {
        
        // 非大陆用户，不开启防沉迷系统
        if !RegionDetector.isMainlandUser {
            return
        }
        
        if AntiAddictionKit.configuration.useSdkOnlineTimeLimit == false {
            return
        }
        
        guard User.shared != nil else {
            return
        }
        
        if Router.isContainerPresented || Container.shared().isBeingPresented {
            return
        }
        
        let limitLevel = TimeLimitLevel.limitLevelForUser(User.shared!)
        
        //成年人
        if limitLevel == .unlimited  {
            return
        }
        
        //如果最后一次存储的日期 与 现在不是同一天，则清空在线时长
        if (DateHelper.isSameDay(User.shared!.timestamp, Date()) == false) {
            // 如果不是游客，才清空，游客同一设备时长固定，不刷新
            if User.shared!.type != .unknown {
                User.shared!.clearOnlineTime()
            }
        }
        
        Logger.info("单机版防沉迷时长统计开始")
        
        mainTimer.start()
    }
    
    /// 停止防沉迷时长统计服务
    class func stop() {
        UserService.saveCurrentUserInfo()
        
        mainTimer.suspend()
    }
    
    /// 主 Timer
    private static var mainTimer: SwiftTimer = SwiftTimer(interval: .seconds(Int(kTimerInterval)), repeats: true, queue: .global()) { (mTimer) in
        
        guard User.shared != nil else {
            Logger.debug("单机版当前无登录用户")
            mTimer.suspend()
            return
        }
        
        let limitLevel = TimeLimitLevel.limitLevelForUser(User.shared!)
        
        //成年人
        if limitLevel == .unlimited  {
            mTimer.suspend()
            return
        }
        
        User.shared!.onlineTimeIncrease(kTimerInterval)
        #if DEBUG // 给demo发送时间
        postOnlineTimeNotification()
        #endif
        
        //剩下是未成年人
        if limitLevel == .minor {
            let nowDate = Date()
            //            如果在未成年允许的时间段
            if DateHelper.minorCanPaly(nowDate) {
                AntiAddictionKit.configuration.showSwitchAccountButton = false
                let minorTotalTime  = DateHelper.intervalForMinorCanPlay(nowDate)
                
                if minorTotalTime == AntiAddictionKit.configuration.firstAlertTipRemainTime {
                    Router.openAlertTip(.lessThan15Minutes(.minor))
                    return
                }
                if minorTotalTime == AntiAddictionKit.configuration.countdownAlertTipRemainTime {
                    Router.openAlertTip(.lessThan60seconds(.minor, minorTotalTime))
                    return
                }
                            
             }else{
                //未成年无法进入
                AntiAddictionKit.sendCallback(result: .noRemainTime, message: "不在国家允许时间范围，无法进入游戏！")
                let content = AlertType.TimeLimitAlertContent.minorGameOver( canPlay: false);
                Router.openAlertController(AlertData(type: .timeLimitAlert, title: content.title, body: content.body, remainTime: 0))
                return
            }
            
            
        }
        
    }
    
}

enum TimeLimitLevel {
    case guest //游客限制
    case minor //未成年限制
    case unlimited //成年人无限制
    
    static func limitLevelForUser(_ user: User) -> TimeLimitLevel {
        switch user.type {
        case .unknown:
            return .guest
        case .child, .junior, .senior:
            return .minor
        case .adult:
            return .unlimited
        }
    }
}


/// Debug: - 给 DEMO 发送玩家当前游戏时间
internal func postOnlineTimeNotification() {
    #if DEBUG
    if let user = User.shared {
        NotificationCenter.default.post(name: NSNotification.Name("NSNotification.Name.totalOnlineTime"), object: nil, userInfo: ["userId": user.id, "totalOnlineTime": user.totalOnlineTime])
        return
    }
    
    if let account = AccountManager.currentAccount {
        NotificationCenter.default.post(name: NSNotification.Name("NSNotification.Name.totalOnlineTime"), object: nil, userInfo: ["userId": account.id, "totalOnlineTime": TimeManager.currentRemainTime])
        return
    }
    #endif
}
