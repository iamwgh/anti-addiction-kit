## 游戏防沉迷 AntiAddictionKit (Android) 对接文档

### 接入方式

针对 Android studio 项目，将 SDK 的 aar 库文件放入应用 module 的 libs 目录下，并在该 module 的 build.gradle 文件中进行配置，样例如下：

```
android{
	...
	repositories{
		flatDir{
			dirs 'libs'
		}
	}
}
dependencies{
	...
	implementation(name:'antiLib_v1.2.0',ext:'aar')
}
```
### 接入流程

（1）在应用的主 Activity 中进行功能配置（采用默认值可跳过）和初始化，在初始化接口传递的回调对象参数中处理对应回调。  
（2）如果游戏支持用户模块，在用户登录后调用登录接口，如果不支持用户模块，在用户正式进入游戏前，利用uuid或其他方式生成唯一标识符调用登录接口，传递给 SDK。  
（3）在游戏启动和停止的地方调用时长统计对应接口  
（4）在付费和聊天等场景下，调用 SDK 对应接口进行实名校验  
（5）用户在游戏内选择登出后，调用 SDK 登出接口同步信息

	
### SDK 接口 API
#### 1.配置参数（采用默认值可跳过）
##### (1) 功能性参数列表如下：

参数名称 | 参数类型 | 参数默认值 | 参数说明 
--- |--- |--- | ---
useSdkRealName | boolean | true | 是否使用 SDK 实名认证功能
useSdkPaymentLimit | boolean | true | 是否使用 SDK 付费限制
useSdkOnlineTimeLimit | boolean | true | 是否使用 SDK 在线时长限制
showSwitchAccountButton | boolean | true | 是否显示切换账号按钮

调用方式示例：

```
AntiAddictionKit.getFunctionConfig()
	 		.useSdkRealName(true)
     		.useSdkOnlineTimeLimit(true);
```
或直接传递三个对应参数（参数顺序：useRealName, usePaymentLimit, useOnlineTimeLimit)，用例如下：

```
AntiAddictionKit.resetFunctionConfig(true,true,true);

```

##### (2) 数据设置和外观参数
调用方式如下：

```
AntiAddictionKit.getCommonConfig()
			.gusterTime(3 *60)
			.dialogContentTextColor("#00ff00");

```
可设置的参数列表如下：

参数名称 | 参数类型 | 参数默认值 | 参数说明 
--- |--- |--- | ---
timeStrictStart | int | 20 * 60 * 60 | 未成年人游戏限制起始时间, 默认20点，单位 秒
timeStrictEnd | int | 21 * 60 * 60 |未成年人游戏限制结束时间，默认21点，单位 秒
dayOfWeekArray | int[] | {Calendar.FRIDAY, Calendar.SATURDAY, Calendar.SUNDAY} | 未成年一周可玩星期，默认周五周六周日, 整型数组， Calendar day_of_week 枚举
teenPayLimit | int | 50 * 10 * 10 | 未成年人（8-15岁）单次充值限额，默认50元，单位 分
teenMonthPayLimit | int | 300 * 10 * 10 | 未成年人（8-15岁）每月充值限额，默认200元，单位 分
youngPayLimit | int | 100 * 10 * 10 | 未成年人（16-17岁）单次充值限额，默认100元，单位 分
youngMonthPayLimit | int | 400 * 10 * 10 | 未成年人（16-17岁）每月充值限额，默认400元， 单位 分
dialogBackground | String | #ffffff | sdk弹窗背景颜色
dialogContentTextColor | String | #999999 | sdk弹框内容字体颜色
dialogTitleTextColor | String | #2b2b2b | 弹框标题字体颜色
dialogButtonBackground | String | #000000 |弹框按钮背景颜色
dialogButtonTextColor | String | #ffffff | 弹框按钮字体颜色
dialogEditTextColor | String | #000000 | 弹框输入框字体颜色
popBackground | String | #cc000000 | 倒计时浮窗背景颜色
popTextColor | String | #ffffff | 倒计时浮窗字体颜色
tipBackground | String | #ffffff | 提示浮窗背景颜色
tipTextColor | String | #000000 | 提示浮窗字体颜色
encodeString | String | test | 用户实名信息加密秘钥（AES）

#### 2.初始化
该接口应尽早调用，建议在应用的主 Activity 的 onCreate 方法中调用。示例如下：

