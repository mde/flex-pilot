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

  public class FPStrip {
    public static function strip(html:String, tags:String = ""):String {
      var tagsToBeKept:Array = new Array();
      if (tags.length > 0)
          tagsToBeKept = tags.split(new RegExp("\\s*,\\s*"));
   
      var tagsToKeep:Array = new Array();
      for (var i:int = 0; i < tagsToBeKept.length; i++){
          if (tagsToBeKept[i] != null && tagsToBeKept[i] != "")
              tagsToKeep.push(tagsToBeKept[i]);
      }
   
      var toBeRemoved:Array = new Array();
      var tagRegExp:RegExp = new RegExp("<([^>\\s]+)(\\s[^>]+)*>", "g");
   
      var foundedStrings:Array = html.match(tagRegExp);
      for (i = 0; i < foundedStrings.length; i++) {
          var tagFlag:Boolean = false;
          if (tagsToKeep != null) {
              for (var j:int = 0; j < tagsToKeep.length; j++){
                  var tmpRegExp:RegExp = new RegExp("<\/?" + tagsToKeep[j] + "( [^<>]*)*>", "i");
                  var tmpStr:String = foundedStrings[i] as String;
                  if (tmpStr.search(tmpRegExp) != -1) 
                      tagFlag = true;
              }
          }
          if (!tagFlag)
              toBeRemoved.push(foundedStrings[i]);
      }
      for (i = 0; i < toBeRemoved.length; i++) {
          var tmpRE:RegExp = new RegExp("([\+\*\$\/])","g");
          var tmpRemRE:RegExp = new RegExp((toBeRemoved[i] as String).replace(tmpRE, "\\$1"),"g");
          html = html.replace(tmpRemRE, "");
      } 
      return html; 
    }
  }
}
