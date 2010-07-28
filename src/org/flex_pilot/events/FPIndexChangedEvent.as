package org.flex_pilot.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.events.IndexChangedEvent;
	
	public class FPIndexChangedEvent extends IndexChangedEvent
	{
		public function FPIndexChangedEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, relatedObject:DisplayObject=null, oldIndex:Number=-1, newIndex:Number=-1, triggerEvent:Event=null)
		{
			super(type, bubbles, cancelable, relatedObject, oldIndex, newIndex, triggerEvent);
		}
	}
}