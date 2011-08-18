package routines
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	public class MyNetStream extends NetStream
	{
		public var aspect:Number = 0;
		public function MyNetStream(connection:NetConnection, peerID:String="connectToFMS")
		{
			super(connection, peerID);
		}
		public function onMetaData(data):void
		{
			this.aspect = (data.width/data.height);
		}
		
		public function onXMPData(data):void
		{
		}
	}
}