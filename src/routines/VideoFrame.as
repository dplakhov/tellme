package routines
{
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import mx.controls.VideoDisplay;
	
	public class VideoFrame 
	{
		public var display:VideoDisplay;
		public var video:Video;
		public var stream:NetStream;
		public var streamname:String;
		public var defaultW:uint = 275;
		public var defaultH:uint = 206;
		public var cellid:int = -1;
		
		public function VideoFrame(strname:String,nc:NetConnection)
		{
			
			streamname = strname;
			display = new VideoDisplay();
			display.width = defaultW;
			display.height = defaultH;
			stream = new NetStream(nc);
			video = new Video();
			video.attachNetStream(stream);
			video.width = display.width;
			video.height = display.height;
			video.deblocking = 2;
			video.smoothing = true;
			display.addChild(video);
			stream.play(this.streamname);
		}
		
		public function attach(grid:FrameGrid):Boolean {
			
			cellid = grid.getfreecell();
			if (cellid == -1) return false;
			grid.field.addChild(display);
			display.x = grid.cells[cellid][0];
			display.y = grid.cells[cellid][1];
			
			setsize(grid.cellW,grid.cellH);
			grid.cells[cellid][2] = false;
			
			
			return true;	
		}
		
		public function detach(grid:FrameGrid) {
			grid.cells[cellid][2] = true;
			
		}
		
		public function setsize(w:uint,h:uint){
			display.width = w;
			display.height = h;
			video.width = display.width;
			video.height = display.height;
		}		
		
	
	
	}
	

	
	
}