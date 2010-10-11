package org.flex_pilot.events
{
	import spark.events.IndexChangeEvent;
	
	public class FPIndexChangeEvent extends IndexChangeEvent
	{
		public function FPIndexChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, oldIndex:int=-1, newIndex:int=-1)
		{
			super(type, bubbles, cancelable, oldIndex, newIndex);
		}
	}
}