/*
Copyright 2009, Matthew Eernisse (mde@fleegix.org) and Slide, Inc.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

package org.flex_pilot.events {
  import flash.events.*;
  import flash.utils.getDefinitionByName;
  
  import mx.core.DragSource;
  import mx.core.mx_internal;
  import mx.events.*;
  
  import org.flex_pilot.events.*;
  
  import util.DataGridUtil;
  import util.IndexChangeUtil;
  
  FP::complete  {
  import util.AdvancedDataGridUtil;
  import mx.controls.AdvancedDataGrid;
  }
  
  

  public class Events {
    public function Events():void {}

    // Allow lengthy list of ordered params or a simple params
    // object to override the default values
    // NOTE: 'default' param is an array of arrays -- this is
    // a janky hack because Object keys in AS3 don't iterate
    // in their insertion order
    private static function normalizeParams(defaults:Array,
        args:Array):Object {
      var p:Object = {};
      var elem:*;
      // Merge the two arrays into a params obj
      for each (elem in defaults) {
        p[elem[0]] = elem[1];
      };
      // If there are other params, that means either ordered
      // params, or a single params object to set all the options
      if (args.length) {
        // Ordered params -- use these to override vals
        // in the params map
        if (args[0] is Boolean) {
          // Iterate through the array of param keys to pull
          // out any param values passed, in order
          for each (elem in defaults) {
            p[elem[0]] = args.shift();
            if (!args.length) {
              break;
            }
          }
        }
        // Options param obj
        else {
          for (var prop:String in p) {
            if (prop in args[0]) {
              p[prop] = args[0][prop];
            }
          }
        }
      }
      return p;
    }

    public static function triggerMouseEvent(obj:*, type:String,
        ...args):void {
      // AS3 Object keys don't iterate in insertion order
      var defaults:Array = [
        ['bubbles', true], // Override the default of false
        ['cancelable', false],
        ['localX', 0], // Override the default of NaN
        ['localY', 0], // Override the default of NaN
        ['relatedObject', null],
        ['ctrlKey', false],
        ['altKey', false],
        ['shiftKey', false],
        ['buttonDown', false],
        ['delta', 0]
      ];
	  
	  
      var p:Object = Events.normalizeParams(defaults, args);
	  
      var ev:FPMouseEvent = new FPMouseEvent(type, p.bubbles,
          p.cancelable, p.localX, p.localY,
          p.relatedObject, p.ctrlKey, p.altKey, p.shiftKey,
          p.buttonDown, p.delta);
      // Check for stageX and stageY in params obj -- these are
      // only getters in th superclass, so we don't set them in
      // the constructor -- we set them here.
      if (args.length && !(args[0] is Boolean)) {
        p = args[0];
        if ('stageX' in p) {
          ev.stageX = p.stageX;
        }
        if ('stageY' in p) {
          ev.stageY = p.stageY;
        }
      }
      obj.dispatchEvent(ev);
    }

    public static function triggerTextEvent(obj:*, type:String,
        ...args):void {
      // AS3 Object keys don't iterate in insertion order
      var defaults:Array = [
        ['bubbles', true], // Override the default of false
        ['cancelable', false],
        ['text', '']
      ];
      var p:Object = Events.normalizeParams(defaults, args);
      var ev:FPTextEvent = new FPTextEvent(type, p.bubbles,
          p.cancelable, p.text);
      obj.dispatchEvent(ev);
    }

    public static function triggerFocusEvent(obj:*, type:String,
        ...args):void {
      // AS3 Object keys don't iterate in insertion order
      var defaults:Array = [
        ['bubbles', true], // Override the default of false
        ['cancelable', false],
        ['relatedObject', null],
        ['shiftKey', false],
        ['keyCode', 0]
      ];
      var p:Object = Events.normalizeParams(defaults, args);
      var ev:FPFocusEvent = new FPFocusEvent(type, p.bubbles,
          p.cancelable, p.relatedObject, p.shiftKey, p.keyCode);
      obj.dispatchEvent(ev);
    }
    
    public static function triggerKeyboardEvent(obj:*, type:String,
        ...args):void {
      // AS3 Object keys don't iterate in insertion order
      var defaults:Array = [
        ['bubbles', true], // Override the default of false
        ['cancelable', false],
        ['charCode', 0],
        ['keyCode', 0],
        ['keyLocation', 0],
        ['ctrlKey', false],
        ['altKey', false],
        ['shiftKey', false]
      ];
      var p:Object = Events.normalizeParams(defaults, args);
      var ev:FPKeyboardEvent = new FPKeyboardEvent(type, p.bubbles,
          p.cancelable, p.charCode, p.keyCode, p.keyLocation,
          p.ctrlKey, p.altKey, p.shiftKey);
      obj.dispatchEvent(ev);
    }
    public static function triggerListEvent(obj:*, type:String,
        ...args):void {
      // AS3 Object keys don't iterate in insertion order
      var defaults:Array = [
        ['bubbles', false], // Don't override -- the real one doesn't bubble
        ['cancelable', false],
        ['columnIndex', -1],
        ['rowIndex', -1],
        ['reason', null],
        ['itemRenderer', null]
      ];
      var p:Object = Events.normalizeParams(defaults, args);
      var ev:FPListEvent = new FPListEvent(type, p.bubbles,
          p.cancelable, p.columnIndex, p.rowIndex, p.reason,
          p.itemRenderer);
      obj.dispatchEvent(ev);
    }
	
	
	
	public static function  triggerSliderEvent(obj:* , type:String , ...args):void{
		var defaults:Array=[
			['bubbles',false],
			['cancelable',false],
			['thumbIndex',-1],
			['triggerEvent',null],
			['clickTarget',null],
			['keyCode',-1]
			];
		var p:Object = Events.normalizeParams(defaults, args);
		var ev:FPSliderEvent=new FPSliderEvent(type, p.bubbles, p.cancelable, p.thumbIndex, p.value, p.triggerEvent, p.clickTarget, p.keyCode);
		obj.dispatchEvent(ev);
		
			
	}
	
	public static function triggerCalendarLayoutChangeEvent(obj:* , type:String , ...args):void{
		var defaults:Array=[
			['bubbles',false],
			['cancelable',false],
			['newDate',null],
			['triggerEvent',null]
		];
		
		var p:Object=Events.normalizeParams(defaults, args);
		
		
		var ev:FPCalendarLayoutChangeEvent=new FPCalendarLayoutChangeEvent(type, p.bubbles, p.cancelable, p.newDate, p.triggerEvent);
		obj.dispatchEvent(ev);
		
	}
	
	public static function triggerDataGridEvent(obj:* , type:String , ...args):void{
		
		var defaults:Array=[
		['bubbles' , true],
		['cancelable' , false],
		['columnIndex',-1],
		['dataField',null],
		['rowIndex',-1],
		['reason',null],
		['itemRenderer',null],
		['localX',NaN],
		['newValue',null],
		['sortDescending',null] ,
		['dir' , false] , 
		['caseSensitivity' , false]
		];
		var p:Object=Events.normalizeParams(defaults, args);
		
		
		var ev:FPDataGridEvent=new FPDataGridEvent(type , p.bubbles , p.cancelable , p.columnIndex , p.dataField , p.rowIndex , p.reason , p.itemRenderer ,p.localX);
		switch(type){
		
			case DataGridEvent.COLUMN_STRETCH :
				DataGridUtil.columnStretch(obj , p.columnIndex , p.localX );
				break ;
			
			case DataGridEvent.ITEM_EDIT_END :
				for(var i:* in obj.columns)
				if(p.dataField==obj.columns[i].dataField){
					p.columns=i;
				}
					
					
				DataGridUtil.itemEdit(obj , p.rowIndex ,p.columnIndex, p.dataField , p.newValue); 
				break;
			
			case FPDataGridEvent.SORT_ASCENDING :
				ev.preventDefault();
				DataGridUtil.sortGridOrder(obj , p.columnIndex , p.dir ,p.caseSensitivity);
				break;
			
			case FPDataGridEvent.SORT_DESCENDING :
				ev.preventDefault();
				DataGridUtil.sortGridOrder(obj , p.columnIndex , p.dir ,p.caseSensitivity);
				break;
			case DataGridEvent.HEADER_RELEASE :
				ev.preventDefault();
				DataGridUtil.dgSort(obj , p.columnIndex , p.caseSensitivity );
				break;

				
				
		}
			
			
		
		obj.dispatchEvent(ev);
		
	
	}
	
	FP::complete
	public static function triggerAdvancedDataGridEvent(obj:* , type:String , ...args):void{
		var defaults:Array = [
			['bubbles' , false] , 
			['cancelable' , true] ,
			['columnIndex' , -1],
			['dataField' , null ] ,
			['rowIndex' , -1 ],
			['reason' , null ] ,
			['localX' , NaN ], 
			['multiColumnSort' ,false] ,
			['removeColumnFromSort' , false] , 
			['item' , null ],
			['triggerEvent' ,null] ,
			['headerPart' , null] ,
			['opening' , true], 
			['caseSensitivity' , false] , 
			['dir' , false] , 
			['newValue' , null]
		];
		
		var p:Object=Events.normalizeParams(defaults, args);
		
		
		trace(p.rowIndex , p.columnIndex);
		
		// just a simple mechanism to handle the adg if it's dataProvider had been reset . this may cause a change in the value for the field 'mx_internal_uid' in dataProvider with respect to the original testcase
		var found:Boolean=false;
		if(p.item)
		for(var i:* in obj.dataProvider){
			
			found=true;
			
			for(var v:* in p.item){
				if(p.item[v]!=obj.dataProvider[i][v]&&v.indexOf('mx_internal_uid')==-1){
					found=false;
					break;
				}
			}
			
			
			if(p.item.length&&found){
				p.columnIndex=i;
				p.item=obj.dataProvider[i];
				break;
			}
		}
		
		trace(p.rowIndex , p.columnIndex);
		
		var ev:FPAdvancedDataGridEvent = new FPAdvancedDataGridEvent( type , p.bubbles , p.cancelable , p.columnIndex , p.dataField , p.rowIndex , p.reason , obj.itemToItemRenderer(p.item)  , p.localX , p.multiColumnSort , p.removeColumnFromSort , p.item , p.triggerEvent , p.headerPart);
		
		
		
		
		switch(type){
			case AdvancedDataGridEvent.ITEM_OPENING :
				ev.opening=p.opening;
				break;
			case AdvancedDataGridEvent.COLUMN_STRETCH :
				AdvancedDataGridUtil.columnStretch(obj , p.columnIndex , p.localX);
				break;
			case AdvancedDataGridEvent.HEADER_RELEASE :
				ev.preventDefault();
				AdvancedDataGridUtil.adgSort(obj , p.columnIndex , p.caseSensitivity );
				break;
			case FPAdvancedDataGridEvent.SORT_ASCENDING :
				ev.preventDefault();
				AdvancedDataGridUtil.sortGridOrder(obj , p.columnIndex , p.dir , p.caseSensitivity);
				break;
			
			case FPAdvancedDataGridEvent.SORT_DESCENDING :
				ev.preventDefault();
				AdvancedDataGridUtil.sortGridOrder(obj , p.columnIndex , p.dir , p.caseSensitivity);
				break;
			case AdvancedDataGridEvent.ITEM_EDIT_END :
				ev.preventDefault();
				AdvancedDataGridUtil.itemEdit(obj , p.rowIndex , p.columnIndex , p.newValue);
				break;
		}
		
	}
	
	public static function triggerIndexChangedEvent(obj:* , type:String , ...args):void{
		
		var defaults:Array = [
			['bubbles' , false] , 
			['cancelable' , false] ,
			['relatedObject' , null] ,
			['oldIndex' , -1] ,
			['newIndex' , -1] , 
			['triggerEvent' , null]
		];
		
		var p:Object=Events.normalizeParams(defaults, args);
		
		var ev:FPIndexChangedEvent = new FPIndexChangedEvent(type , p.bubbles , p.cancelable , p.relatedObject , p.oldIndex , p.newIndex , p.triggerEvent);
		
		IndexChangeUtil.headerShift(obj , p.oldIndex , p.newIndex);
		
		obj.dispatchEvent(ev);
	}
	
	public static function triggerIndexChangeEvent(obj:* , type:String , ...args):void{
		
		var defaults:Array = [
			['bubbles' , false] , 
			['cancelable' , false] ,
			['oldIndex' , -1] ,
			['newIndex' , -1] , 
		];
		
		var p:Object=Events.normalizeParams(defaults, args);
		var fpIndxChngEvt:*=getDefinitionByName('org.flex_pilot.events.FPIndexChangeEvent');
		var ev:* = new fpIndxChngEvt(type , p.bubbles , p.cancelable ,p.oldIndex , p.newIndex );
		
		
		
		obj.dispatchEvent(ev);
	}
	
	public static function triggerEventEvent(obj:* , type:String , ...args):void{
		
		var defaults:Array = [
			['bubbles' , false] , 
			['cancelable' , false] ,
		];
		
		var p:Object=Events.normalizeParams(defaults, args);
		
		var ev:FPEvent = new FPEvent(type , p.bubbles , p.cancelable );
		
		obj.dispatchEvent(ev);
	}
	
	public static function triggerDragEvent(obj:* , type:* , ...args):void{
	
		var defaults:Array=[
			['bubbles' , false] ,
			['cancelable' , true],
			['dragInitiator' , null],
			['dragSource' , null ],
			['action' , null],
			['ctrlKey' ,false],
			['altKey' , false],
			['shiftKey' , false] ,
			['stageX' , NaN ],
			['stageY' , NaN] ,
			['localX' , NaN ] ,
			['localY' , NaN] , 
			['selectedItems' , null]
		];
		
		var p:Object=Events.normalizeParams(defaults, args);
		
		var ds:DragSource=new DragSource;
		
		ds.addHandler( function(useDataField:Boolean=true):Array{
			return p.selectedItems;
		} , "items");
		
		
		var e:FPDragEvent=new FPDragEvent(type ,p.bubbles , p.cancelable , p.dragInitiator , ds , p.action , p.ctrlKey , p.altKey , p.shiftKey );
		
		e.localX=p.localX;
		e.localY=p.localY;
		
		obj.dispatchEvent(e);
		
	}
	
	
	
  }
}

