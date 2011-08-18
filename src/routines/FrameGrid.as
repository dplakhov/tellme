package routines
{
	import mx.containers.Canvas;
	import mx.core.Application;
	
		public class FrameGrid {
		
		public var field:Canvas;
		
		public var gridW:uint;
		public var gridH:uint;
		public var gridX:uint = 5;
		public var gridY:uint = 5; 

		public var vCells:uint;
		public var hCells:uint;
		public var cellW:uint;
		public var cellH:uint;
		public var cells:Object;
		
		public var cellsTotal:uint;
		
		public var aspect = 1.333333;
		
		public function FrameGrid(width:uint,hElems:uint,vElems:uint) {

			vCells = vElems;
			hCells = hElems;
			cellsTotal = (vCells * hCells);
			gridW = width;
			

			cellW = (gridW / hCells) - (gridW % hCells);
			cellH = (cellW / aspect) - (cellW % aspect);

			gridH = cellH * vCells;
			
			

			field = new Canvas();
			Application.application.addChild(field);
			field.x = gridX; field.y = gridY;
			field.width = gridW;
			field.height = gridH;
			
			fillgrid();

		} 
		
		private function fillgrid():void {
			
			var x:uint = 0;
			var y:uint = 0;
			var z:uint = 0;
			
			cells = new Object();
			
			for (z = 0; z < cellsTotal; z++) {
				cells[z] = [x,y,true];
				x += cellW;
				if (((z+1)%hCells) == 0) {
					y += cellH;
					x = 0;
				} 
			}
		}

		public function getfreecell():int {
			var z;
			for (z = 0; z < cellsTotal; z++) {
				if (cells[z][2]) return z;
			}
		return -1;
		}
		
	/*	public function addframe(frame:VideoFrame):Boolean {
			var fn:int = getfreecell();
			if (fn == -1) return false;
			field.AddChild(frame.display);
			frame.display.x = cells[fn][0];
			frame.display.y = cells[fn][1];
			frame.display.setsize(cellW,cellH);
			frame.display.sets
		return true;	
		}*/
		
	}
}