# 游戏防沉迷 AntiAddictionKit

## 说明
AntiAddictionKit 是为了遵循最新防沉迷政策而编写的一个集实名登记、防沉迷时长限制、付费限制三部分功能的组件，方便国内游戏团队快速接入游戏实现防沉迷功能从而符合政策规定。

### <p style='color:red'>SDK注意事项：</p>

-
SDK只提供了本地判断，主要面向于单机游戏。若需要接入中宣部实名系统或对接自己的业务服务端，请移步： [联网版文档](https://github.com/taptap/anti-addiction-kit)
- SDK的登录为伪登录，需要游戏自己实现登录或者接入第三方登录，游戏登录时调用login会根据玩家信息触发实名弹窗判断



## SDK业务流程图

![流程图](./flow.jpg)

## 下载

[Release](https://github.com/xindong/anti-addiction-kit/releases/latest)

支持通过 Android 原生、iOS 原生、Unity 三种方式使用。

## 文档


[iOS](/iOS/README.md)

[Android](/Android/README.md)

[Unity](/Unity/README.md)

## License

[MIT](https://github.com/xindong/anti-addiction-kit//blob/master/LICENSE)
