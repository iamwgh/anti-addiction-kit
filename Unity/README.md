# 游戏防沉迷 AntiAddictionKit (Unity) 对接文档
AntiAddictionSDK 是为了遵循最新防沉迷政策而编写的一个集实名登记、防沉迷时长限制、付费限制三部分功能的组件，方便国内游戏团队快速接入游戏实现防沉迷功能从而符合政策规定。

# 说明
Unity 模块是通过引入 iOS 和 Android 模块后增加桥接文件打包出的 `.unitypackage`，方便以 Unity 开发的游戏直接引入。其他引擎/平台的游戏可以通过 iOS/Android 原生的方式接入，详见 iOS/Android 各模块接入文档。

## 1.接入SDK
Unity 开发环境:2018.4.17f

导入 `AntiAddictionForUnity.unitypackage`

### 1.1 iOS
- iOS Deployment Target 最低支持 iOS 8.0
- Xcode 11 编译 

>注意:  
>`unitypackge`中默认 iOS 平台 `AntiAddictionKit.framework` 为真机设备架构，如需生成模拟器包进行测试，请下载仓库 Release 目录中提供的 `AntiAddictionKitiOS.zip` 并解压后在目录`/AntiAddictionKit.xcframework/ios-i386_x86_64-simulator/`中找到 i386 和 x86 架构的 `AntiAddictionKit.framework` 并替换。
>
> `.xcframework` 是 WWDC 2019 推出的 Framework 替代品，自带模拟器和真机架构，其使用方法与原`.framework` 基本相同
> `AntiAddictionKit.xcframework` 同时包含 `i386`, `x86_64`,`armv7`, `armv7s`, `arm64` 等多种真机和模拟器架构
>

**检查 Unity 输出的 Xcode 工程**

1. 请确保设置`UnityFramework中`  `Xcode` - `General` - `Frameworks, Libraries, and Embedded Content` 中的 `AntiAddictionKit.framework` 为 `Embed & Sign`。
2. 如果编译报错找不到头文件或者模块，请确保 `Xcode`-`Build Settings` - `Framework Search Paths` 中的路径以保证 Xcode 正常编译。
3. 确保 `Xcode` - `Build Phases` - `Embed Frameworks` 中存在 `AntiAddiction.framework` 且已勾上 `Code Sign On Copy`。
4. 确保 Xcode 工程的 `Build Settings` 的 `Always Embed Swift Standard Libraries` 为 `Yes`，即 `始终引入 Swift 标准库`，避免 App 启动时报错 `无法找到 Swift 标准库之类`。如果未设置，低于 iOS 13  版本的 iPhone 启动 App 时会因缺少 Swift 标准库而闪退。
5. 添加依赖库 `libc++.tbd`
6. 如果遇到动态库问题，可将 `AntiAddictionKit.framework` 拖入导出的工程中，并且确保`Frameworks, Libraries, and Embedded Content` 中的 `AntiAddictionKit.framework` 为 `Embed & Sign`。
7. 开始代码接入


> 请确保以上步骤正确执行。

### 1.2 Android
最低支持安卓版本 5.0。

## 2.接口文档
安卓和 iOS 分别有默认的防沉迷时长和外观默认值，如需修改，请查看对应平台文档或代码。

**以下使用需要SDK命名空间下**

```
namespace AntiAddiction.OpenSource
```

### 2.1 功能配置（采用默认值可跳过）
#### (1) 功能配置参数列表如下：

 功能配置参数 |类型|默认值|说明 
--- |--- |--- | ---
useSdkRealName | bool | true | 是否使用 SDK 实名登记功能
useSdkPaymentLimit | bool | true | 是否使用 SDK 付费限制
useSdkOnlineTimeLimit | bool | true | 是否使用 SDK 在线时长限制

调用方式示例：

```
/*
	配置SDK
	useSdkRealName：是否使用SDK内部实名				默认true
	useSdkPaymentLimit：是否开启支付限制	 			默认true
	useSdkOnlineTimeLimit：是否开启在线时长限制	   默认true 
 */
public static void fuctionConfig(bool useSdkRealName,bool useSdkPaymentLimit,bool useSdkOnlineTimeLimit)
```

**也可以使用配置类AntiAddictionConfig配置SDK,类中配置更齐全**


调用方式示例：

