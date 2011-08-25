	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.StatusEvent;
	import flash.events.TimerEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.net.Responder;
	import flash.system.System;
	import flash.utils.Timer;
	import flash.utils.flash_proxy;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.containers.HDividedBox;
	import mx.controls.Alert;
	import mx.controls.Text;
	import mx.controls.ToolTip;
	import mx.core.Application;
	import mx.events.IndexChangedEvent;
	import mx.events.ListEvent;
	import mx.events.ResizeEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.rpc.xml.SimpleXMLDecoder;
	import mx.utils.ArrayUtil;
	
	import mynetconnection.MyNetConnection;
	
	import routines.*;
	
	
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
	
	private var streams:Object;
	private var videoframes:Object;
	
	private var myResponder:Responder = new Responder(displayreply);
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
	private var confTimer:Timer;
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
	[Embed(source="assets/publish.png")]
	[Bindable]
	public var imgPublish:Class;

	[Embed(source="assets/preview.png")]
	[Bindable]
	public var imgPreview:Class;

	[Embed(source="assets/unpublish.png")]
	[Bindable]
	public var imgUnpublish:Class;
	private var d:Date = new Date(0,0,0,0,0,0,0);

	public var groupServer:String;
	public var getServerResponder:Responder;
	public var scaleRatio:Number;
	public var conferenceStatus:String = "offline";
	private var appname:String;
	private var confDuration:Number;
	private var prvNames:ArrayCollection;
	public function startup():void {
		
		var i:int;
		myname = "4d4974c23c6cf97dab000000";
		username = "dplakhov,mbogdanov,dchenosov,silyin";
		serverip = "46.182.31.245";
		group_id = "4e4375eaada0255c2e000001";
		session_key = "f55307327a8b8e45147e31f3982e31fc";
		appname = "mm";
		//group = "";
		if (Application.application.parameters.myname != null){
			myname = Application.application.parameters.myname;
			appname = "mm";
		} 
		if (Application.application.parameters.username != null) username = Application.application.parameters.username;
		if (Application.application.parameters.ip != null) serverip = Application.application.parameters.ip;
		if (Application.application.parameters.group_id != null) group_id = Application.application.parameters.group_id;
		if (Application.application.parameters.session_key != null) session_key = Application.application.parameters.session_key;
		
		//groupServer = "rtmp://"+serverip+"/getserver/";
		groupServer = "rtmp://"+serverip+"/serverlist/";
		
		
		shadow = new DropShadowFilter();
		shadow.distance = 0;
		shadow.color = 0xDDDDDD;
		shadow.angle = 25;
		shadow.strength = 7;
		shadow.inner = true;
		cons.visible = false;
		cameras = new ArrayCollection(Camera.names);
		mics = new ArrayCollection(Microphone.names);
		camlist1.selectedIndex = 1;
		miclist1.selectedIndex = 1;
		errtext.text = "";
		myVid.filters = [shadow];
		
		//streamlist = new ArrayCollection();
		streamdisp.dataProvider = streamlist;
		vipStreamList = new ArrayCollection();
		vipStreams.dataProvider = vipStreamList;
		
		nc = new MyNetConnection();
		nc.addEventListener("netStatus", tmpOnNCStatus);
		//nc.connect(groupServer,group_id);
		nc.connect(groupServer);
		groupIdLabel.text = group_id;
		
		my_nc = new MyNetConnection();
		client = new Object();
		my_nc.client = client;
		client.nc_message = showMess;
		client.nc_broadcastRequest = broadcastRequest;
		client.nc_playMaster = playMaster;
		client.nc_recieveMembers = recieveMembers;
		client.nc_recieveHdMembers = recieveHdMembers;
		client.nc_checkAdmin = checkAdmin;
		client.nc_clientHdPublish = clientHdPublish;
		client.nc_stopPreview = stopPreview;
		client.nc_clientUnpublish = clientUnpublish;
		client.nc_closeMaster = closeMaster;
		client.nc_chatmessage = chatMessage;
		client.nc_clientConnected = clientConnected;
		client.nc_clientDisconnected = clientDisconnected;
		my_nc.addEventListener("netStatus", OnNCStatus);
		//my_nc.connect(red5server,"1q2w3e4r",group_id,session_key);

		previewScrs = new ArrayCollection();
		previewScrs.addItem(preview1);
		previewScrs.addItem(preview2);
		previewScrs.addItem(preview3);
		previewScrs.addItem(preview4);
		prvNames = new ArrayCollection();
		prvNames.addItem(prvName1);
		prvNames.addItem(prvName2);
		prvNames.addItem(prvName3);
		prvNames.addItem(prvName4);
		/*for (var i:int = 0; i<prvNames.length; i++)
		{
			prvNames.getItemAt(i).filters = [shadow];
		}*/
		
		timer = new Timer(10000);
		timer.addEventListener(TimerEvent.TIMER,onTick);
		confTimer = new Timer(1000);
		confTimer.addEventListener(TimerEvent.TIMER,confTimerTick);
		
				
	}

	private function clientConnected(id):void
	{
		var c:int = 0;
		var i:int = 0;
		var tmpObj:Object;
		for (i = 0; i< streamlist.length; i++)
		{
			if(streamlist.getItemAt(i).style == "bold") c++;
		}
		
		for (i = 0; i < streamlist.length; i++)
		{
			if (streamlist.getItemAt(i).id == id)
			{
				tmpObj = streamlist.getItemAt(i);
				streamlist.removeItemAt(i);
				tmpObj.fcolor = 0x00ff00;
				streamlist.addItemAt(tmpObj,c);
			}
		}

		streamdisp.invalidateList();
		streamdisp.invalidateDisplayList();
		streamdisp.invalidateProperties();
		streamdisp.invalidateSize();
				
	}

	private function clientDisconnected(id):void
	{
		var c:int = 0;
		var i:int = 0;
		var tmpObj:Object;

		for (i = 0; i< streamlist.length; i++)
		{
			if(streamlist.getItemAt(i).fcolor == 0x00ff00) c++;
		}
		for (i = 0; i < streamlist.length; i++)
		{
			if (streamlist.getItemAt(i).id == id)
			{
				tmpObj = streamlist.getItemAt(i);
				streamlist.removeItemAt(i);
				tmpObj.fcolor = 0x000000;
				streamlist.addItemAt(tmpObj,c);
			}
		}
		
		streamdisp.invalidateList();
		streamdisp.invalidateDisplayList();
		streamdisp.invalidateProperties();
		streamdisp.invalidateSize();
				
	}

	private function chatMessage(mess):void
	{
		chatBox.htmlText += mess+"\n";
		chatBox.validateNow();
		chatBox.verticalScrollPosition = chatBox.maxVerticalScrollPosition+10;
	}

	protected function chatSendButton_clickHandler(event:MouseEvent):void
	{
		if (chatSendText.text != "") my_nc.call("sendMessage",null,chatSendText.text);
		chatSendText.text = "";
		
	}
	protected function chatSendText_keyDownHandler(event:KeyboardEvent):void
	{
			switch (event.charCode)
			{
				case 13:
					if (chatSendText.text != "") my_nc.call("sendMessage",null,chatSendText.text);
					chatSendText.text = "";
					break;
			}
	}
	protected function streamdisp_itemDoubleClickHandler(event:ListEvent):void
	{
		
		ViewStreamClick();
	}

	protected function toggleConferenceButton_clickHandler(event:MouseEvent):void
	{
		switch (conferenceStatus)
		{
			case "offline":
				conferenceStatus = "online";
				my_nc.call("setConferenceStatus",null,conferenceStatus);
				my_nc.call("toggleRecording",null,true);
				toggleConferenceButton.label = "Закончить";
				toggleConferenceButton.invalidateProperties();
				confStatusInd.setStyle("backgroundColor","#00FF00");
				confDuration = 0;
				confTimer.start();
				
				break;
			
			
			case "online":
				conferenceStatus = "offline";
				my_nc.call("setConferenceStatus",null,conferenceStatus);
				my_nc.call("toggleRecording",null,false);
				toggleConferenceButton.label = "Начать";
				toggleConferenceButton.invalidateProperties();
				confStatusInd.setStyle("backgroundColor","#FF0000");
				confStatusText.text = "Конференция закончена"
				confDuration = 0;
				confTimer.stop();
				break;
			
		}
	}

	protected function vipStreams_itemClickHandler(event:ListEvent):void
	{
		if (event.columnIndex == 1)
		{
			//playMaster(vipStreams.selectedItem.id);
			my_nc.call("setMaster", null, vipStreams.selectedItem.id);
		}
		if (event.columnIndex == 2)
		{
			for (var i:int = 0; i<previewScrs.length; i++)
			{
				if (!previewScrs.getItemAt(i).playing)
				{
					previewScrs.getItemAt(i).frame.stream = vipStreams.selectedItem.id;
					previewScrs.getItemAt(i).frame.ns.play(vipStreams.selectedItem.id);
					
					previewScrs.getItemAt(i).playing = true;
					previewScrs.getItemAt(i).visible = true;
					if (vipStreams.selectedItem.name <=15) prvNames.getItemAt(i).text = "\n"+vipStreams.selectedItem.name;
					else prvNames.getItemAt(i).text = vipStreams.selectedItem.name;
					
					my_nc.call("playPreview",null,vipStreams.selectedItem.id,i);
					return;
				}
			}
			
		}
		
	}
	protected function vipStreams_itemDoubleClickHandler(event:ListEvent):void
	{
		// TODO Auto-generated method stub
		vipStreamList.removeItemAt(vipStreams.selectedIndex);
		
	}

	protected function streamdisp_itemClickHandler(event:ListEvent):void
	{
		var tmpObj:Object;
		if (event.columnIndex == 2)
		{
			vipStreamList.addItem(streamdisp.selectedItem);
			streamlist.removeItemAt(streamdisp.selectedIndex);
		}
	}
	private function clientHdPublish(stream,name):void
	{
		
		vipStreamList.addItem({id:stream,name:name});
	}
	public function groupIdLabel_clickHandler(event:MouseEvent):void
	{
		groupIdLabel.selectionBeginIndex = 0;
		groupIdLabel.selectionBeginIndex = groupIdLabel.text.length;
		Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT,group_id);
	}
	public function toggleRecording():void
	{
		if (recording.selected)
		{
			my_nc.call("toggleRecording",null,true);
		}
		else {
			my_nc.call("toggleRecording",null,false);
		}
	}
	public function mute():void
	{
		if (soundSwitch.selected) src_ns2.receiveAudio(true);
		else src_ns2.receiveAudio(false);
	}
	public function getServerResult(result:String):void
	{
		serverip = result;
		red5server = "rtmp://"+serverip+"/"+appname+"/"+group_id;
		my_nc.connect(red5server,myname,group_id,session_key);
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
				//Alert.show("Не могу получить список серверов.");
			}
	
			
	
	}
	
	public function myVidClick():void
	{
		if (myVid.width == 10){
			makeBig.play([myVid]);
			publishInd.visible = true;
			moveUp.play([myVid]);
		} 
		else{ 
			makeSmall.play([myVid]);
			publishInd.visible = false;
			moveDown.play([myVid]);
		}
		
		
		
	
	}

	
	public function clientUnpublish(streamname:String):void{
		
		var tmpobj:Object;
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).id == streamname){
				tmpobj = streamlist.getItemAt(ii);
				streamlist.removeItemAt(ii);
				tmpobj.style = "normal";
				tmpobj.pending = false;
				streamlist.addItemAt(tmpobj,ii);
				break;
			}
		}
		/*for (var ii: int = 0; ii < vipStreamList.length; ii++) {
			if (vipStreamList.getItemAt(ii).id == streamname){
				vipStreamList.removeItemAt(ii);
				break;
			}
		}*/
	
		
	
	}
	
	public function stopPreview(scrId):void
	{
		previewScrs.getItemAt(parseInt(scrId)).frame.ns.close();
		previewScrs.getItemAt(parseInt(scrId)).frame.vid.clear();
		previewScrs.getItemAt(parseInt(scrId)).frame.stream = "";
		previewScrs.getItemAt(parseInt(scrId)).playing = false;
		previewScrs.getItemAt(parseInt(scrId)).visible = false;
		prvNames.getItemAt(parseInt(scrId)).text = "";
	}

	public function checkAdmin(param:String):void{
		if (param != "OK"){
			Alert.show("У вас нет прав администратора в этой группе.");
			my_nc.close();
			 //getMembers();
		} else{ 
			getMembers();
			src_ns.publish(myname);
		}
	}
	
	private	function padValue(elem, padChar, finalLength, dir):String
	{
		//make sure the direction is in lowercase
		dir = dir.toLowerCase();
		//store the elem length
		var elemLen = elem.toString().length;
		//check the length for escape clause
		if(elemLen >= finalLength)
		{
			
			return elem;
		}
		//pad the value
		switch(dir)
		{
			
			default:
			case 'l':
				return padValue(padChar + elem, padChar, finalLength, dir);
				break;
			case 'r':
				return padValue(elem + padChar, padChar, finalLength, dir);
				break;
		}
	}

	private function confTimerTick(event:TimerEvent):void
	{
		d.setSeconds(confDuration);
		confDuration++;
		confStatusText.text = "Конференция идет: " +
			/*padValue(d.hours,"0",2,"l")+":" +
			padValue(d.minutes,"0",2,"l")+":" +
			padValue(d.seconds,"0",2,"l");*/
			padValue((Math.floor(confDuration/3600)).toString(),"0",2,"l")+":" +
			padValue((Math.floor(confDuration/60)).toString(),"0",2,"l")+":" +
			padValue((confDuration%60).toString(),"0",2,"l");

	
	}
	private function setConferenceStatus(status:String):void
	{
		
		toggleConferenceButton.enabled = true;
		conferenceStatus = status.split(";")[0];
		var duration:Number = parseInt(status.split(";")[1]);
		
		switch (conferenceStatus)
		{
			case "offline":
				toggleConferenceButton.label = "Начать";
				toggleConferenceButton.invalidateProperties();
				confStatusInd.setStyle("backgroundColor","#FF0000");
				confStatusText.text = "Конференция закончена";
				break;
			
			
			case "online":
				toggleConferenceButton.label = "Закончить";
				toggleConferenceButton.invalidateProperties();
				confStatusInd.setStyle("backgroundColor","#00FF00");
				confDuration = duration;
				confTimer.start();
				break;
			
		}
		
	}
	private function recieveLastMessages(messages:Array):void
	{
		if (messages.length > 0){
			for (var i:int =0; i< messages.length;i++)
			{
				chatBox.htmlText += messages[i]+"\n";
			}
		}
		chatBox.validateNow();
		
		chatBox.verticalScrollPosition = chatBox.maxVerticalScrollPosition;
	}
	public function recieveMembers(members:XMLDocument,connected:Array):void
	{
		var c:int = 0;
		var i:int = 0;
		var o:Object;
		for (i = 0; i < connected.length; i++)
		{
			if (connected[i] != null) c++;	
		}
		membersCount.text = "Участников: "+c;
		fillstreamlist(members,connected);
		/*for (i = 0; i<connected.length; i++)
		{
			if (connected[i] != null)
			{
				clientConnected(connected[i]);
			}
		
		}*/
		timer.start();
		my_nc.call("getConferenceStatus",new Responder(setConferenceStatus));
		
	}

	public function recieveHdMembers(members:Object):void
	{
		
		for (var i:int = 0; i < members.length; i++)
		{
			if (members[i] != null)
			{
				vipStreamList.addItem({id:members[i].streamName,name:members[i].hdName});
			}
		}
		
		
	}

	public function playMaster(stream:String,fullname:String):void
	{
		src_ns2.play(stream);
		mastername.text = fullname;
		if (stream == myname)
		{
			src_ns2.receiveAudio(false);
			soundSwitch.selected = false;
			soundSwitch.invalidateProperties();
		}
		else
		{
			src_ns2.receiveAudio(true);
			soundSwitch.selected = true;
			soundSwitch.invalidateProperties();

		}
		for (var i:int = 0; i < previewScrs.length; i++)
		{
			if (previewScrs.getItemAt(i).frame.stream == stream)
			{
				previewScrs.getItemAt(i).frame.ns.receiveAudio(false);
				previewScrs.getItemAt(i).sound.selected = false;
				previewScrs.getItemAt(i).sound.invalidateProperties();
				
			}
			else
			{
				if (previewScrs.getItemAt(i).frame.stream != myname)
				{
					previewScrs.getItemAt(i).frame.ns.receiveAudio(true);
					previewScrs.getItemAt(i).sound.selected = true;
					previewScrs.getItemAt(i).sound.invalidateProperties();
					
				}
			}
		}

	}
	
	public function showMess(mess:String):void
	{
		Alert.show(mess);
	}

	public function broadcastRequest(name:String):void
	{
		pushupitem(name);
	}



	public function addstream():void {
		trace("test");
	}
	
	public function ViewStreamClick():void {
	 	
	 	if (streamdisp.selectedItem.style == "bold"){
		 	for (var i:int = 0; i<previewScrs.length; i++)
		 	{
		 		
		 		if (!previewScrs.getItemAt(i).playing)
		 		{
		 			previewScrs.getItemAt(i).frame.stream = streamdisp.selectedItem.id;
		 			previewScrs.getItemAt(i).frame.ns.play(streamdisp.selectedItem.id);
					
		 			previewScrs.getItemAt(i).playing = true;
					previewScrs.getItemAt(i).visible = true;
					if (streamdisp.selectedItem.name.length <= 15) prvNames.getItemAt(i).text = "\n"+streamdisp.selectedItem.name;
					else prvNames.getItemAt(i).text = streamdisp.selectedItem.name;
		 			my_nc.call("playPreview",null,streamdisp.selectedItem.id,i);
		 			streamdisp.selectedItem.pending = false;
		 			streamdisp.invalidateList();
		 			streamdisp.invalidateDisplayList();
		 			streamdisp.invalidateProperties();
		 			streamdisp.invalidateSize();
		 			return;
		 		}	
		 	}
	 	}
	 	else{
	 		
	 		if (streamdisp.selectedItem.id == myname){
				for (var i:int = 0; i<previewScrs.length; i++)
						 	{
						 		if (!previewScrs.getItemAt(i).playing)
						 		{	 		
						 			if (Camera.names.length > 0){
							 			previewScrs.getItemAt(i).frame.stream = myname;
							 			previewScrs.getItemAt(i).frame.ns.play(myname);
							 			previewScrs.getItemAt(i).playing = true;
										previewScrs.getItemAt(i).visible = true;
										previewScrs.getItemAt(i).frame.ns.receiveAudio(false);
										previewScrs.getItemAt(i).sound.selected = false;
										previewScrs.getItemAt(i).invalidateProperties();
										if (streamdisp.selectedItem.name.length <= 15) prvNames.getItemAt(i).text = "\n"+streamdisp.selectedItem.name;
										else prvNames.getItemAt(i).text = streamdisp.selectedItem.name;

							 			my_nc.call("playPreview",null,myname,i);
						 			}
									return;
						 		}
						 	}
	 		
	 		
	 		}
	 	
	 	}
		
	
		
	}

	private function removeitem(streamname:String):void {
		var strnum:int;
		
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).Имя == streamname){ }
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
				//tmpobj.myEffect="0xFF0000";
				tmpobj.myEffect = glowFilter;
				tmpobj.pending = true;
				streamlist.addItemAt(tmpobj,0);
				break;
			
			}
		}
	}


	private function useractive(username:String,names:Array):Boolean {
		
		for (var ii: int = 0; ii < names.length; ii++) {
			if (names[ii] == username){ return true;}
		}
		return false;
	}
	
	private function sortByColor(a,b):int
	{
		if (a.fcolor < b.fcolor)
		{
			return 1;
		}
		else if (a.fcolor > b.fcolor)
		{
			return -1;
		}
		else return 0;
	}
		

	public function fillstreamlist(members:XMLDocument,connected:Array):void {
		var found:Boolean = false;
		var foundInVip:Boolean = false;
		var d:SimpleXMLDecoder;
		d = new SimpleXMLDecoder();
		var o:Object = d.decodeXML(members);
		var arr:Array = ArrayUtil.toArray(o.users.user);
		var i:int = 0;
		for (var p:int = 0; p<arr.length; p++)
		{
			if (connected.lastIndexOf(arr[p].id) != -1) arr[p].fcolor = 0x00ff00;
			else arr[p].fcolor = 0x000000;
			if (arr[p].avatar != null) arr[p].image = "http://xn--90acimpsblk.xn--p1ai/file/"+arr[p].avatar+"/avatar_micro.png";
			else arr[p].image = "http://xn--90acimpsblk.xn--p1ai/media/notfound/avatar_micro.png";
			arr[p].pending = false;
		}
		
		arr.sort(sortByColor);
		
			
		if (streamlist == null) {
			
			streamlist = new ArrayCollection(arr);
		}
		else
		{
			for (i = 0; i < arr.length; i++)
			{
				found = false;
				for (var j:int = 0; j < streamlist.length; j++)
				{
					if (streamlist.getItemAt(j).id == arr[i].id)
					{
						found = true;
					}
				}
				if (!found)
				{
					foundInVip = false;
					for (var k:int = 0; k < vipStreamList.length; k++)
					{
						if( vipStreamList.getItemAt(k).id == arr[i].id)
						{
							foundInVip = true;						
						}
						
					}
					if (!foundInVip) 
						streamlist.addItem(arr[i]);
						if (arr[i].fcolor == 0x00ff00) clientConnected(arr[i].id);
				}
			}
		}
	}
	

	public function checkonline(streams:Array) {
		var i:int;
		var j:int;
		for ( i = 0; i < streamlist.length; i++ ) {
			if (useractive(streamlist.getItemAt(i).Имя,streams)){
				streamlist.getItemAt(i).style = "bold";
				streamlist.getItemAt(i).active = true;
			} else {

				streamlist.getItemAt(i).style = "";
				streamlist.getItemAt(i).active = false;
				
			}
		}
		streamlist.refresh();
	}
	
	private function setqual():void {
			cam.setQuality(0,int("85"));
	}
	

	

	private function setmaster():void {
		
		//Alert.show(masterselect.selectedValue.toString());
		my_nc.call("setMaster", null, streamdisp.selectedItem.id);
	}
	
	 
	 
	private function getMembers():void
	{
		my_nc.call("listMembers",null,group_id);
			
	
	}
	public function onTick(event:TimerEvent):void
	{
		getMembers();
		/*var tmpobj:Object;
		
		for (var i = 0; i < streamlist.length; i++ ) {
			if (streamlist.getItemAt(i).pending){
				
				tmpobj = streamlist.getItemAt(i);
				streamlist.removeItemAt(i);
				tmpobj.myEffect = "#FF0000"; 
				streamlist.addItemAt(tmpobj,i);
				
			}
			else {
				tmpobj = streamlist.getItemAt(i);
				streamlist.removeItemAt(i);
				tmpobj.myEffect = "#000000"; 
				streamlist.addItemAt(tmpobj,i);
			
			}
			
		}*/
		
		//sendrequest();
		
		
	}
	public function toggleFullScreen():void
	{
		if (Application.application.stage["displayState"] == StageDisplayState.NORMAL ) Application.application.stage["displayState"] = StageDisplayState.FULL_SCREEN;
		else Application.application.stage["displayState"] = StageDisplayState.NORMAL;
		
	}
	public function scaleapp():void {

		Application.application.stage.addEventListener(Event.FULLSCREEN,resizeStage);
		Application.application.stage.scaleMode = StageScaleMode.SHOW_ALL;
		scaleRatio = Application.application.stage.width / Application.application.stage.height;
		
	}
	public function resizeStage(event:FullScreenEvent):void
	{
		if (event.fullScreen) fullScreenButton.label = "В окне";
		else fullScreenButton.label = "На весь экран";
		fullScreenButton.invalidateProperties();
	}
	private function changeCamMode():void
	{
		if (cam != null)
		{
			if (camRes320.selected) cam.setMode(320,240,20);
			else cam.setMode(640,480,20);
			cam.setQuality(0,camQuality.value);
		}
			
	}
	private function initcam():void{
					
					if (deviceGroup1.selected) cam = Camera.getCamera(camlist.selectedIndex.toString());
					else cam = Camera.getCamera(camlist1.selectedIndex.toString());
					if (camRes320.selected) cam.setMode(320,240,20,true);
					else cam.setMode(640,480,20,true);
					cam.setQuality(0,camQuality.value);
					myVid.attachCamera(cam);
					src_ns.attachCamera(cam);
					
					
	}
	private function initmic():void {
		
		if(deviceGroup1.selected)mic = Microphone.getMicrophone(miclist.selectedIndex);
		else mic = Microphone.getMicrophone(miclist1.selectedIndex);
		mic.codec = SoundCodec.SPEEX;
		mic.encodeQuality = 10;
		mic.setSilenceLevel(0);
		mic.setUseEchoSuppression(true);
		src_ns.attachAudio(mic);
	
	}
	
	public function closeMaster():void
	{
		src_ns2.close();
		mastername.text = "";
		vidd.clear();

	}
	public function closeMasterClick():void
	{
		my_nc.call("closeMaster", null, myname);
	}
	
	public function publishMe():void{
		
			
			my_nc.call("setMaster", null, myname);
		
		
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
			//so.addEventListener(SyncEvent.SYNC, syncHandler);
			my_nc.call("checkAdmin",null);
			my_nc.call("getLastMessages",new Responder(recieveLastMessages));
			
			if (Camera.names.length > 0)
			{
				
				src_ns = new NetStream(my_nc);
				initcam();
				if (Microphone.names.length > 0)initmic();
				
			//	src_ns.publish(myname);
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

		}
		else  {
			/*cons.visible = true;
			errtext.text += event.info.code+"\n";
			errtext.text += event.info.description+"\n";
			*/
		}
	
		
	} 
	
	public function ViewStream(streamname:String):void {
		src_ns2.play(streamname);
	}
	

	public function stopstream():void {
		my_nc.close();
	}

	public function displayreply(result:Object):void {
		cons.visible = true;
		errtext.text += String(result);
	}
	public function sendstring():void {
		///my_nc.call("clientsend",myResponder,sendstr.text);
		
	}

