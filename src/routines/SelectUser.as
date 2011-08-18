package routines
{
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.CheckBox;
	import mx.core.Application;

	public class SelectUser extends CheckBox
	{
		public function SelectUser()
		{
			super();
			this.addEventListener("click",onClick);
		}
		
		public function onClick(event:MouseEvent):void{
			var counter:int = 0;
			Application.application.streamlist.getItemAt(1);
			for (var i = 0; i< Application.application.streamlist.length; i++)
			{
				if	(Application.application.streamlist.getItemAt(i).selected){
					counter++;
					if (counter > 4){
						Alert.show("Выберите не более 5 человек");
					} 
				
				}
			}
			if(this.selected) Application.application.streamdisp.selectedItem.selected = true;
			else Application.application.streamdisp.selectedItem.selected = false;
		}
		
		
		}

}