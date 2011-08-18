package routines
{
	
	import flash.events.MouseEvent;
	
	import mx.controls.Image;
	import mx.core.Application;
	
	
	
	
	public class StatusImage extends Image
	{
		[Bindable]
		[Embed (source="./assets/online.png")]
		private var imgOnline:Class;

		[Bindable]
		[Embed (source="./assets/offline.png")]
		private var imgOffline:Class;

		[Bindable]
		[Embed (source="./assets/onsite.png")]
		private var imgOnsite:Class;
		
		
		[Bindable]
		[Embed (source="./assets/publishing.png")]
		private var imgPublishing:Class;
		
		[Embed(source="assets/setmaster.png")]
		[Bindable]
		public var imgSetMaster:Class;

		[Embed(source="assets/tovip.png")]
		[Bindable]
		public var imgToVip:Class;

		[Embed(source="assets/preview.png")]
		[Bindable]
		public var imgPreview:Class;
		
		private var _status:String;
		private var _online:String;
		//public var mystate:String;

		public function StatusImage()
		{
			this.width = 10;
			this.height = 10;
			super();
		}
		
		
	/*	public function set mystate(mstate:String):void{
			sstate = mstate;			
			if (mstate == "paused") this.source = new iplay();
			if (mstate == "playing") this.source = new ipause(); 

		
		}
	*/	public function set online(online:String):void{
			this._online =  online;
			
			if (this._online == "true")
			{
				this.source = new imgOnsite();
				
			}
			else
			{
				this.source = new imgOffline();
				
			}
		}
			
	
		public function set status(status:String):void{
			this._status = status;
			switch (status){

				case ("4Не в сети"):
					this.source = new imgOffline();
					break;

				case ("3На сайте"):
					this.source = new imgOnsite();
					
					break;
				
				case ("2Онлайн"):
					this.source = new imgOnline();
					break;

				case ("1Занят"):
					this.source = new imgPublishing();
					break;

				case ("setmaster"):
					this.source = new imgSetMaster();
					this.width = 10;
					this.height = 10;
					break;

				case ("preview"):
					this.source = new imgPreview();
					this.width = 10;
					this.height = 10;

					break;

				case ("tovip"):
					this.source = new imgToVip();
					this.width = 10;
					this.height = 10;

					break;
			}
			
		}
		
		
		
		 
		
	}
}