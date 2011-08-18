package routines
{
	import flash.events.*;
	import flash.media.Video;
	
	import mx.controls.VideoDisplay;
	import mx.events.*;
	


	public class StreamVideoDisplay extends VideoDisplay
	{
		private var creationCompleted:Boolean = false;
		private var _streamsource:String = null;
		private var sourceChanged:Boolean = false;
		public var display:Video;
		
		public function StreamVideoDisplay()
		{
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);

		}
		private function creationCompleteHandler(event:FlexEvent):void
    		{
		        removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteHandler);
		        //creationCompleted = true;
		      playstream();
    		}
   	    public function get streamsource():String
		    {
		        return _streamsource;
		    }

	    public function set streamsource(value:String):void
	    {
	        if (_streamsource != value)
	        {
	            _streamsource = value;
	            sourceChanged = true;
	//            dispatchEvent(new Event("sourceChanged"));
	            if (creationCompleted)
	                playstream();
	                
	        }
	    }
	    public function playstream():void {
	    	
	    }




		
	}
}