```
 AntiAddictionKit.init(activity,protectCallBack);

```
其中ProtectCallBack 为回调监听实例，具体创建方法如下：

```
protectCallBack = new AntiAddictionKit.AntiAddictionCallback() {
            @Override
            public void onAntiAddictionResult(int resultCode, String msg) {
             switch (resultCode){
                    case AntiAddictionKit.CALLBACK_CODE_PAY_NO_LIMIT:
           			 ···
            }
 }

```
回调中会返回对应的回调类型和信息，sdk 中主要应用的如下：
<a name="callback"></a>

回调类型 | 类型值 |  触发条件 | 附带信息
--- | --- | --- | ---
CALLBACK\_CODE\_LOGIN\_SUCCESS | 500 | 登录通过，当游戏调用 login 后用户完成登录流程 | 无
CALLBACK\_CODE\_SWITCH_ACCOUNT | 1000 | 切换账号，当用户因防沉迷机制受限时，登录认证失败或选择切换账号时会触发 | 无
CALLBACK\_CODE\_USER\_TYPE\_CHANGED | 1500 | 用户类型变更，通过SDK完成实名会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_SUCCESS | 1010 | 实名成功，仅当游戏主动调用 openRealName 方法时，如果成功会触发 | 无
CALLBACK\_CODE\_REAL\_NAME\_FAIL | 1015 | 实名失败，仅用游戏主动调用 openRealName 方法时，如果用户取消会触发 | 无
CALLBACK\_CODE\_PAY\_NO\_LIMIT | 1020 | 付费不受限，sdk检查用户付费无限制时触发| 无
CALLBACK\_CODE\_PAY\_LIMIT | 1025 | 付费受限，付费受限触发,包括游客未实名或付费额达到限制等 | 触发原因
CALLBACK\_CODE\_TIME\_LIMIT | 1030 | 时间受限，未成年人或游客游戏时长已达限制，通知游戏 | 无
CALLBACK\_CODE\_OPEN\_REAL\_NAME | 1060 | 打开实名窗口，需要游戏通过其他方式完成用户实名时触发 | 触发原因提示，包括 "PAY\_LIMIT","CHAT_LIMIT"等
CALLBACK\_CODE\_CHAT\_NO\_LIMIT | 1080 | 聊天无限制，用户已通过实名，可进行聊天 | 无
CALLBACK\_CODE\_CHAT\_LIMIT | 1090 | 聊天限制，用户未通过实名，不可进行聊天 | 无
CALLBACK\_CODE\_AAT\_WINDOW\_SHOWN | 2000 | 额外弹窗显示，当用户操作触发额外窗口显示时通知游戏 | 无
CALLBACK\_CODE\_AAK\_WINDOW\_DISMISS | 2500 | 额外弹窗显示，额外窗口消失时通知游戏 


> 注意:  
> 关于 "USER\_TYPE\_CHANGED" 的回调，触发时机可能不唯一，当用户在付费或其他需要实名的时候，完成实名过程都会触发相应回调，所以不建议在这两个回调中做UI相关或任何阻塞线程的事情。另外初始化后默认成功，没有对应回调。  
> 当游戏 App 安装后**第一次启动初始化 SDK 时**，SDK 会判断当前用户地区是否为大陆地区。第二次及以后的初始化不会检测，直接以第一次的检测结果为准。只有大陆地区会有防沉迷机制。
> 
> 游戏 App 删除重装后的**第一次初始化**会重新检测当前用户地区。

#### 3.设置用户信息
<a name ="update_user"></a>

相关接口参数说明:

用户相关参数 | 类型 | 说明
--- | --- | ---
userId | `String` | 用户的唯一标识
userType | `Int` | 用户实名类型

userType 可选参数如下：

<a name="登录类型"></a>

参数 | 参数值 | 参数说明
--- | --- | ---
USER\_TYPE\_UNKNOWN | 0 | 依赖SDK获取实名信息或第三方获取的信息为未实名
USER\_TYPE\_CHILD | 1 | 未成年人（8岁以下）
USER\_TYPE\_TEEN | 2 | 未成年人（8-16岁）
USER\_TYPE\_YOUNG | 3 | 未成年人（16-17岁）
USER\_TYPE\_ADULT | 4 | 成年人

