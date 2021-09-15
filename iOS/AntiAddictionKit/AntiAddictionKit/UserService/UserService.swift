
import Foundation

final class UserService {
    
    /// 游戏主动登录用户
    /// - Parameter user: user 实例
    class func login(_ user: User) {
        sdkLogin(user)
    }
    
    /// 游戏主动退出用户
    class func logout() {
        sdkLogout()
    }
    
    /// 游戏主动更新用户
    class func updateUserType(_ type: UserType) {
        guard let _ = User.shared else { return }
        
        Router.closeAlertTip()
        Router.closeContainer()
        
        User.shared!.updateUserType(type)
        
        TimeService.start()
    }
    
    
    /// 获取用户类型
    /// - Parameter userId: 用户 id
    class func getUserType(_ userId: String) -> Int {
        guard let user = UserService.fetch(userId) else {
            return -1
        }
        
        return user.type.rawValue
    }
    
}

extension UserService {
    
    /// SDK 登出用户
    class func sdkLogout() {
        //停止计时器相关（同时会保存当前用户信息）
        TimeService.stop()
        
        //关掉所有页面
        Router.closeContainer()
        Router.closeAlertTip()
        
        // 清除当前用户信息
        User.shared = nil
        
        // 清除用户主动点击关闭浮窗后记录的浮窗显示逻辑
        AlertTip.userTappedToDismiss = false
    }
    
    private class func sdkLogin(_ user: User) {
        
        // 先清除所有弹窗，清除当前用户信息
        sdkLogout()
        
        // 尝试从硬盘中取出用户
        var isFirstLogin = false
        var theUser: User = user
        if var storedUser = UserService.fetch(theUser.id) {
            isFirstLogin = false
            storedUser.updateUserType(theUser.type)
            theUser = storedUser
        } else {
            isFirstLogin = true
        }
        
        // 更新当前用户
        User.shared = theUser
        
        // 非大陆用户，不开启防沉迷系统
        if !RegionDetector.isMainlandUser {
            Logger.info("非大陆地区不开启防沉迷")
            AntiAddictionKit.sendCallback(result: .loginSuccess, message: "非大陆地区不开启防沉迷-用户登录成功")
            return
        }
        
        // 如果在线时长控制未开启，则直接登录成功
        if !AntiAddictionKit.configuration.useSdkOnlineTimeLimit {
            AntiAddictionKit.sendCallback(result: .loginSuccess, message: "用户登录成功")
            return
        }
        
//        //如果最后一次存储的日期 与 现在不是同一天，则清空在线时长
//        if DateHelper.isSameDay(theUser.timestamp, Date()) == false {
//            // 如果不是游客，才清空，游客同一设备时长固定，不刷新
//            if theUser.type != .unknown {
//                theUser.clearOnlineTime()
//            }
//        }
        
        //如果最后一次存储的日期 与 现在不是同一月，则清空支付金额
        if DateHelper.isSameMonth(theUser.timestamp, Date()) == false {
            theUser.clearPaymentAmount()
        }
        
        //用户时长限制类型 游客 未成年人 成年人
        let limitLevel = TimeLimitLevel.limitLevelForUser(theUser)
        print("limitLevel---\(limitLevel)--\(theUser.type)")
        
        //成年人 直接登录成功
        if limitLevel == .unlimited  {
            AntiAddictionKit.sendCallback(result: .loginSuccess, message: "用户登录成功")
            return
        }
        
        //如果是游客，弹出实名认证页面
        if limitLevel == .guest {
            
            var content: AlertType.TimeLimitAlertContent
            content = AlertType.TimeLimitAlertContent.guestLogin
            Router.openAlertController(AlertData(type: .timeLimitAlert,
                                                 title: content.title,
                                                 body: content.body,
                                                 remainTime: 0))
            AntiAddictionKit.sendCallback(result: .loginLimitWithUnRealName, message: "用户登录失败，未实名")
            
            return
        }
        
        //未成年人
        if limitLevel == .minor {
            
            let nowDate = DateHelper.nowDate()
//            如果在未成年允许的时间段
            if DateHelper.minorCanPaly(nowDate) {
                AntiAddictionKit.configuration.showSwitchAccountButton = false
            
                let minorTotalTime: Int = Int(ceil(Double(DateHelper.intervalForMinorCanPlay(nowDate)) / 60.0))
            
                let content = AlertType.TimeLimitAlertContent.minorGameOver(minutes: minorTotalTime, canPlay: true);
                Router.openAlertController(AlertData(type: .timeLimitAlert, title: content.title, body: content.body, remainTime: minorTotalTime))
       
                AntiAddictionKit.sendCallback(result: .loginSuccess, message: "用户登录成功")
               // TimeService.start()
                return
                
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

extension UserService {
    
    class func fetch(_ uid: String) -> User? {
        let key = Key<User>(uid)
        return Defaults.shared.get(for: key)
    }
    
    class func store(_ user: User) {
        var aUser = user
        aUser.timestamp = Date()
        let key = Key<User>(aUser.id)
        Defaults.shared.set(aUser, for: key)
    }
    
    class func delete(_ user: User) {
        let key = Key<User>(user.id)
        Defaults.shared.clear(key)
    }
    
    class func delete(_ id: String) {
        let key = Key<User>(id)
        Defaults.shared.clear(key)
    }
    
}

extension UserService {
    class func saveCurrentUserInfo() {
        guard let user = User.shared else { return }
        self.store(user)
    }
}
