	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.utils.Timer;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.TabBar;
	import mx.core.Application;
	import mx.events.ResizeEvent;
	import mx.managers.ToolTipManager;
	import mx.messaging.messages.HTTPRequestMessage;
	import mx.rpc.http.HTTPService;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ArrayUtil;
	import mx.utils.URLUtil;
	
	import mynetconnection.MyNetConnection;
	
	import routines.*;
	
	public var publishing:Boolean = false;
	public var cam:Camera;
	public var mic:Microphone;
	[Bindable]
	public var my_nc:MyNetConnection;
	public var nc:MyNetConnection;
//	public var my_nc:NetConnection;
//	public var my_nc2:NetConnection;
	
	public var src_ns:NetStream;
	public var src_ns2:NetStream;
	public var src_ns3:NetStream;
	public var req:HTTPService;
	public var masterStream:String;
	private var streams:Object;
	private var videoframes:Object;
	
	
	public var myname:String;
	public var username:String;
	public var serverip:String;
	public var group_id:String;
	public var red5server:String;
	public var shadow:DropShadowFilter; 
	private var so:SharedObject;
	[Bindable]
	private var streamlist:ArrayCollection;

	[Bindable]
	private var vipStreamList:ArrayCollection;
	private var timer:Timer;
	
	private var connected:Boolean = false;
	[Bindable]
	public var fullstrname:String;
	public var strname:String;
	public var grid:FrameGrid;
	public var frames:Array;
	[Bindable]
	private var cameras:ArrayCollection;
	[Bindable]
	private var mics:ArrayCollection;
	public var newframes:ArrayCollection;
	public var client:Object;
	public var previewScrs:ArrayCollection;
	public var session_key:String;
	public var vidd:Video;
	public var callerId:String;
	public var callId:String;
	public var myFullName:String;
	public var roster:Array;
	public var httpServer:String;
	public var confAccepted:Boolean = false;
	[Embed(source="assets/publish.png")]
	[Bindable]
	public var imgPublish:Class;

	[Embed(source="assets/unpublish.png")]
	[Bindable]
	public var imgUnpublish:Class;
	public var mainserver:String;
	public var groupServer:String;
	public var getServerResponder:Responder;
	public var confMembers:ArrayCollection;
	public function startup():void {
		callId = "";
		var i:int;
		
		
		//callId = "4d0208c15a481a496a000082";
		//myname = "4d0208c25a481a496a000138"; //дм. новиков 24@ya.ru
		myname = "4d0208c25a481a496a00016c"; //Андрей Фёдоров 28@ya.ru
		
		//myname = "4d0208c15a481a496a000082"; //Полина Смирнова
		//callId = "4d0208c05a481a496a00000d";
		//serverip = "188.93.21.227";
		//serverip = "188.93.20.18";
		serverip = "109.234.158.4";
		
		group_id = "4d13741cdf8ebf34c4000000";
		session_key = "7569927eec7c8393a45c421bc824bebd";
		
		httpServer = URLUtil.getServerName(this.url);
		//var t:String = "http://as1.modnoemesto.ru/srv/user/94328rseourfh43rhyiu/friends/all.xml";
		
		if (Application.application.parameters.myname != null) myname = Application.application.parameters.myname;
		if (Application.application.parameters.username != null) username = Application.application.parameters.username;
		if (Application.application.parameters.ip != null) serverip = Application.application.parameters.ip;
		if (Application.application.parameters.group_id != null) group_id = Application.application.parameters.group_id;
		if (Application.application.parameters.session_key != null) session_key = Application.application.parameters.session_key;
		if (Application.application.parameters.callid != null) callId = Application.application.parameters.callid;
		
		
		shadow = new DropShadowFilter();
		shadow.distance = 0;
		shadow.color = 0xDDDDDD;
		shadow.angle = 25;
		shadow.strength = 7;
		shadow.inner = true;
		cons.visible = false;
		cameras = new ArrayCollection(Camera.names);
		mics = new ArrayCollection(Microphone.names);
		errtext.text = "";
		myVid.filters = [shadow];
		streamlist = new ArrayCollection();
		streamdisp.dataProvider = streamlist;
		
		mainserver = "rtmp://"+serverip+"/serverlist/";
		//mainserver = "http://"+serverip+"/serverlist/";
		nc = new MyNetConnection();
		nc.addEventListener("netStatus", tmpOnNCStatus);
		
		nc.connect(mainserver);
		
		red5server = "rtmp://"+serverip+"/mmuserconf/";
		my_nc = new MyNetConnection();
		client = new Object();
		my_nc.client = client;
		client.nc_message = showMess;
		client.nc_recieveFriends = recieveFriends;
		client.nc_friendPublishing = friendPublishing;
		client.nc_friendOnline = friendOnline;
		client.nc_friendOffline = friendOffline;
		client.nc_friendViewing = friendViewing;
		client.nc_clientUnpublish = clientUnpublish;
		client.nc_friendClose = friendClose;
		client.nc_incomingCall = incomingCall;
		my_nc.addEventListener("netStatus", OnNCStatus);
		//my_nc.connect(red5server,myname,httpServer,session_key);
		
		previewScrs = new ArrayCollection();
		previewScrs.addItem(preview1);
		previewScrs.addItem(preview2);
		previewScrs.addItem(preview3);
		previewScrs.addItem(preview4);
		previewScrs.addItem(preview5);
		timer = new Timer(500);
		incomingCallPanel.visible = false;
		membersList.visible = false;
		mainvid.addEventListener(ResizeEvent.RESIZE,mainvidResize);
		
		
		this.invalidateProperties();
		this.invalidateDisplayList();
		
		
		
	}

	private function mute():void{
		
		
		if (soundSwitch.selected) src_ns2.receiveAudio(true);
		else src_ns2.receiveAudio(false);
	}
	private function disableVideo():void
	{
		if (vidSwitch.selected) src_ns2.receiveVideo(true);
		else src_ns2.receiveVideo(false);
	}
	
	private function showElems(show:Boolean):void{
		//if (!frame.active) return;
		
		if (show){
			soundSwitch.visible = true;
			vidSwitch.visible = true;
		}
		else {
			soundSwitch.visible = false;
			vidSwitch.visible = false;
		}
	}


	public function getServerResult(result:String):void
	{
		serverip = result;
		red5server = "rtmp://"+serverip+"/mmuserconf/";
		//red5server = "http://"+serverip+"/mmuserconf/";
		my_nc.connect(red5server,myname,httpServer,session_key);
	}
	
	public function getServerStatus(status:StatusEvent):void
	{
		Alert.show("Не могу получить список серверов.");
	}
	
	public function tmpOnNCStatus(event:NetStatusEvent):void{
		
		if(event.info.code == "NetConnection.Connect.Success") {
			getServerResponder = new Responder(getServerResult,getServerStatus);				
			nc.call("getServer",getServerResponder);
		}
		else
		{
			Alert.show("Не могу получить список серверов.");
		}
		
		
		
	}


	public function mainvidResize(event:ResizeEvent):void
	{
			//vidd.height = (event.target.width / 1.33333);
			
	}

	public function scaleapp():void {
		//Alert.show("scaleapp");
		Application.application.stage.addEventListener(Event.RESIZE,resizeStage);
		//Application.application.stage.scaleMode = "noScale";
		Application.application.stage.scaleMode = StageScaleMode.NO_BORDER ;
		Application.application.stage.align = "TL";
		
		
		/*Application.application.width = Application.application.stage.width;
		main.width = Application.application.stage.width;
		mainvid.width = Application.application.stage.width;
		//vidd.width = Application.application.stage.width;
		
		Application.application.height = Application.application.stage.height;
		main.height = Application.application.stage.height;
		mainvid.height = Application.application.stage.height-37;
		//vidd.height = Application.application.stage.height-37;*/
		
	}
	private function resizeStage(event:Event):void
	{
				
	
	}
	private function resizeStage1(event:Event):void{
		if (event.target.stageHeight < 500) return;
		if (event.target.stageWidth < 800) return;
		Application.application.width = event.target.stageWidth;
		/*main.width = event.target.stageWidth;
		mainvid.width = event.target.stageWidth;
		vidd.width = event.target.stageWidth;
		*/
		//mainvid.height = event.target.stageHeight-143;
		//mainvid.width = event.target.stageWidth - 201;

		closeMasterInd.x = mainvid.x + mainvid.width - 12; 
		for (var i:int = 0; i < previewScrs.length; i++)
		{
			previewScrs.getItemAt(i).y = event.target.stageHeight - 125;
			
			//previewScrs.getItemAt(i).width = ((mainvid.width / 100)*18.86477462437396);
			if (i > 0) previewScrs.getItemAt(i).x = previewScrs.getItemAt(i-1).x + (previewScrs.getItemAt(i-1).width + 8);
			previewScrs.getItemAt(i).invalidateProperties();
			previewScrs.getItemAt(i).invalidateSize();
			previewScrs.getItemAt(i).invalidateDisplayList();
			
		}
		
		/*previewScrs.getItemAt(2).x
		previewScrs.getItemAt(3).x
		previewScrs.getItemAt(4).x
		previewScrs.getItemAt(5).x*/
				
		settButton.y = event.target.stageHeight-32;
		callButton.y = event.target.stageHeight-32;
		callButton.x = event.target.stageWidth - 183;
		myVid.y = event.target.stageHeight-246;
		/*mainvid.width = mainvid.height * 1.333333;
		if ((mainvid.width / 1.3333333) < (event.target.stageHeight-153))
		{
			mainvid.height = mainvid.width / 1.3333333;
		}*/
		streamdisp.height = event.target.stageHeight - 50;
		streamdisp.x = event.target.stageWidth - 183;
		Application.application.height = event.target.stageHeight;
	
		if ((event.target.stageHeight-153)>(event.target.stageWidth-201))
		{
			mainvid.width = (event.target.stageHeight-153) * 1.3333333;
			mainvid.height = event.target.stageHeight-153;
		}
		else
		{
			mainvid.height = (event.target.stageWidth-201) / 1.3333333;
			mainvid.width = event.target.stageWidth-201;
		}
		
		/*main.height = event.target.stageHeight;
		
		vidd.height = event.target.stageHeight-37;*/
		
		
	}


	public function publishingFriends(result:Array):void
	{
		for (var iii:int = 0; iii < previewScrs.length; iii++)
		{
			if (previewScrs.getItemAt(i).frame.stream == result[iii]) delete result[iii];
		}
		
		if (confAccepted){
			
			if (result.length > 0){
				for (var ii:int = 0; ii<result.length; ii++)
				{
					if ((result[ii] != myname) && (result[ii] != null)){
						if (result[ii] == callerId)
						{
							src_ns2.play(callerId);
						}
						for (var i:int = 0; i < previewScrs.length; i++)
						{
							if (!previewScrs.getItemAt(i).playing)
							{
								//Alert.show("Playing "+result[ii]+" in "+i.toString()+" frame.");
								previewScrs.getItemAt(i).frame.stream = result[ii];
								previewScrs.getItemAt(i).frame.ns.play(result[ii]);
								previewScrs.getItemAt(i).playing = true;
								if (previewScrs.getItemAt(i).frame.stream  == callerId)
								{
									previewScrs.getItemAt(i).frame.ns.receiveAudio(false);
								}
								break;
							}
						}
					}
				}
			}
		}
	}


	public function getPublishingFriends():void
	{
		my_nc.call("getPublishingFriends",new Responder(publishingFriends));
	
	}
	