##### (1) 登录
登录接口应只在游戏登录过程中、登出后以及收到回调 [”SWITCH\_ACCOUNT"](#callback) 时调用。示例如下:

```
 AntiAddictionKit.login("userid1",0);
```
第一个参数为 userId , 第二个参数为 userType , 具体类型值参考 [上表](#登录类型) 。  
userId 类型为字符串，用于表示用户唯一标识，除 null 和 ”“ 等特殊字符串外无其他限制。  
userType 类型为 int，游戏如果不通过第三方实名，传递0即可，否则传递通过第三方获取的用户类型。
<a name="更新用户类型"></a>

##### (2) 更新用户类型
当游戏通过第三方实名后，需要将实名信息更新到 SDK 中，否则不需要调用该接口。具体示例如下：

```
AntiAddictionKit.updateUserType(1);

```	 
接口参数为 userType ,具体参考 [上表](#登录类型) 。

##### (3) 登出
当用户在游戏内点击登出或退出账号时调用该接口，调用示例如下：

```
AntiAddictionKit.logout();

```
#### 4.付费
游戏在收到用户的付费请求后，调用 SDK 的对应接口来判断当前用户的付费行为是否被限制，示例如下：

```
 AntiAddictionKit.checkPayLimit(100);

```
接口参数表示付费的金额，单位为分。当用户可以发起付费时，SDK 会调用回调 [PAY\_NO\_LIMIT](#callback) 通知游戏,否则调用 [PAY\_LIMIT](#callback);   
当用户完成付费行为时，游戏需要通知 SDK ，更新用户状态，示例如下：

```
 AntiAddictionKit.paySuccess(100);

```
参数为本次充值的金额，单位为分。

>注意：  
>如果用户在付费过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "updateUserType" [更新用户类型](#更新用户类型) , 还需再次调用 " checkPayLimit " 接口才能收到 [是否付费限制](#callback) 的回调。

#### 5.聊天
游戏在需要聊天时，调用 SDK 接口判断当前用户是否实名，示例如下：

```
 AntiAddictionKit.checkChatLimit();
```
当用户可以聊天时， SDK 会通过聊天回调 [CHAT\_NO\_LIMIT](#callback) 来通知游戏，否则就会去实名。如果此时需要打开第三方实名页，SDK 会调用 [OPEN\_REAL\_NAME](#callback) 回调，否则打开 SDK 的实名页面，如果实名失败就会调用[CHAT\_LIMIT](#callback) 回调，否则调用 [CHAT\_NO\_LIMIT](#callback)。
#####注意：如果用户在判断聊天限制过程中需要打开第三方页面进行实名，实名完成后，游戏除了要调用 "updateUserType" [更新用户信息](#更新用户类型) , 还需再次调用 " checkChatLimit " 接口才能收到 [是否聊天限制](#callback) 的回调。

#### 6.时长统计
为保证用户的时长统计准确，游戏需要在运行的主 Activity 的方法中调用如下接口，示例如下：

```
 	@Override
    protected void onResume() {
        super.onResume();
        AntiAddictionKit.onResume();
    }

    @Override
    protected void onStop() {
        super.onStop();
        AntiAddictionKit.onStop();
    }

```

#### 7.获取用户类型
SDK 初始化后，游戏可以获取 SDK 内保存的用户类型信息。如果游戏之前已设置过用户,会返回该用户的类型信息，否则会返回 -1 。 
调用示例如下：

```
AntiAddictionKit.getUserType("userId"); 
```
参数是用户的唯一标识字符串，正常返回值参考[登录类型](#登录类型)。

#### 8.打开实名窗口
> 注意：  
> 当游戏除了时长和付费限制时，有其他场景需要主动打开实名窗口。则可以通过该接口让用户进行实名，否则不需要调用该接口。如果用户已实名，则该接口直接触发实名成功回调。</font>  
当游戏在某些场景下需要主动打开实名窗口时，游戏可调用此接口打开实名窗口，示例如下：

```
AntiAddictionKit.openRealName();
```
调用后结果会通过[实名相关回调](#callback)返回。
```

## 联网版防沉迷
SDK只提供了本地判断，主要面向于单机游戏。若需要接入中宣部实名系统或对接自己的业务服务端，请移步： [联网版文档](https://github.com/taptap/anti-addiction-kit)
