package org.flex_pilot.events
{
	import flash.events.Event;
	
	public class FPEvent extends Event
	{
		public function FPEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}