public function hangUp():void
	{
		
		callButton.label = "Вызов";
		callerId = "";
		src_ns2.close();
		vidd.clear();
		src_ns.close();
		
		for (var n:int = 0; n < previewScrs.length; n++)
		{
			previewScrs.getItemAt(n).frame.ns.close();
			previewScrs.getItemAt(n).frame.vid.clear();
			previewScrs.getItemAt(n).frame.stream = "";
			previewScrs.getItemAt(n).playing = false;
		}
		for (var n:int = 0; n < streamlist.length; n++)
		{
			streamlist.getItemAt(n).selected = false;
			streamdisp.invalidateList();
		}
			
	}

	public function callReply():void
	{
		
		var members:Array = new Array;
		confAccepted = !confAccepted;
		if (confAccepted){
			incomingCallPanel.visible = false;
			publishStream();
			getPublishingFriends();
			callButton.label = "Завершить";
		}
		else
		{
			hangUp();
		}
	}
	
	public function clientReply(id:String):void
	{
		
		
	}
	
	public function callReject():void
	{
		incomingCallPanel.visible = false;
		
	}
	
	public function incomingCall(_callerId:String,members:Array):void
	{
		incomingCallPanel.visible = true;
		
		callerName.text = "Вас вызывает \n"+roster[_callerId];
		callerId = _callerId;
		if (members.length > 1)
		{
			for(var ii = 0; ii < members.length; ii++)
			{
				if (members[ii].id == _callerId) delete members[ii];
				members[ii].name = roster[members[ii].id];
				
			}
			
			membersLabel.text = "Другие участники конференции:";
			confMembers = new ArrayCollection(members);
			
			for (var p:int = 0; p < confMembers.length; p++)
			{
			
				if (confMembers.getItemAt(p).id == myname)
					confMembers.removeItemAt(p);
					
			}
			
			membersList.dataProvider = confMembers;
			membersList.visible = true;
		}
		else
		{
			membersLabel.text = "";
			membersList.visible = false;
		}
	}
	public function MakeCall():void{
		
		confAccepted = !confAccepted;
		if (!confAccepted)
		{
			hangUp();
			
		}
		else
		{
			callButton.label = "Завершить";
			var callIds:Array = new Array();
			var counter:int = 0;
			var tmpObj:Object;
			for(var i = 0; i < streamlist.length; i++)
			{
				if (streamlist.getItemAt(i).selected)
				{
					counter++;
					if (counter > 5){
						Alert.show("Выберите не более 5 человек");
						return;
					}
					else 
					{
						
						//callIds.push({id:streamlist.getItemAt(i).id,name:streamlist.getItemAt(i).name});
						callIds.push({id:streamlist.getItemAt(i).id});
					}
					confMembers = new ArrayCollection(callIds);
					
				}
				 
				
			}
			if (callIds.length > 0){
				publishStream();
				my_nc.call("makeCall",null,callIds);
			}
		}
	}
	
	public function friendOnline(id:String):void
	{
		var tmpObj:Object;
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).id == id)
			{
				streamlist.getItemAt(ii).status = "2Онлайн";
				tmpObj = streamlist.getItemAt(ii);
				streamlist.removeItemAt(ii);
				streamlist.addItemAt(tmpObj,0);
				
				streamdisp.invalidateList();
			}
		}
	
	}

	public function friendOffline(id:String):void
	{
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).id == id)
			{
				if (!streamlist.getItemAt(ii).online){
					streamlist.getItemAt(ii).status = "4Не в сети";
				}
				else streamlist.getItemAt(ii).status = "3На сайте";
				streamdisp.invalidateList();
			}
		}
	
	}
	
	
	
	
	public function friendClose(streamname):void
	{
		
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).id == streamname){
				streamlist.getItemAt(ii).pending = false;
				if (!streamlist.getItemAt(ii).online)
					streamlist.getItemAt(ii).status = "4Не в сети";
				else streamlist.getItemAt(ii).status = "3На сайте";
				streamdisp.invalidateList();
				break;
			}
		}

	
	
	}
	public function clientUnpublish(streamname:String):void{
		
		/*var tmpobj:Object;
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).id == streamname){
				tmpobj = streamlist.getItemAt(ii);
				streamlist.removeItemAt(ii);
				tmpobj.style = "normal";
				//tmpobj.pending = false;
				streamlist.addItemAt(tmpobj,ii);
				break;
			}
		}*/
		for(var i = 0; i < streamlist.length; i++)
		{
			if (streamlist.getItemAt(i).id == streamname){
				streamlist.getItemAt(i).status = "2Онлайн";
				streamdisp.invalidateList();
			}
		}
		for (var n = 0; n < previewScrs.length; n++)
		{
			if (previewScrs.getItemAt(n).frame.stream == streamname)
			{
			
				previewScrs.getItemAt(n).frame.ns.close();
				previewScrs.getItemAt(n).frame.vid.clear();
				previewScrs.getItemAt(n).frame.stream = "";
				previewScrs.getItemAt(n).playing = false;

			}
		}
		if (streamname == masterStream)
		{
			src_ns2.close();
			vidd.clear();
			masterStream = "";
		}

		
	}
	
	public function friendViewing(id:String):void{
		var tmpobj:Object;
		for (var i: int = 0; i < streamlist.length; i++) {
			if (streamlist.getItemAt(i).id == id)
			{
				tmpobj = streamlist.getItemAt(i);
				streamlist.removeItemAt(i);
				tmpobj.pending = true;
				streamlist.addItemAt(tmpobj,i);
			}
		}
	
	
	}
	
	public function friendPublishing(id:String):void
	{
		var tmpObj:Object;
		for(var i = 0; i < streamlist.length; i++)
		{
			if (streamlist.getItemAt(i).id == id){
				streamlist.getItemAt(i).status = "1Занят";
				tmpObj = streamlist.getItemAt(i);
				streamlist.removeItemAt(i);
				streamlist.addItemAt(tmpObj,0);
				streamdisp.invalidateList();
			}
		}
		if (confAccepted)
		{

			if (confMembers != null){
				for(i = 0; i < confMembers.length; i++)
				{
					if (confMembers.getItemAt(i).id == id)
					{
						for (var ii:int = 0; ii<previewScrs.length; ii++)
						{
	
							if (!previewScrs.getItemAt(ii).playing)
							{
								//Alert.show("Playing new member "+id+" in "+ii.toString()+" frame.");
								previewScrs.getItemAt(ii).frame.stream = id;
								previewScrs.getItemAt(ii).frame.ns.play(id);
								previewScrs.getItemAt(ii).playing = true;
								return;
							}
						
						}
					
					}
				}
			}
			
		}
	}
	public function recieveFriends(members:XMLDocument):void
	{
		fillstreamlist(members);
	}
	
	public function showMess(mess:String):void
	{
		Alert.show(mess);
	}


	
	
	public function ViewStreamClick():void {
	 	
	 	if (streamdisp.selectedItem.style == "bold"){
		 	for (var i:int = 0; i<previewScrs.length; i++)
		 	{
		 		
		 		if (!previewScrs.getItemAt(i).playing)
		 		{
		 			
		 			for (var ii:int = 0; ii<previewScrs.length; ii++)
		 			{
			 			if (previewScrs.getItemAt(ii).frame.stream == streamdisp.selectedItem.id )
			 			{
			 				
			 				return;
			 			}
			 		} 
		 			
		 			previewScrs.getItemAt(i).frame.stream = streamdisp.selectedItem.id;
		 			previewScrs.getItemAt(i).frame.ns.play(streamdisp.selectedItem.id);
		 			my_nc.call("viewFriend",null,streamdisp.selectedItem.id);
		 			previewScrs.getItemAt(i).playing = true;

		 			streamdisp.invalidateList();
		 			streamdisp.invalidateDisplayList();
		 			streamdisp.invalidateProperties();
		 			streamdisp.invalidateSize();
		 			return;
		 		}	
		 	}
	 	}
	 	
		
	
		
	}


	private function pushupitem(streamname:String):void {
		var strnum:int;
		var tmpobj:Object;
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).id == streamname){ 
				tmpobj = streamlist.getItemAt(ii);
				streamlist.removeItemAt(ii);
				tmpobj.style="bold";
				
				streamlist.addItemAt(tmpobj,0);
				break;
			
			}
		}
	}

	
	public function fillstreamlist(members:XMLDocument):void {
		roster = new Array();
		var ids:Array = new Array();
		var d:SimpleXMLDecoder;
		d = new SimpleXMLDecoder();
		var o:Object = d.decodeXML(members);
		var arr:Array = ArrayUtil.toArray(o.users.user);
		streamlist = new ArrayCollection(arr);
		
		for (var i = 0; i < streamlist.length; i++ ) {
			roster[streamlist.getItemAt(i).id] = streamlist.getItemAt(i).name; 
			if (streamlist.getItemAt(i).online)
			{
				streamlist.getItemAt(i).status = "3На сайте";
			}
			else streamlist.getItemAt(i).status = "4Не в сети";
			
			streamlist.getItemAt(i).pending = false;
			
			streamlist.getItemAt(i).selected = false;
			ids[i] = streamlist.getItemAt(i).id;
			if (streamlist.getItemAt(i).id == myname) myFullName = streamlist.getItemAt(i).name;
		}
		mynameLabel.text = myFullName;
		
		my_nc.call("fillFriends",null,ids);

	}
	

	
	var membersLoaded:Responder; 
	private function getMembers():void
	{
		my_nc.call("listMembers",membersLoaded,group_id);
	}

	public function onTick(event:TimerEvent):void
	{
	}
	
	private function initcam():void
	{
					cam = Camera.getCamera(camlist.selectedIndex.toString());
					cam.setMode(320,240,20);
					cam.setQuality(0,int("75"));
					myVid.attachCamera(cam);
					src_ns.attachCamera(cam);
	}
	
	private function initmic():void {
		mic = Microphone.getMicrophone(miclist.selectedIndex);
		mic.setUseEchoSuppression(true);
		
		src_ns.attachAudio(mic);
	}
	
	public function closeMasterClick():void
	{
		src_ns2.close();
		vidd.clear();
		
		for (var i:int = 0; i < previewScrs.length;i++)
		{
			if (previewScrs.getItemAt(i).frame.stream == masterStream)
			{
				previewScrs.getItemAt(i).frame.ns.receiveAudio(true);
				previewScrs.getItemAt(i).sound.selected = true;
				previewScrs.getItemAt(i).sound.invalidateProperties();
			}
		}
		masterStream = "";
	}
	
	
	private function OnNCStatus(event:NetStatusEvent):void {
		
		var i:int;
		if(event.info.code == "NetConnection.Connect.Success") {
			for (var i:int = 0; i<previewScrs.length; i++)
		 	{
				previewScrs.getItemAt(i).frame.initnet(my_nc);
		 	}
			connected = true;
			so = SharedObject.getRemote("message", my_nc.uri, false);
	    	so.client = this;
	    	so.connect(my_nc);
			
			if (Camera.names.length > 0)
			{
				
				src_ns = new NetStream(my_nc);
				initcam();
				if (Microphone.names.length > 0)initmic();
				
				
			}
			else
			{
			//	cons.visible = true;
			//	errtext.text += "Веб-камера не обнаружена\n";
			}
			//fillstreamlist();

			src_ns2 = new NetStream(my_nc);
			
			vidd = new Video();
			vidd.attachNetStream(src_ns2);
			vidd.width = mainvid.width;
			vidd.height = mainvid.height;
			
			vidd.deblocking = 2;
			vidd.smoothing = true;
			mainvid.addChild(vidd);
			var tmpArr:Array = new Array;
			
			if (callId != ""){
				confAccepted = true;
				publishStream();
				tmpArr.push({id:callId});
				confMembers = new ArrayCollection(tmpArr);
				my_nc.call("makeCall",null,tmpArr);
				callButton.label = "Завершить";
			}

		}
		else  {
			/*cons.visible = true;
			errtext.text += event.info.code+"\n";
			errtext.text += event.info.description+"\n";
			*/
		}
	
		
	} 
	private function publishStream():void{
				
					if (!publishing){
						if (Camera.names.length > 0)
						{
							
							src_ns.publish(myname);
							
							publishing = true;

							
						}
						else Alert.show("Веб-камера не найдена");
					}
					else{
						
						src_ns.close();
						publishing = false;
						
					}
				
	}





