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

package {
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.SecurityDomain;
	import flash.system.LoaderContext;
	import flash.display.LoaderInfo;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.StyleSheet;
	import flash.utils.*;
  import util.DOMEventDrag;
  import org.windmill.WMBootstrap;

	[SWF(width="400",height="400",frameRate="30",backgroundColor="#FFFFFF")]

  public class WMDemo extends MovieClip {
    private var spriteVert:int = 20;
    private var assetList:Object = {
      clamwich: {
        name: 'Clamwich',
        y: 20
      },
      bat_punch: {
        name: 'Bat Punch',
        y: 100
      },
      cloud_candy: {
        name: 'Cloud Candy',
        y: 180
      },
      crab_apple: {
        name: 'Crab Apple',
        y: 260
      }
    };
    private var dragged:Sprite;

    public function WMDemo():void {
      var createLoadFunc:Function = function (k:String):Function {
        return function (res:Event):void {
          handleLoadAsset(k, res);
        }
      }

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
      var item:Object;
      for (var key:String in assetList) {
        item = assetList[key];
        loadAsset('/images/sp_gift_' + key + '.png', createLoadFunc(key));
      }
      stage.addEventListener(MouseEvent.MOUSE_UP, endDrag);
      addDragTarget();
      WMBootstrap.init(stage);
    }

		// Generic loader function -- takes a handler func for
		// loader completion, and an optional handler for loading
		// progress
		private function loadAsset(url:String,
			complete:Function, progress:Function = null):void {
			var loader:Loader = new Loader();
			var req:URLRequest = new URLRequest(url);
			var con:LoaderContext = new LoaderContext(false,
				ApplicationDomain.currentDomain,
				SecurityDomain.currentDomain);
			// FIXME: Need a nicer error message for when loading breaks
			loader.contentLoaderInfo.addEventListener(
				IOErrorEvent.IO_ERROR, function ():void { trace('could not load ' + url); });
			loader.contentLoaderInfo.addEventListener(
				Event.COMPLETE, complete, false, 0, true);
			// If a progress func is defined, pass it the ProgressEvent
			if (progress is Function) {
				loader.contentLoaderInfo.addEventListener(
				ProgressEvent.PROGRESS, progress, false, 0, true);
			}
			// Doo eeet!
			loader.load(req, con);
		}

		private function getLoaderContent(e:Event):* {
			var li:LoaderInfo = e.target as LoaderInfo;
			return li.loader.content;
		}

		// Add the background once it loads
		private function handleLoadAsset(key:String, e:Event):void {
			var result:* = getLoaderContent(e);
      var container:Automatable = new Automatable();
			container.addChild(result);
      container.x = 20;
      var yPos:int = assetList[key].y;
      container.y = yPos
      container.buttonMode = true;
      container.automationName = key + 'Sprite'
      container.addEventListener(MouseEvent.MOUSE_DOWN, beginDrag);
      addChild(container);

		}

		private function addDragTarget():void {
      var spr:Automatable = new Automatable();
      spr.automationName = 'targetSprite';
      spr.graphics.clear()
      spr.graphics.beginFill(0xDDDDDD);
      spr.graphics.drawRect(0,0,100,100);
      spr.x = 300;
      spr.y = 150
      addChild(spr);
    }

    private function beginDrag(e:MouseEvent):void {
      //if (e.target.name == 'dragSprite') {
        var targ:Sprite = e.target as Sprite;
        dragged = targ;
        DOMEventDrag.startDrag(targ);
      //}
    }
    private function endDrag(e:MouseEvent):void {
      if (dragged) {
        DOMEventDrag.stopDrag(dragged);
      }
    }

  }
}

import flash.display.Sprite;
class Automatable extends Sprite {
  public var automationName:String;
}
