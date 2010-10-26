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
  import flash.display.DisplayObject;
  import flash.display.DisplayObjectContainer;
  import flash.display.InteractiveObject;
  import flash.display.Stage;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.TextEvent;
  import flash.external.ExternalInterface;
  import flash.text.StaticText;
  import flash.utils.*;
  
  import mx.controls.ComboBox;
  import mx.controls.DataGrid;
  import mx.controls.DateChooser;
  import mx.controls.DateField;
  import mx.controls.List;
  import mx.controls.dataGridClasses.DataGridBase;
  import mx.controls.listClasses.ListBase;
  import mx.controls.sliderClasses.Slider;
  import mx.core.UIComponent;
  import mx.events.CalendarLayoutChangeEvent;
  import mx.events.DataGridEvent;
  import mx.events.DragEvent;
  import mx.events.IndexChangedEvent;
  import mx.events.ListEvent;
  import mx.events.SliderEvent;
  
  import org.flex_pilot.FPExplorer;
  import org.flex_pilot.FPLocator;
  import org.flex_pilot.FPLogger;
  import org.flex_pilot.FlexPilot;
  
  FP::complete {
    import mx.events.AdvancedDataGridEvent;
    import mx.controls.listClasses.AdvancedListBase;
    import mx.controls.advancedDataGridClasses.AdvancedDataGridBase;
    import mx.controls.AdvancedDataGrid;
    import mx.controls.AdvancedDataGridBaseEx;
  }

  public class FPRecorder {
   
  // Remember the last event type so we know when to
  // output the stored string from a sequence of keyDown events
  private static var lastEventType:String;
  private static var lastEventLocator:String;

  //just to hide the mouse clicks occured while the user is changing the date or value of slider .
  private static var noClickTime:Boolean=false;
  private static var noClick:*;
  
  // Remember recent target -- used to detect double-click
  // and to throw away click events on text items that have
  // already spawned a 'link' TextEvent.
  // Only remembered for one second
  private static var recentTarget:Object = {
    click: null,
    change: null,
    sliderChange: null
  };
  
  // Timeout id for removing the recentTarget
  private static var recentTargetTimeout:Object = {
    click: null,
    change: null,
    sliderChange: null,
    dateChange: null
  };
  
  // String built from a sequenece of keyDown events
  private static var keyDownString:String = '';
   /* private static var listItems:Array = [];
  private static var dateItems:Array=[];
  private static var dgItems:Array=[];
  private static var adgItems:Array=[];
  private static var adgBaseExItems:Array=[];
  private static var uicItems:Array=[];
  private static var sliderItems:Array=[];*/
 
  private static var running:Boolean = false;
  
  // just in case u want to record for clicks placed while you are 
  //performing other user actities  Ex. recording of clicks while selecting an item from a list
  public static var recordExtraClicks:Boolean=false;
  private static var draggerParams:Object;
  public static var test:Object;
  public static var typesAllowed:Array;
  private static var runBefore:Boolean=false;
 
   // maps some of the flex4 components to the existing flex3 component
   private static var componentMap:Array=[];
   private static var eventMap:Array=[];
 
   typesAllowed=[
    {'item':Slider , 'itemList':[] , 'eventType':['change']} , 
    {'item':ListBase , 'itemList':[] , 'eventType':['change']} ,
    {'item':ComboBox , 'itemList':[] , 'eventType':['change']} ,
    {'item':DateChooser , 'itemList':[] , 'eventType':['change']} ,
    {'item':DateField , 'itemList':[] , 'eventType':['change']} ,
    {'item':DataGrid , 'itemList':[] , 'eventType':['columnStretch' , 'headerRelease' , 'itemEditEnd']} ,
    {'item':UIComponent , 'itemList':[] , 'eventType':['dragStart' , 'dragDrop']} ,
   ];
  
  FP::complete  {
    typesAllowed=[
     {'item':Slider , 'itemList':[] , 'eventType':['change']} , 
     {'item':ListBase , 'itemList':[] , 'eventType':['change']} ,
     {'item':ComboBox , 'itemList':[] , 'eventType':['change']} ,
     {'item':DateChooser , 'itemList':[] , 'eventType':['change']} ,
     {'item':DateField , 'itemList':[] , 'eventType':['change']} ,
     {'item':DataGrid , 'itemList':[] , 'eventType':['columnStretch' , 'headerRelease' , 'itemEditEnd']} ,
     {'item':UIComponent , 'itemList':[] , 'eventType':['dragStart' , 'dragDrop']} ,
     {'item':AdvancedListBase , 'itemList':[] , 'eventType':['change' , 'dragStart' , 'dragDrop']} ,
     {'item':AdvancedDataGridBaseEx , 'itemList':[] , 'eventType':['columnStretch' , 'headerRelease' , 'itemEditEnd']} ,
     {'item':AdvancedDataGrid , 'itemList':[] , 'eventType':['itemOpen' , 'itemClose']} 
    ];
  }

  private static var typesAllowedObj:Object={};
  public function FPRecorder():void {}
  public static function start():void {
    // Stop the explorer if it's going
    FPExplorer.stop();
    if (!runBefore) {
      makeFlex4Compatible();
    }
   
    var recurseAttach:Function = function (item:*):void {
      // Otherwise recursively check the next link in
      // the locator chain
      var count:int = 0;
      var i:Number=0;
      var arr:Array;
    
      for each(var elem:* in typesAllowed) {
       if (item is elem.item) {
        elem.itemList.push(item);
        for each(var eventType:* in elem.eventType){
         item.addEventListener(eventType , FPRecorder.handleEvent);
        }
       }
      }
      if (item is DisplayObjectContainer) {
        count = item.numChildren;
      }
      if (count > 0) {
        var index:int = 0;
        while (index < count) {
          var kid:DisplayObject = item.getChildAt(index);
          var res:DisplayObject = recurseAttach(kid);
          index++;
        }
      }
    }
    recurseAttach(FlexPilot.getContext());
    var stage:Stage = FlexPilot.getStage();
    stage.addEventListener(MouseEvent.CLICK, FPRecorder.handleEvent);
    stage.addEventListener(MouseEvent.DOUBLE_CLICK, FPRecorder.handleEvent);
    stage.addEventListener(TextEvent.LINK, FPRecorder.handleEvent);
    stage.addEventListener(KeyboardEvent.KEY_DOWN, FPRecorder.handleEvent);
    
    FPRecorder.running = true;
  }

  public static function stop():void {
    if (!FPRecorder.running) { return; }
    var stage:Stage = FlexPilot.getStage();
    stage.removeEventListener(MouseEvent.CLICK, FPRecorder.handleEvent);
    stage.removeEventListener(MouseEvent.DOUBLE_CLICK, FPRecorder.handleEvent);
    stage.removeEventListener(TextEvent.LINK, FPRecorder.handleEvent);
    stage.removeEventListener(KeyboardEvent.KEY_DOWN, FPRecorder.handleEvent);
   
   for each( var elem:* in typesAllowed) {
    while(elem.itemList.length){
     var item:*=elem.itemList.pop();
     for each(var eventType:* in elem.eventType) {
      item.removeEventListener(eventType , FPRecorder.handleEvent);
     }
    }
   }
  }
 
 private static function makeFlex4Compatible():void{
  runBefore=true;
  
  //var regx:RegExp=new RegExp('\\[class (.*)\\]');  
  // [only few of the components have been put into spark.components and so will load them directly]
  // combobox , listbase , Hslider , vslider  ,  
  
  try {
    var flex4ComboBox:*=getDefinitionByName('spark.components.ComboBox');
    typesAllowed.push({'item':flex4ComboBox , 'itemList':[] , 'eventType':['change']});
    componentMap[ComboBox]=flex4ComboBox;
  }
  catch(e:Error) {}
  try {
   var flex4SliderBase:*=getDefinitionByName('spark.components.supportClasses.SliderBase');
   typesAllowed.push({'item':flex4SliderBase , 'itemList':[] , 'eventType':['change']});
   componentMap[Slider]=flex4SliderBase;
  }
  catch(e:Error) {}
  try {
   var flex4ListBase:*=getDefinitionByName('spark.components.supportClasses.ListBase');
   typesAllowed.push({'item':flex4ListBase , 'itemList':[] , 'eventType':['change']});
   componentMap[ListBase]=flex4ListBase;
  }
  catch(e:Error) {}
  
  try {
    // similar mapping can be done in future depending on the component usage
    componentMap[List]=getDefinitionByName('spark.components.List');
    eventMap[IndexChangedEvent]=getDefinitionByName('spark.events.IndexChangeEvent');
  }
  catch(e:Error){}
 }

  public static function handleEvent(e:*):void {
    var targ:* = e.target;
    var _this:* = FPRecorder;
    var chain:String=FPLocator.generateLocator(targ);
    var opts:Object;
    var condTest:Boolean=true;
  
    FP::complete  {
      switch(true) {
        case (e is AdvancedDataGridEvent &&  e.type==AdvancedDataGridEvent.ITEM_OPEN) :
          condTest=false;
          opts = new Object;
          opts.item=e.item;
          opts.opening=true;
          opts.bubbles=e.bubbles;
          opts.cancelable=e.cancelable;
          _this.generateAction('adgItemOpen', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is AdvancedDataGridEvent && e.type==AdvancedDataGridEvent.ITEM_CLOSE) :
          condTest=false;
          opts = new Object;
          opts.item=e.item;
          opts.opening=false;
          opts.bubbles=e.bubbles;
          opts.cancelable=e.cancelable; 
          _this.generateAction('adgItemClose', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is AdvancedDataGridEvent && e.type==AdvancedDataGridEvent.COLUMN_STRETCH) :
          condTest=false;
          opts=new Object;
          opts.bubbles=e.bubbles;
          opts.cancelable=e.cancelable;
          opts.localX=Number(e.localX);
          opts.columnIndex=e.columnIndex;
          opts.dataField=e.dataField;
          opts.rowIndex=e.rowIndex;
          _this.generateAction('adgColumnStretch', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is AdvancedDataGridEvent && e.type==AdvancedDataGridEvent.HEADER_RELEASE) :
          condTest=false;
          opts = new Object;
          opts.bubbles=e.bubbles;
          opts.cancelable=e.cancelable;
          opts.columnIndex = e.columnIndex;
          opts.dataField= e.dataField;
          opts.removeColumnFromSort=e.removeColumnFromSort;
          _this.generateAction('adgHeaderRelease', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is AdvancedDataGridEvent && e.type==AdvancedDataGridEvent.ITEM_EDIT_END) :
          condTest=false;
          opts = new Object;
          opts.bubbles=e.bubbles;
          opts.cancelable=e.cancelable;
          opts.columnIndex = e.columnIndex;
          opts.rowIndex=e.rowIndex;
          opts.dataField= e.dataField;
          opts.reason=e.reason;
          opts.newValue=e.target.itemEditorInstance[e.target.columns[e.columnIndex].editorDataField];
          _this.generateAction('adgItemEdit', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is IndexChangedEvent && e.type==IndexChangedEvent.HEADER_SHIFT) :
          condTest=false;
          opts = new Object;
        
          opts.newIndex=e.newIndex;
          opts.oldIndex=e.oldIndex;
          opts.bubbles=e.bubbles;
          opts.cancelable=e.cancelable;
          _this.generateAction('adgHeaderShift', targ , opts);
          _this.setNoClickZone();
          break;
      
        case (((e is ListEvent 
          || e is IndexChangedEvent 
          || e is eventMap[IndexChangedEvent]) 
          && ( targ is ComboBox 
            || targ is componentMap[ComboBox] 
            || targ is ListBase 
            || targ is componentMap[ListBase] 
            || targ is AdvancedListBase) ) 
          && e.type==ListEvent.CHANGE) :
            
          condTest=false;
          _this.generateAction('select', targ);
          _this.resetRecentTarget('change', e);
          break;
      }
    }
  
    if (condTest) {
      switch (true) {
        case (e is SliderEvent && e.type==SliderEvent.CHANGE) :
          _this.generateAction('sliderChange',targ);
          _this.setNoClickZone();
          break;
        case (e is CalendarLayoutChangeEvent && e.type==CalendarLayoutChangeEvent.CHANGE) :
          _this.generateAction('dateChange',targ);
          _this.setNoClickZone();
          break;
        // ComboBox changes
        case (e is DataGridEvent && e.type==DataGridEvent.COLUMN_STRETCH ) :
          opts=new Object;
          opts.localX=Number(e.localX);
          opts.columnIndex=e.columnIndex;
          opts.rowIndex=e.rowIndex;
          _this.generateAction('dgColumnStretch', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is DataGridEvent && e.type==DataGridEvent.HEADER_RELEASE) :    
          //storing some of the values from event and to remain on the safe 
          //side if event had been custom generated . . .
          opts=new Object;
          opts.columnIndex=e.columnIndex;
          opts.dataField=e.dataField;
          opts.rowIndex=e.rowIndex;
          opts.reason=e.reason;
          opts.cancelable=e.cancelable;
          opts.sortDescending=targ.columns[e.columnIndex].sortDescending;
          _this.generateAction('dgHeaderRelease' , targ , opts);
          _this.setNoClickZone();
          break;

        case (e is DataGridEvent && e.type==DataGridEvent.ITEM_EDIT_END) :
          opts=new Object;
          opts.newValue=e.target.itemEditorInstance[e.target.columns[e.columnIndex].editorDataField];
        
          opts.dataField=e.dataField;
          opts.rowIndex=e.rowIndex;
        
          opts.reason=e.reason;
          opts.cancelable=e.cancelable;
          _this.generateAction('dgItemEdit', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is DragEvent && e.type==DragEvent.DRAG_START) :
          opts={
            bubbles : e.bubbles ,
            cancelable : e.cancelable ,
            action : e.action ,
            altKey : e.altKey ,
            shiftKey : e.shiftKey ,
            ctrlKey : e.ctrlKey  , 
            stageX : e.stageX ,
            stageY : e.stageY ,
            localX : e.localX ,
            localY : e.localY ,
            selectedIndices : targ.selectedIndices 
          };
          _this.generateAction('dragStart', targ , opts);
          _this.setNoClickZone();
          break;
        case (e is DragEvent && e.type==DragEvent.DRAG_DROP) :
          opts={
            bubbles : e.bubbles ,
            cancelable : e.cancelable ,
            action : e.action ,
            altKey : e.altKey ,
            shiftKey : e.shiftKey ,
            ctrlKey : e.ctrlKey  , 
            stageX : e.stageX ,
            stageY : e.stageY ,
            localX : e.localX ,
            localY : e.localY
          };
          _this.generateAction('itemDragDrop', targ , opts);      
          break;
        case (((e is ListEvent 
        || e is IndexChangedEvent)
        && ( targ is ComboBox 
          || targ is componentMap[ComboBox] 
          || targ is ListBase 
          || targ is componentMap[ListBase]) ) 
          && e.type==ListEvent.CHANGE) :
     
          _this.generateAction('select', targ);
          _this.resetRecentTarget('change', e);
          break;
    
        case (e is KeyboardEvent && e.type==KeyboardEvent.KEY_DOWN) :
          // If we don't ignore 0 we get a translation error
          // as it generates a non unicode character
          if (e.charCode != 0) {
          _this.keyDownString += String.fromCharCode(e.charCode);
          }
          break;
        // Mouse/URL clicks
        default:
          // If the last event was a keyDown, write out the string
          // that's been saved from the sequence of keyboard events
          if (_this.lastEventType == KeyboardEvent.KEY_DOWN) {
            var locate:* = targ;
            //If we have a prebuild last locator, use it
            //Since the current isn't actually the node we want
            //it's the following node that generated the onchange
            if (_this.lastEventLocator) {
              locate = _this.lastEventLocator;
            }
            _this.generateAction('type', locate, { text: _this.keyDownString });
            // Empty out string storage
            _this.keyDownString = '';
          }
          // Ignore clicks on ComboBox/List items that result
          // in ListEvent.CHANGE events -- the list gets blown
          // away, and can't be looked up by the generated locator
          // anyway, so we have to use this event instead
          /*else if (_this.lastEventType == ListEvent.CHANGE) {
            if (_this.recentTarget.change && (_this.recentTarget is List || targ is componentMap[List])) {
              return;
            }
            else if (_this.recentTarget.sliderChange  && _this.recentTarget is Slider) {
              return;
            }
          }*/
        
        // Avoid multiple clicks on the same target
        if (_this.recentTarget == e.target) {
          // Check for previous TextEvent.LINK
          if (_this.lastEventType != MouseEvent.DOUBLE_CLICK) {
            // Just throw this mofo away
            return;
          }
        }
      
        var t:String = e.type == MouseEvent.DOUBLE_CLICK ?
          'doubleClick' : 'click';
        
        if (!_this.noClickTime) {
          _this.generateAction(t, targ);
          _this.resetRecentTarget('click', e);
        }
      }

      // Remember the last event type for saving sequences of
      // keyboard events
      _this.lastEventType = e.type;
      _this.lastEventLocator = FPLocator.generateLocator(targ);

      //FPLogger.log(e.toString());
      //FPLogger.log(e.target.toString());
    }
    }
    
    private static function resetRecentTarget(t:String, e:*):void {
    var _this:* = FPRecorder;
    // Remember this target, avoid multiple clicks on it
    _this.recentTarget[t] = e.target;
    // Cancel any old setTimeout still hanging around
    if (_this.recentTargetTimeout[t]) {
      clearTimeout(_this.recentTargetTimeout[t]);
    }
    // Clear the recentTarget after 1 sec.
    _this.recentTargetTimeout[t] = setTimeout(function ():void {
      _this.recentTarget[t] = null;
      _this.recentTargetTimeout[t] = null;
      }, 1);
    }
  
    private static function setNoClickZone():void {
      var _this:* = FPRecorder;
    
      if (!FPRecorder.recordExtraClicks) {
      if (_this.noClick) {
        clearTimeout(_this.noClick);
      }
      _this.noClickTime=true;
      _this.noClick=setTimeout(function():void {
        _this.noClickTime=false;
      }, 5);
      }
    }

    private static function generateAction(t:String, targ:*,
      opts:Object = null):void {
      var trybool:Boolean=false;
      var chain:String;
      //Type actions send an already build locator string
      if (typeof(targ) == 'object') {
        chain = FPLocator.generateLocator(targ);
      }
      else { chain = targ; }

      //Figure out what kind of displayObj were dealing with
      var classInfo:XML = describeType(targ);
      classInfo =  describeType(targ);
      var objType:String = classInfo.@name.toString();

      var res:Object = {
        method: t,
        chain: chain
      };
      var params:Object = {};

      //if we have a flex accordion
      if (objType.indexOf('Accordion') != -1) {
        if (objType.indexOf('AccordionHeader') != -1) {
          params.label = targ.label;
        }
        else {
          params.label = targ.getHeaderAt(0).label;
        }
      }

      var p:String;
      for (p in opts) {
        params[p] = opts[p]
      }
    
      switch (t) {
        case 'click':
          break;
        case 'doubleClick':
          break;
        case 'select':
        var isSelectedItems:Boolean=false;
        var sel:*;
    
        // In case of components like ComboBox(in Flex3) property selectedItems 
        // is not present but is there in case of other List based components and in flex4 combobox .
        if ('selectedItems' in targ) {
         isSelectedItems=true;
         sel=targ.selectedItems;
         res.selectedItems=sel;
        }
        else {
         sel=targ.selectedItem;
         res.selectedItem=sel;
        }
    
        // If labelField is not equal to 'label' then the item to be 
        // selected is compared with data in labelField property .
        var labelField:* = targ.labelField ? targ.labelField : 'label';
        params.labelField=labelField;
        
          break;
        case 'type':
          break;
        case 'sliderChange':
          params.value=targ.value;
          break;
        case 'dateChange':
          params.value=targ.selectedDate.time;
          break;
        case 'itemDragDrop' :
          // storing the information about the start of drag . . .
          res.start=draggerParams;
          break;
      }
    
      for (p in params) {     
        res.params = params;
        break;
      }
    
      if (t=='dragStart') {     
        //  draggerParams is set with the value representing the state during the start of drag 
        //  draggerParams will be used later with the dispatch of event DragEvent.DRAG_DROP
        draggerParams=res;
        return;
      }
    
      if (t=='itemDragDrop') {
        test=res;
      }

      if (t=='select'){
        test=res;
      }
      
      var r:* = ExternalInterface.call('fp_recorderAction', res);
      if (!r) {
        FPLogger.log(res);
        FPLogger.log('(FlexPilot Flash bridge not found.)');
      }
    }
  }
}
