package org.flex_pilot.events
{
	import mx.core.DragSource;
	import mx.core.IUIComponent;
	import mx.events.DragEvent;
	
	public class FPDragEvent extends DragEvent
	{
		public function FPDragEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true, dragInitiator:IUIComponent=null, dragSource:DragSource=null, action:String=null, ctrlKey:Boolean=false, altKey:Boolean=false, shiftKey:Boolean=false)
		{
			super(type, bubbles, cancelable, dragInitiator, dragSource, action, ctrlKey, altKey, shiftKey);
		}
	}
}