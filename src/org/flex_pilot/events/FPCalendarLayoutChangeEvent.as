package org.flex_pilot.events
{
	import flash.events.Event;
	
	import mx.events.CalendarLayoutChangeEvent;
	
	public class FPCalendarLayoutChangeEvent extends CalendarLayoutChangeEvent
	{
		public function FPCalendarLayoutChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, newDate:Date=null, triggerEvent:Event=null)
		{
			super(type, bubbles, cancelable, newDate, triggerEvent);
			
		}
	}
}