```
AntiAddictionConfig config = new AntiAddictionConfig.Builder ()
.UseSdkRealName (true)
.UseSdkPaymentLimit (true)
.UseSdkOnlineTimeLimit(true)
.ShowSwitchAccountButton (false)		// 是否显示切换账号按钮
.Build ();

AntiAddiction.OpenSource.AntiAddiction.fuctionConfig(config);
```


### 2.初始化

初始化SDK并设置回调，初始化方法接收Action作为回调
> 初始化方法尽量在 Unity 引擎生命周期启动 onStart 之后，如果在 onAwake 时调用，可能会出现 init 调用失效。初始化方法不能过于提前调用，否则影响某些特定设备的地区判定。
>
> 当游戏 App 安装后的**第一次启动初始化 SDK 时**，SDK 会根据会判断当前用户地区是否为大陆地区。第二次及以后的初始化不会检测，直接以第一次的检测结果为准。
> 
> 游戏 App 删除重装后的**第一次初始化**会重新检测当前用户地区。
> 
> iOS 单机游戏请尽量在用户**主动点击游戏开始**时进行登录（调用 login 方法），以保证判断用户类型以启动相应的防沉迷策略。

示例如下：

```
// 定义回调Action
public Action<int,string> onAntiAddictionResult;

public void onAntiAddictionHandler (int resultCode,string msg){
	Debug.Log("onAntiAddictionHandler" + resultCode);
}
// 设置回调
onAntiAddictionResult += onAntiAddictionHandler;
AntiAddiction.OpenSource.AntiAddiction.init(onAntiAddictionResult);
```

回调中会返回对应的回调类型码 resultCode 和相应信息 message：

回调类型 | 参数值 |  触发条件 | 附带信息
--- | --- | --- | ---
CALLBACK\_CODE\_ENTER\_SUCCESS | 500 | 登录通过，当用户登录过程中通过防沉迷限制时会触发 | 无
CALLBACK\_CODE\_SWITCH_ACCOUNT | 1000 | 切换账号，当用户因防沉迷机制受限时，选择切换账号时会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_SUCCESS | 1010 | 实名成功，通过SDK或第三方完成实名会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_FAIL | 1015 | 实名失败，实名取消或失败会触发 | 无
CALLBACK\_CODE\_PAY\_NO\_LIMIT | 1020 | 付费不受限，sdk检查用户付费无限制时触发| 无
CALLBACK\_CODE\_PAY\_LIMIT | 1025 | 付费受限，付费受限触发,包括游客未实名或付费额达到限制等 | 触发原因
CALLBACK\_CODE\_TIME\_LIMIT | 1030 | 时间受限，未成年人或游客游戏时长已达限制，通知游戏 | 无
CALLBACK\_CODE\_OPEN\_REAL\_NAME | 1060 | 打开实名窗口，需要游戏通过其他方式完成用户实名时触发 | 触发原因提示，包括 "PAY\_LIMIT","CHAT_LIMIT"等
CALLBACK\_CODE\_CHAT\_NO\_LIMIT | 1080 | 聊天无限制，用户已通过实名，可进行聊天 | 无
CALLBACK\_CODE\_CHAT\_LIMIT | 1090 | 聊天限制，用户未通过实名，不可进行聊天 | 无
CALLBACK\_CODE\_USER\_TYPE\_CHANGED | 1500 | 用户类型变更，通过SDK完成实名会触发 | 无
CALLBACK\_CODE\_AAT\_WINDOW\_SHOWN | 2000 | 额外弹窗显示，当用户操作触发额外窗口显示时通知游戏 | 无
CALLBACK\_CODE\_AAK\_WINDOW\_DISMISS | 2500 | 额外弹窗显示，额外窗口消失时通知游戏 

####注意：关于 "USER\_TYPE\_CHANGED" 的回调，触发时机可能不唯一，当用户在付费或其他需要实名的时候，完成实名过程都会触发相应回调，所以不建议在这两个回调中做UI相关或任何阻塞线程的事情。


### 3.设置用户信息

相关接口参数说明:

用户相关参数 | 类型 | 说明
--- | --- | ---
userId | `String` | 用户的唯一标识
userType | `Int` | 用户实名类型



<a name="用户类型"></a>

