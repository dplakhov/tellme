
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.controls.VideoDisplay;
	import mx.managers.DragManager;
	import mx.rpc.http.HTTPService;
	
	import mynetconnection.MyNetConnection;
	
	import routines.*;
	
	
	public var cam:Camera;
	public var mic:Microphone;
	[Bindable]
	public var my_nc:MyNetConnection;
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
	
	public var red5server:String;
	public var shadow:DropShadowFilter; 
	private var so:SharedObject;
	private var streamlist:ArrayCollection;
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
	
	public function startup():void {
		var i:int;
		myname = "agorodishenin";
		username = "dplakhov,mbogdanov,dchenosov,silyin";
		serverip = "192.168.0.211"; 
		
		if (Application.application.parameters.myname != null) myname = Application.application.parameters.myname;
		if (Application.application.parameters.username != null) username = Application.application.parameters.username;
		if (Application.application.parameters.ip != null) serverip = Application.application.parameters.ip;
		
		red5server = "rtmp://"+serverip+"/oflaDemo/";
		shadow = new DropShadowFilter();
		shadow.distance = 0;
		shadow.color = 0xDDDDDD;
		shadow.angle = 25;
		shadow.strength = 7;
		shadow.inner = true;
		cons.visible = false;
		//user.text = username;
		cameras = new ArrayCollection(Camera.names);
		mics = new ArrayCollection(Microphone.names);
		





		me.text = "Ваше имя: "+myname;
		
		errtext.text = "";
		serv.text = "Сервер трансляции: " + red5server;
		serv.filters = [shadow];
		fpslabel.filters = [shadow];
		currfps.filters = [shadow];
		myVid.filters = [shadow];
		//myVid2.filters = [shadow];
		
		streamlist = new ArrayCollection();
		streamdisp.dataProvider = streamlist;
		
		//timer = new Timer(1000,0);
		//timer.addEventListener(TimerEvent.TIMER, onTick);

	
		my_nc = new MyNetConnection();
		
		my_nc.addEventListener("netStatus", OnNCStatus);
		
		my_nc.connect(red5server);
		//grid = new FrameGrid(200,5,5);
		//frames = new Array();
	}
	
	
	public function addstream():void {
		 
		trace("test");
	}
	
	public function ViewStreamClick():void {
	 	
		//fullstrname = red5server+streamdisp.selectedItem.Имя;
		//strname = red5server+streamdisp.selectedItem.Имя;
		if (streamdisp.selectedItem.active)
		streamdisp.selectedItem.style="";
		ViewStream(streamdisp.selectedItem.Имя);
		
		//newframes.addItem({'label':"имя",'data':red5server+strname});
		//a = gridtiles.itemToItemRenderer(streamdisp.selectedItem) as IListItemRenderer;
	
		//frames[i] = new VideoFrame(strname,my_nc);
		
		/*var i:int = frames.length + 1; 
		frames[i] = new VideoFrame(strname,my_nc);
		frames[i].attach(grid);*/
		
		
	}
	public function PreViewStreamClick():void {
	 	streamdisp.selectedItem.style="";
	 	if (streamdisp.selectedItem.active)
		PreViewStream(streamdisp.selectedItem.Имя);
	
		
	}
	
	private function dragUserEnter(event:MouseEvent,value):void {
		
		var dropTarget:VideoDisplay = event.currentTarget as VideoDisplay;

		//cons.visible = true;
		
		DragManager.acceptDragDrop(dropTarget);

//		errtext.text += event.currentTarget.Имя as String;
		
	}

	private function dragUserDrop(event:MouseEvent,value):void {
		
		var vidd1:VideoDisplay;
		var dropTarget:VideoDisplay = event.currentTarget as VideoDisplay;
		//cons.visible = true;
		//errtext.text += dropTarget.id+"\n";
		
		vidd1 = new VideoDisplay();
		
		//ViewStream(value,dropTarget);
//		errtext.text += event.currentTarget.Имя as String;
		
	}

	private function dragUserExit(event:MouseEvent,value):void {
		
		var dropTarget:VideoDisplay = event.currentTarget as VideoDisplay;
		
//		errtext.text += event.currentTarget.Имя as String;
		
	}
	 
	
	
	private function checkdups(streamname:String):Boolean {
		
		for (var ii: int = 0; ii < streamlist.length; ii++) {
			if (streamlist.getItemAt(ii).Имя == streamname){ return false;}
		}
	return true;
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
			if (streamlist.getItemAt(ii).Имя == streamname){ 
				tmpobj = streamlist.getItemAt(ii);
				streamlist.removeItemAt(ii);
				tmpobj.style="bold";
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
	
	public function fillstreamlist():void {
		var names:Array;
		var i:int;
		
		names = username.split(",");
		
		for ( i = 0; i < names.length; i++ ) {
			streamlist.addItem({Имя:names[i],style:"",active:false});
		}
		
	}
	
	public function updatestreamlist():void {
		
	
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
	
	public function receiveMessage( ...args ):void	{
		
   		   		
   			//Alert.show(args[0]);
   			pushupitem(args[0]);
   			
   		

	}
	
	private function setqual():void {
			cam.setQuality(0,int("85"));
	}
	
	private function sendrequest():void {
		
		my_nc.call("sendMessage", null, myname);
	}
	public function playStream( ...args):void {
		
		src_ns2.play(args[0]);
		//Alert.show("Playstream initiated with "+args[0]);
	}

	private function setmaster():void {
		
		//Alert.show(masterselect.selectedValue.toString());
		if (masterselect.selectedValue.toString() == "По-умолчанию") my_nc.call("playStream", null, myname);
		else my_nc.call("playStream", null, streamdisp.selectedItem.Имя);
	}
	public function onTick(event:TimerEvent):void
	{
		//sendrequest();
		
	}
	
	private function initcam():void{
					
					//src_ns.close();
					cam = Camera.getCamera(camlist.selectedIndex.toString());
					cam.setMode(320,240,20);
					setqual();		
					
					
					myVid.attachCamera(cam);
					src_ns.attachCamera(cam);
					
					//src_ns.publish(myname);
	}
	private function initmic():void {
		
		mic = Microphone.getMicrophone(miclist.selectedIndex);
		mic.setUseEchoSuppression(true);
		src_ns.attachAudio(mic);
	
	}
	private function OnNCStatus(event:NetStatusEvent):void {
		
		var i:int;
		if(event.info.code == "NetConnection.Connect.Success") {
		connected = true;
		so = SharedObject.getRemote("message", my_nc.uri, false);
    	so.client = this;
    	so.connect(my_nc);
		
			if (Camera.names.length > 0)
			{
				
				src_ns = new NetStream(my_nc);
				initcam();
				initmic();
				src_ns.publish(myname);
			}
			else
			{
				cons.visible = true;
				errtext.text += "Веб-камера не обнаружена\n";
			}
			fillstreamlist();
			//timer.start();
			src_ns2 = new NetStream(my_nc);
			var vidd:Video = new Video();
			//vidd.addEventListener(Event.ENTER_FRAME,onPlaying);
			vidd.attachNetStream(src_ns2);
			vidd.width = mainvid.width;
			vidd.height = mainvid.height;
			
			vidd.deblocking = 2;
			vidd.smoothing = true;
			mainvid.addChild(vidd);

		}
		else  {
			//if (timer.running) timer.stop();
			cons.visible = true;
			errtext.text += event.info.code+"\n";
			errtext.text += event.info.description+"\n";
			
		}
	
		
	} 
	
	private function onPlaying(event:Event):void {
		
		currfps.text = src_ns2.currentFPS.toPrecision(2).toString();
	}

	
	public function ViewStream(streamname:String):void {

/*		streams[screen.id] = new NetStream(my_nc);
		videoframes[screen.id] = new Video();
			

		//videoframes[scren.id].addEventListener(Event.ENTER_FRAME,onPlaying);
		videoframes[screen.id].attachNetStream(streams[screen.id]);
		videoframes[screen.id].width = screen.width;
		videoframes[screen.id].height = screen.height;
		
		videoframes[screen.id].deblocking = 2;
		videoframes[screen.id].smoothing = true;
		
		streams[screen.id].play(streamname);
		screen.addChild(videoframes[screen.id]);
//		chatwithuser.text = "Видеочат с пользователем: " + streamdisp.selectedItem.Имя;
*/

	/*	src_ns2 = new NetStream(my_nc);
		var vidd:Video = new Video();
		vidd.addEventListener(Event.ENTER_FRAME,onPlaying);
		vidd.attachNetStream(src_ns2);
		vidd.width = mainvid.width;
		vidd.height = mainvid.height;
		
		vidd.deblocking = 2;
		vidd.smoothing = true;
		mainvid.addChild(vidd);
	*/	
		src_ns2.play(streamname);
		
		
		chatwithuser.text = "Видеочат с пользователем: " + streamdisp.selectedItem.Имя;

		
	}
	
	public function PreViewStream(streamname:String):void {


		src_ns3 = new NetStream(my_nc);
		var vidd1:Video = new Video();
		
		vidd1.attachNetStream(src_ns3);
		vidd1.width = preview.width;
		vidd1.height = preview.height;
		
		vidd1.deblocking = 2;
		vidd1.smoothing = true;
		
		src_ns3.play(streamname);
		
		
		preview.addChild(vidd1);
		

		
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

/*
	public function checknamein():void {
		if (mynamefield.text == "Ваше имя") mynamefield.text = "";
	}
	
	public function checknameout():void {
		if (mynamefield.text == "") mynamefield.text = "Ваше имя";
		 
	}

	public function checknameedit():void {
		if ((mynamefield.text != "Ваше имя")&&(mynamefield.text != "" )) enterbutton.enabled = true;
		else enterbutton.enabled = false;
	}
*/

