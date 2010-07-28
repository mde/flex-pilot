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

package org.flex_pilot {
  import flash.events.*;
  import flash.geom.Point;
  import flash.ui.Mouse;
  import flash.utils.*;
  
  
  import mx.controls.DataGrid;
  import mx.events.*;
  
  import org.flex_pilot.FPLocator;
  import org.flex_pilot.events.*;
  
  FP::complete{
	  import mx.controls.AdvancedDataGrid;  
  }

  public class FPController {
	  
    public function FPController():void {}
    
    public static function mouseOver(params:Object):void {
      var obj:* = FPLocator.lookupDisplayObject(params);
      Events.triggerMouseEvent(obj, MouseEvent.MOUSE_OVER);
      Events.triggerMouseEvent(obj, MouseEvent.ROLL_OVER);
    }

    public static function mouseOut(params:Object):void {
      var obj:* = FPLocator.lookupDisplayObject(params);
      Events.triggerMouseEvent(obj, MouseEvent.MOUSE_OUT);
      Events.triggerMouseEvent(obj, MouseEvent.ROLL_OUT);
    }

    public static function click(params:Object):void {
      var obj:* = FPLocator.lookupDisplayObject(params);

      //Figure out what kind of displayObj were dealing with
      var classInfo:XML = describeType(obj);
      classInfo =  describeType(obj);
      var objType:String = classInfo.@name.toString();

<<<<<<< HEAD
      //if we have an accordion
      if (objType.indexOf('mx.containers::Accordion') != -1){
        for(var i:int = 0; i < obj.numChildren; i++) {
          var atb:Object = obj.getHeaderAt(i) as Object;
          if (atb.label == params.label) {
            Events.triggerMouseEvent(atb, MouseEvent.CLICK);
          }
        }
      }
      else {
=======
      function doTheClick(obj:*):void {
>>>>>>> e209f5edff16e1b867864a9212fb576f4173147e
        // Give it focus
        Events.triggerFocusEvent(obj, FocusEvent.FOCUS_IN);
        // Down, (TextEvent.LINK,) up, click
        Events.triggerMouseEvent(obj, MouseEvent.MOUSE_DOWN, {
            buttonDown: true });
        // If this is a link, do the TextEvent hokey-pokey
        // All events fire on the containing DisplayObject
        if ('link' in params) {
          var link:String = FPLocator.locateLinkHref(params.link,
            obj.htmlText);
          Events.triggerTextEvent(obj, TextEvent.LINK, {
              text: link });
        }
        Events.triggerMouseEvent(obj, MouseEvent.MOUSE_UP);
        Events.triggerMouseEvent(obj, MouseEvent.CLICK);
      }

      //if we have an accordion
      if (objType.indexOf('Accordion') != -1){
        for(var i:int = 0; i < obj.numChildren; i++) {
          var atb:Object = obj.getHeaderAt(i) as Object;
          if (atb.label == params.label) {
            doTheClick(atb);
          }
        }
      }
      else { doTheClick(obj); }
    }

    // Click alias functions
    public static function check(params:Object):void {
      return FPController.click(params);
    }
	
	
	
    public static function radio(params:Object):void {
      return FPController.click(params);
    }

    public static function dragDropElemToElem(params:Object):void {
      // Figure out what the destination is
      var destParams:Object = {};
      for (var attrib:String in params) {
        if (attrib.indexOf('opt') != -1){
          destParams[attrib.replace('opt', '')] = params[attrib];
          break;
        }
      }
      var dest:* = FPLocator.lookupDisplayObject(destParams);
      var destCoords:Point = new Point(0, 0);
      destCoords = dest.localToGlobal(destCoords);
      params.coords = '(' + destCoords.x + ',' + destCoords.y + ')';
      dragDropToCoords(params);
    }

    public static function dragDropToCoords(params:Object):void {
      var obj:* = FPLocator.lookupDisplayObject(params);
      var startCoordsLocal:Point = new Point(0, 0);
      var endCoordsAbs:Point = FPController.parseCoords(params.coords);
      // Convert local X/Y to global
      var startCoordsAbs:Point = obj.localToGlobal(startCoordsLocal);
      // Move mouse over to the dragged obj
      Events.triggerMouseEvent(obj.stage, MouseEvent.MOUSE_MOVE, {
        stageX: startCoordsAbs.x,
        stageY: startCoordsAbs.y
      });
      Events.triggerMouseEvent(obj, MouseEvent.ROLL_OVER);
      Events.triggerMouseEvent(obj, MouseEvent.MOUSE_OVER);
      // Give it focus
      Events.triggerFocusEvent(obj, FocusEvent.FOCUS_IN);
      // Down, (TextEvent.LINK,) up, click
      Events.triggerMouseEvent(obj, MouseEvent.MOUSE_DOWN, {
          buttonDown: true });
      // Number of steps will be number of pixels in shorter delta
      var deltaX:int = endCoordsAbs.x - startCoordsAbs.x;
      var deltaY:int = endCoordsAbs.y - startCoordsAbs.y;
      var stepCount:int = 10; // Just pick an arbitrary number of steps
      // Number of pixels to move per step
      var incrX:Number = deltaX / stepCount;
      var incrY:Number = deltaY / stepCount;
      // Current pos as the move happens
      var currXAbs:Number = startCoordsAbs.x;
      var currYAbs:Number = startCoordsAbs.y;
      var currXLocal:Number = startCoordsLocal.x;
      var currYLocal:Number = startCoordsLocal.y;
      // Step number
      var currStep:int = 0;
      // Use a delay so we can see the move
      var stepTimer:Timer = new Timer(5);
      // Step function -- reposition per step
      var doStep:Function = function ():void {
        if (currStep <= stepCount) {
          Events.triggerMouseEvent(obj, MouseEvent.MOUSE_MOVE, {
            stageX: currXAbs,
            stageY: currYAbs,
            localX: currXLocal,
            localY: currYLocal
          });
          currXAbs += incrX;
          currYAbs += incrY;
          currXLocal += incrX;
          currYLocal += incrY;
          currStep++;
        }
        // Once it's finished, stop the timer and trigger
        // the final mouse events
        else {
          stepTimer.stop();
          Events.triggerMouseEvent(obj, MouseEvent.MOUSE_UP, {
            stageX: currXAbs,
            stageY: currYAbs,
            localX: currXLocal,
            localY: currYLocal
          });
          Events.triggerMouseEvent(obj, MouseEvent.CLICK, {
            stageX: currXAbs,
            stageY: currYAbs,
            localX: currXLocal,
            localY: currYLocal
          });
        }
      }
      // Start the timer loop
      stepTimer.addEventListener(TimerEvent.TIMER, doStep);
      stepTimer.start();
    }
	
	public static function dragDrop(params:Object):void{
		
		var dropLoc:* = FPLocator.lookupDisplayObject(params);
		var dragFrom:* =  FPLocator.lookupDisplayObject(params.start);	
		var startParams:*=params.start.params;
		var endParams:*=params;
		
		trace(startParams.stageX , startParams.stageY , endParams.startX , endParams.startY );
		
		Events.triggerMouseEvent(dragFrom.stage, MouseEvent.MOUSE_MOVE, {
			stageX: startParams.stageX,
			stageY: startParams.stageY ,
			ctrlKey : endParams.ctrlKey ,
			shiftKey : endParams.shiftKey ,
			altKey : endParams.altKey
		});
		
		Events.triggerMouseEvent(dragFrom, MouseEvent.ROLL_OVER);
		Events.triggerMouseEvent(dragFrom, MouseEvent.MOUSE_OVER);
		Events.triggerFocusEvent(dragFrom, FocusEvent.FOCUS_IN);
		
		// just a trick . when the data component is fresh and asked to drag , the drag never occurs . 
		Events.triggerDragEvent(dragFrom , DragEvent.DRAG_START ,startParams);                
		
		dragFrom.validateNow();
		dragFrom.selectedIndices=startParams.selectedIndices;
		dragFrom.destroyItemEditor();
		
		//ugly but can't help it . . . . component takes some time to set the value for 
		//selectedIndex and during that time any other activity might result in the required item not being selected
		setTimeout(function():void{
		
  		Events.triggerMouseEvent(dragFrom, MouseEvent.MOUSE_DOWN, {
  			buttonDown: true  , 
  			ctrlKey : endParams.ctrlKey ,
  			shiftKey : endParams.shiftKey ,
  			altKey : endParams.altKey}
  		);
		
  		Events.triggerDragEvent(dragFrom , DragEvent.DRAG_START ,startParams);
			
  		var deltaX:int = -startParams.stageX + endParams.stageX;
  		var deltaY:int = -startParams.stageY + endParams.stageY;
  		var stepCount:int = 10; // Just pick an arbitrary number of steps
  		// Number of pixels to move per step
  		var incrX:Number = deltaX / stepCount;
  		var incrY:Number = deltaY / stepCount;
  		// Current pos as the move happens
  		var currXAbs:Number = startParams.stageX;
  		var currYAbs:Number = startParams.stageY;
		
  		var pnt:Point=dragFrom.globalToLocal(new Point(currXAbs , currYAbs));
		
  		var currXLocal:Number = pnt.x;
  		var currYLocal:Number = pnt.y;
  		// Step number
  		var currStep:int = 0;
  		// Use a delay so we can see the move
  		var stepTimer:Timer = new Timer(50);
  		// Step function -- reposition per step
  		var doStep:Function = function ():void {
  			trace(currStep);
  			if (currStep <= stepCount) {
  				Events.triggerMouseEvent( dragFrom, MouseEvent.MOUSE_MOVE, {
  					stageX: currXAbs,
  					stageY: currYAbs,
  					localX: currXLocal,
  					localY: currYLocal ,
  					ctrlKey : endParams.ctrlKey ,
  					shiftKey : endParams.shiftKey ,
  					altKey : endParams.altKey
  				});
				
  				currXAbs += incrX;
  				currYAbs += incrY;
  				currXLocal += incrX;
  				currYLocal += incrY;
  				currStep++;
  			}

  			else {
  				stepTimer.stop();
  				Events.triggerMouseEvent( dragFrom, MouseEvent.MOUSE_MOVE, {
  					stageX: currXAbs,
  					stageY: currYAbs,
  					localX: currXLocal,
  					localY: currYLocal ,
  					ctrlKey : endParams.ctrlKey ,
  					shiftKey : endParams.shiftKey ,
  					altKey : endParams.altKey
  				});
				
  				Events.triggerMouseEvent(dropLoc, MouseEvent.ROLL_OVER);
  				Events.triggerMouseEvent(dropLoc, MouseEvent.MOUSE_OVER);
  				// Give it focus
  				Events.triggerFocusEvent(dropLoc, FocusEvent.FOCUS_IN);
  				Events.triggerMouseEvent(dragFrom, MouseEvent.MOUSE_UP, {
  					stageX: currXAbs,
  					stageY: currYAbs, 
  					localX : currXLocal ,
  					localY : currYLocal ,
  					ctrlKey : endParams.ctrlKey ,
  					shiftKey : endParams.shiftKey ,
  					altKey : endParams.altKey
  				});
  				Events.triggerMouseEvent(dragFrom , MouseEvent.CLICK);
  			}
  		}

  		stepTimer.addEventListener(TimerEvent.TIMER, doStep);
  		stepTimer.start();		
		} , 25);
	}

    // Ensure coords are in the right format and are numbers
    private static function parseCoords(coordsStr:String):Point {
      var coords:Array = coordsStr.replace(
          /\(|\)| /g, '').split(',');
      var point:Point;
      if (isNaN(coords[0]) || isNaN(coords[1])) {
        throw new Error('Coordinates must be in format "(x, y)"');
      }
      else {
        coords[0] = parseInt(coords[0], 10);
        coords[1] = parseInt(coords[1], 10);
        point = new Point(coords[0], coords[1]);
      }
      return point;
    }

    public static function doubleClick(params:Object):void {
		//trace("repeat double click");
      var obj:* = FPLocator.lookupDisplayObject(params);
      
      //Figure out what kind of displayObj were dealing with
      var classInfo:XML = describeType(obj);
      classInfo =  describeType(obj);
      var objType:String = classInfo.@name.toString();

      function doTheDoubleClick(obj:*):void {
          // Give it focus
          Events.triggerFocusEvent(obj, FocusEvent.FOCUS_IN);
          // First click
          // Down, (TextEvent.LINK,) up, click
          Events.triggerMouseEvent(obj, MouseEvent.MOUSE_DOWN, {
              buttonDown: true });
          // If this is a link, do the TextEvent hokey-pokey
          // All events fire on the containing DisplayObject
          if ('link' in params) {
            var link:String = FPLocator.locateLinkHref(params.link,
              obj.htmlText);
            Events.triggerTextEvent(obj, TextEvent.LINK, {
                text: link });
          }
          Events.triggerMouseEvent(obj, MouseEvent.MOUSE_UP);
          Events.triggerMouseEvent(obj, MouseEvent.CLICK);
          // Second click
          // Down, (TextEvent.LINK,) up, double click
          Events.triggerMouseEvent(obj, MouseEvent.MOUSE_DOWN, {
              buttonDown: true });
          // TextEvent hokey-pokey, reprise
          if ('link' in params) {
            Events.triggerTextEvent(obj, TextEvent.LINK, {
                text: link });
          }
          Events.triggerMouseEvent(obj, MouseEvent.MOUSE_UP);
          Events.triggerMouseEvent(obj, MouseEvent.DOUBLE_CLICK);
      }

      //if we have an accordion
      if (objType.indexOf('Accordion') != -1){
        for(var i:int = 0; i < obj.numChildren; i++) {
          var atb:Object = obj.getHeaderAt(i) as Object;
          if (atb.label == params.label) {
            doTheDoubleClick(atb);
          }
        }
      }
      else { doTheDoubleClick(obj); }
    }

    public static function type(params:Object):void {
      // Look up the item to write to
      var obj:* = FPLocator.lookupDisplayObject(params);
      // Text to type out
      var str:String = params.text;
      // Char
      var currChar:String;
      // Char code
      var currCode:int;

      // Give the item focus
      Events.triggerFocusEvent(obj, FocusEvent.FOCUS_IN);
      // Clear out any value it previously had
      obj.text = '';

      // Write out the string, firing appropriate events as you go
      for (var i:int = 0; i < str.length; i++) {
        currChar = str.charAt(i);
        currCode = str.charCodeAt(i);
        // FIXME: In reality, capital letters / special chars
        // would be firing shift key events around these
        Events.triggerKeyboardEvent(obj, KeyboardEvent.KEY_DOWN, {
          charCode: currCode });
        // Append to the value
        obj.text += str.charAt(i);
        Events.triggerTextEvent(obj, TextEvent.TEXT_INPUT, {
            text: currChar });
        Events.triggerKeyboardEvent(obj, KeyboardEvent.KEY_UP, {
          charCode: currCode });
      }
    }

    public static function select(params:Object):void {
		
		  trace("sending");
      // Look up the item to write to
      var obj:* = FPLocator.lookupDisplayObject(params);
      var sel:* = obj.selectedItem;
	  
      var item:*;
      // Give the item focus
      Events.triggerFocusEvent(obj, FocusEvent.FOCUS_IN);
      // Set by index
      switch (true) {
        case ('index' in params):
          if (obj.selectedIndex != params.index) {
            Events.triggerListEvent(obj, ListEvent.CHANGE);
            obj.selectedIndex = params.index;
          }
          break;
        case ('label' in params):
        case ('text' in params):
          var targetLabel:String = params.label || params.text;
          // Can set a custom label field via labelField attr
          var labelField:String = obj.labelField ?
              obj.labelField : 'label';
          if (sel[labelField] != targetLabel) {
            Events.triggerListEvent(obj, ListEvent.CHANGE);
            for each (item in obj.dataProvider) {
              if (item[labelField] == targetLabel) {
                obj.selectedItem = item;
              }
            }
          }
          break;
        case ('data' in params):
        case ('value' in params):
          var targetData:String = params.data || params.value;
          if (sel.data != targetData) {
            Events.triggerListEvent(obj, ListEvent.CHANGE);
			
            for each (item in obj.dataProvider) {
              if (item.data == targetData) {
                obj.selectedItem = item;
              }
            }
          }
          break;
    		case ('indices' in params):
    			if (obj.selectedIndices != params.indices) {
    				Events.triggerListEvent(obj, ListEvent.CHANGE);
    				obj.selectedIndices = params.indices;
    			}
    			break;
    		case ('selectedItem' in params):
    			var found:Boolean=false;
			
    			for (var i:* in obj.dataProvider) {
    				found=true;
    				for (var v:* in params.selectedItem) {
    					// mx_internal_uid is the additional column added to dataProvider which is visible after some user interaction on the component
    					if(params.selectedItem[v]!=obj.dataProvider[i][v]&&v.indexOf('mx_internal_uid')==-1){
    						found=false;
    						break;
    					}
    				}
				
    				if (found){
    					//do the move
    					obj.validateNow();    
    					obj.selectedIndex=i;
    					obj.scrollToIndex(i);
    					obj.destroyItemEditor();
    					Events.triggerListEvent(obj, ListEvent.CHANGE);
    					break;
    				}
    		}
    			break;
        default:
          // Do nothing
        }
    }
	
	public static function sliderChange(params:Object):void{
		var obj:* = FPLocator.lookupDisplayObject(params);
		obj.value=params.value;
		Events.triggerSliderEvent(obj , 'change');
	}
	
	public static function dateChange(params:Object):void{
		var obj:* = FPLocator.lookupDisplayObject(params);
		trace('params.value' , params.value);
		var dat:Date=new Date(params.value);
		obj.selectedDate=dat;
		Events.triggerCalendarLayoutChangeEvent(obj , 'change');
	}
	
	public static function dgColumnStretch(params:Object):void{
		var obj:* = FPLocator.lookupDisplayObject(params);
		Events.triggerDataGridEvent(obj , DataGridEvent.COLUMN_STRETCH ,params);		
	}
	
	public static function dgItemEdit(params:Object):void{
		var obj:* = FPLocator.lookupDisplayObject(params);
		Events.triggerDataGridEvent(obj , DataGridEvent.ITEM_EDIT_END ,params); 
	}
	
	public static function dgSort(params:Object):void{
		var obj:*= FPLocator.lookupDisplayObject(params);
		Events.triggerDataGridEvent(obj , DataGridEvent.HEADER_RELEASE ,params);
	}
	
	public static function dgHeaderRelease(params:Object):void{
		var obj:*= FPLocator.lookupDisplayObject(params);
		Events.triggerDataGridEvent(obj , DataGridEvent.HEADER_RELEASE ,params);
	}
	
	public static function dgSortAscending(params:Object):void{
		var obj:*= FPLocator.lookupDisplayObject(params);
		params.params.dir=false;
		Events.triggerDataGridEvent(obj , FPDataGridEvent.SORT_ASCENDING ,params);
	}
	
	public static function dgSortDescending(params:Object):void{
		var obj:*= FPLocator.lookupDisplayObject(params);
		params.params.dir=true;
		Events.triggerDataGridEvent(obj , FPDataGridEvent.SORT_DESCENDING ,params);
	}
	
	FP::complete{
  	public static function adgItemOpen(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		Events.triggerAdvancedDataGridEvent(obj , AdvancedDataGridEvent.ITEM_OPENING ,params);
  	}
	}
	
	FP::complete{
  	public static function adgItemClose(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		Events.triggerAdvancedDataGridEvent(obj , AdvancedDataGridEvent.ITEM_OPENING ,params);
  	}
	}
	
	FP::complete{
  	public static function adgColumnStretch(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		Events.triggerAdvancedDataGridEvent(obj , AdvancedDataGridEvent.COLUMN_STRETCH ,params);
  	}
	}
	
	FP::complete{
  	public static function adgHeaderShift(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		Events.triggerIndexChangedEvent(obj , IndexChangedEvent.HEADER_SHIFT , params);
  	}
	}
	
	FP::complete{
  	public static function adgSort(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		Events.triggerAdvancedDataGridEvent(obj , AdvancedDataGridEvent.HEADER_RELEASE ,params);
  	}
	}
	
	FP::complete{
  	public static function adgHeaderRelease(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		Events.triggerAdvancedDataGridEvent(obj , AdvancedDataGridEvent.HEADER_RELEASE ,params);
  	}
	}
	
	FP::complete{
  	public static function adgSortAscending(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		params.params.dir=false;
  		Events.triggerAdvancedDataGridEvent(obj , FPAdvancedDataGridEvent.SORT_ASCENDING , params);
  	}
	}
	
	FP::complete{
  	public static function adgSortDescending(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		params.params.dir=true;
  		Events.triggerAdvancedDataGridEvent(obj , FPAdvancedDataGridEvent.SORT_ASCENDING , params);
  	}
	}
	
	FP::complete{
  	public static function adgItemEdit(params:Object):void{
  		var obj:*= FPLocator.lookupDisplayObject(params);
  		Events.triggerAdvancedDataGridEvent(obj , AdvancedDataGridEvent.ITEM_EDIT_END , params);			
  	}
	}
		
  public static function getTextValue(params:Object):String {
    // Look up the item where we want to get the property
      var obj:* = FPLocator.lookupDisplayObject(params);
      var attrs:Object=['htmlText', 'label'];
      var res:String = 'undefined';
      var attr:String;
      for each (attr in attrs){
          res = obj[attr];
          if (res != 'undefined'){
              break;
          }
      }
      return res;
    }
    
  public static function getPropertyValue(params:Object, opts:Object = null):String {
    // Look up the item where we want to get the property
      var obj:* = FPLocator.lookupDisplayObject(params);
      var attrName:String;
      var attrVal:String = 'undefined';
      if (opts){
          if (opts.attrName is String) {
          attrName = opts.attrName;
          attrVal = obj[attrName];
          }
      }
      else {
          if (params.attrName is String) {
          attrName = params.attrName;
          attrVal = obj[attrName];
          }
      }
      return String(attrVal);
    }
    
  public static function getObjectCoords(params:Object):String {
      // Look up the item which coords we want to get
      var obj:* = FPLocator.lookupDisplayObject(params);
      var destCoords:Point = new Point(0, 0);
      destCoords = obj.localToGlobal(destCoords);
      var coords:String = '(' + String(destCoords.x) + ',' + String(destCoords.y) + ')';
      return coords;
  }
  }
}