用户类型 | 参数值 | 说明
--- | --- | ---
USER\_TYPE\_UNKNOWN | 0 | 依赖SDK获取实名信息或第三方获取的信息为未实名
USER\_TYPE\_CHILD | 1 | 通过第三方获取，值为未成年人（8岁以下）
USER\_TYPE\_TEEN | 2 | 通过第三方获取，值为未成年人（8-16岁）
USER\_TYPE\_YOUNG | 3 | 通过第三方获取，值为未成年人（16-17岁）
USER\_TYPE\_ADULT | 4 | 通过第三方获取，值为成年人（18岁及以上）

#### 3.1登录

登录接口应只在游戏登录过程中、登出后以及收到回调 ”SWITCH_ACCOUNT" 时调用。

调用示例：

```
AntiAddiction.OpenSource.AntiAddiction.login("12345",4);
```
该接口中共有两个参数，第一个是用户的唯一标识，类型为字符串，第二个代表当前用户的类型.参考上表

#### 3.2更新用户信息
当游戏通过第三方实名后，需要将实名信息更新到 SDK 中，接口参数为 userType ,具体参考 上表 。

具体示例如下：

```
AntiAddiction.OpenSource.AntiAddiction.udpateUserType(4);
```

#### 3.3登出
当用户在游戏内点击登出或退出账号时调用该接口。

调用示例如下：

```
AntiAddiction.OpenSource.AntiAddiction.logout();
```


### 4.付费
游戏在收到用户的付费请求后，调用 SDK 的对应接口来判断当前用户的付费行为是否被限制，示例如下：

```
AntiAddiction.OpenSource.AntiAddiction.checkPayLimit(100);
```

接口参数表示付费的金额，单位为分（例如1元道具=100分）。当用户可以发起付费时，SDK 会调用回调 [PAY\_NO\_LIMIT](#回调类型) 通知游戏,否则调用 [PAY\_LIMIT](#回调类型);   
当用户完成付费行为时，游戏需要通知 SDK ，更新用户状态，示例如下：

```
AntiAddiction.OpenSource.AntiAddiction.paySuccess(100);
```
参数为本次充值的金额，单位为分。

##### 注意：如果用户在付费过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "setUser" [更新用户信息](#设置用户信息) , 还需再次调用 " checkPayLimit " 接口才能收到 [是否付费限制] (#回调类型) 的回调。

### 5.聊天
游戏在需要聊天时，调用 SDK 接口判断当前用户是否实名，示例如下：

```
 AntiAddiction.OpenSource.AntiAddiction.checkChatLimit();
```
当用户可以聊天时， SDK 会通过聊天回调 [CHAT\_NO\_LIMIT](#回调类型) 来通知游戏，否则就会去实名。如果此时需要打开第三方实名页，SDK 会调用 [OPEN\_REAL\_NAME](#回调类型) 回调，否则打开 SDK 的实名页面，如果实名失败就会调用[CHAT\_LIMIT](#回调类型) 回调，否则调用 [CHAT\_NO\_LIMIT](#回调类型)。

##### 注意：如果用户在判断聊天限制过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "setUser" [更新用户信息](#update_user) , 还需再次调用 " checkChatLimit " 接口才能收到 [是否聊天限制](#回调类型) 的回调。

### 6.时长统计
如果步骤一配置的 useSdkOnlineTimeLimit = true，则 sdk 会根据当前政策主动限制游戏时长，反之不会限制用户游戏时长。

安卓平台需要注意，在unity的OnApplicationPause调用onResume和onStop方法

示例如下：

```
void OnApplicationPause(bool pauseStatus){
	if (pauseStatus)
	{
		AntiAddiction.OpenSourceAntiAddiction.onStop();

	}else
	{
		AntiAddiction.OpenSource.AntiAddiction.onResume();

	}
}
```


### 7.获取用户类型
SDK 初始化后，游戏可以获取 SDK 内保存的用户类型信息。如果游戏之前已设置过用户，会返回该用户的正常类型信息（0，1，2，3，4），否则返回 -1。调用示例如下：

```
int userType = AntiAddiction.OpenSource.AntiAddiction.getUserType("12345");

```
参数是用户的唯一标识字符串，返回值参考[用户类型](#用户类型)。

###8.打开实名窗口
设置用户信息后，游戏可调用此接口打开实名窗口，示例如下：

```
AntiAddiction.OpenSource.AntiAddiction.openRealName();
```
调用后结果会通过[实名相关回调](#callback)返回。

## 联网版防沉迷
SDK只提供了本地判断，主要面向于单机游戏。若需要接入中宣部实名系统或对接自己的业务服务端，请移步： [联网版文档](https://github.com/taptap/anti-addiction-kit)


