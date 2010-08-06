/*
Author-MAheSH Gondi

MASH
*/

package org.flex_pilot.events
{
	import flash.events.Event;
	
	import mx.events.SliderEvent;
	
	public class FPSliderEvent extends SliderEvent
	{
		public function FPSliderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, thumbIndex:int=-1, value:Number=NaN, triggerEvent:Event=null, clickTarget:String=null, keyCode:int=-1)
		{
			super(type, bubbles, cancelable, thumbIndex, value, triggerEvent, clickTarget, keyCode);
		}
	}
}