package routines
{
	import flash.events.NetStatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	
	import mx.controls.VideoDisplay;
	
	import mynetconnection.MyNetConnection;
	
	import routines.MyNetStream;

	public class Netvid extends VideoDisplay
	{
		public var stream:String;
		public var vid:Video;
		public var ns:MyNetStream;
		public var repeat:Boolean = false;
		public var streamname:String;
		public var active:Boolean = false;
		public function Netvid():void
		{
			vid = new Video;
			vid.smoothing = true;
			vid.deblocking = 2;
			vid.width = this.width;
			vid.height = this.height;
			
			this.addChild(vid);
			super();
		}
		public function initnet(nc:MyNetConnection):void
		{
			this.ns = new MyNetStream(nc);
			ns.addEventListener(NetStatusEvent.NET_STATUS,onNSStatus);
			this.vid.attachNetStream(this.ns);
			
		}
		private function onNSStatus(event:NetStatusEvent):void
		{
			if (event.info.code == "NetStream.Play.Stop")
			{
				if (repeat){
					ns.seek(0);
				}
					
			}
		}
	}
}