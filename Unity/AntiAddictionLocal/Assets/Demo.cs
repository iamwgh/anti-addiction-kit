
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using AntiAddiction.OpenSource;
using System;

public class Demo : MonoBehaviour {
	public Action<int,string> onAntiAddictionResult;

	private string callbackStatus = "";

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
		
	}

	void OnApplicationPause(bool pauseStatus){
		if (pauseStatus)
		{
			AntiAddiction.OpenSource.AntiAddiction.onStop();

		}else
		{
			AntiAddiction.OpenSource.AntiAddiction.onResume();

		}
	}

	void OnGUI() {
		GUIStyle myButtonStyle = new GUIStyle(GUI.skin.button)
		{
			fontSize = 50
		};

		GUIStyle myLabelStyle = new GUIStyle(GUI.skin.label)
		{
			fontSize = 40
		};


		GUI.depth = 0;

		GUI.Label(new Rect(50, 100, 500, 50), callbackStatus, myLabelStyle);

		if (GUI.Button(new Rect(50, 200, 380, 60), "初始化", myButtonStyle))
		{
			onAntiAddictionResult += onAntiAddictionHandler;
			AntiAddiction.OpenSource.AntiAddiction.init(onAntiAddictionResult);
		}

		if (GUI.Button(new Rect(50, 300, 380, 60), "登录", myButtonStyle))
		{
			AntiAddiction.OpenSource.AntiAddiction.login("1234567",0);
		}

		if (GUI.Button(new Rect(50, 380, 380, 60), "更新用户信息", myButtonStyle))
		{
			AntiAddiction.OpenSource.AntiAddiction.updateUserType(4);
		}

		if (GUI.Button(new Rect(50, 460, 380, 60), "登出", myButtonStyle))
		{
			AntiAddiction.OpenSource.AntiAddiction.logout();
		}

		if (GUI.Button(new Rect(50, 540, 380, 60), "检查付费限制", myButtonStyle))
		{
			AntiAddiction.OpenSource.AntiAddiction.checkPayLimit(200);
		}

		if (GUI.Button(new Rect(50, 610, 380, 60), "付费成功", myButtonStyle))
		{
			AntiAddiction.OpenSource.AntiAddiction.paySuccess(100);
		}

		if (GUI.Button(new Rect(50, 770, 380, 60), "检查聊天限制", myButtonStyle))
		{
			AntiAddiction.OpenSource.AntiAddiction.checkChatLimit();
		}

		if (GUI.Button(new Rect(50, 850, 380, 60), "配置SDK", myButtonStyle))
		{
			AntiAddictionConfig config = new AntiAddictionConfig.Builder ()
			.UseSdkRealName (true)
			.UseSdkPaymentLimit (true)
			.UseSdkOnlineTimeLimit(true)
			.ShowSwitchAccountButton (false)
			.Build ();

			AntiAddiction.OpenSource.AntiAddiction.fuctionConfig(config);
			// AntiAddiction.OpenSource.AntiAddiction.fuctionConfig(false,true,true);
		}

		if (GUI.Button(new Rect(50, 930, 380, 60), "获取用户类型", myButtonStyle))
		{
			int userType = AntiAddiction.OpenSource.AntiAddiction.getUserType("12345");
			Debug.Log("getUserType" + userType);
		}

		if (GUI.Button(new Rect(50, 1010, 380, 60), "打开实名", myButtonStyle))
		{
			AntiAddiction.OpenSource.AntiAddiction.openRealName();
		}
	}

	public void onAntiAddictionHandler (int resultCode,string msg){
		callbackStatus = "onAntiAddictionHandler" + resultCode;

		if (resultCode == (int)CallbackCode.CALLBACK_CODE_ENTER_SUCCESS){
			callbackStatus = "进入游戏成功";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_SWITCH_ACCOUNT){
			callbackStatus = "点击切换账号";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_REAL_NAME_SUCCESS){
			callbackStatus = "实名成功";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_REAL_NAME_FAIL) {
			callbackStatus = "实名失败";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_PAY_NO_LIMIT){
			callbackStatus = "付费不受限制";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_PAY_LIMIT){
			callbackStatus = "付费受限：" + msg;
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_TIME_LIMIT){
			callbackStatus = "游戏时长已达限制";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_OPEN_REAL_NAME){
			callbackStatus = "打开实名窗口";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_CHAT_NO_LIMIT){
			callbackStatus = "聊天无限制";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_USER_TYPE_CHANGED){
			callbackStatus = "用户类型变更";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_AAT_WINDOW_SHOWN){
			callbackStatus = "SDK窗口弹出";
		}else if (resultCode == (int)CallbackCode.CALLBACK_CODE_AAK_WINDOW_DISMISS){
			callbackStatus = "SDK窗口消失";
		}


		Debug.Log(callbackStatus);
	}
}


