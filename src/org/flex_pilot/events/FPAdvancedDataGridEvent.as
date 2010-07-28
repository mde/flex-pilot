package org.flex_pilot.events
{
	import flash.events.Event;
	
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.AdvancedDataGridEvent;
	
	public class FPAdvancedDataGridEvent extends AdvancedDataGridEvent
	{
		
		public static const SORT_ASCENDING:String='sortAscending';
		public static const SORT_DESCENDING:String='sortDescending';
		
		public function FPAdvancedDataGridEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, columnIndex:int=-1, dataField:String=null, rowIndex:int=-1, reason:String=null, itemRenderer:IListItemRenderer=null, localX:Number=NaN, multiColumnSort:Boolean=false, removeColumnFromSort:Boolean=false, item:Object=null, triggerEvent:Event=null, headerPart:String=null)
		{
			super(type, bubbles, cancelable, columnIndex, dataField, rowIndex, reason, itemRenderer, localX, multiColumnSort, removeColumnFromSort, item, triggerEvent, headerPart);
		}
	}
}