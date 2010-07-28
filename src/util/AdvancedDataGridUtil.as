package util
{
	import flash.utils.describeType;
	import flash.utils.setTimeout;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.AdvancedDataGrid;
	import mx.controls.AdvancedDataGridBaseEx;
	import mx.controls.DataGrid;
	import mx.controls.Text;
	import mx.controls.TextInput;
	import mx.controls.advancedDataGridClasses.AdvancedDataGridListData;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.core.IPropertyChangeNotifier;
	import mx.events.AdvancedDataGridEvent;

	public class AdvancedDataGridUtil
	{
		public function AdvancedDataGridUtil()
		{
		}
		
		
		public static function columnStretch(obj:* , columnIndex:Number , localX:Number):void{
			
			var colArray:Array=obj.columns;
			
			if(columnIndex<colArray.length){
				var newWidth:Number=localX-prewidth(colArray , columnIndex);
				colArray[columnIndex].width=newWidth;
			}
			else{
				throw new Error("Incorrect columnIndex recieved");
			}
			
			
			
			
			
			
			
		}
		
		private static function prewidth(colArray:* , columnIndex:Number):Number{
			var sum:Number=0;
			for(var i:Number=0 ; i<columnIndex ; i++){
				sum+=colArray[i].width;
			}
			
			return sum;
		}
		
		public static function sortGridOrder(obj:* , index:Number , descending:Boolean=false , caseSensitive:Boolean=false ):void{
			
			var srt:Sort=new Sort();
			var oldSort:Sort=obj.dataProvider.sort;
			var column:* = obj.columns[index];
			var sf:SortField;
			if(oldSort){
				srt.fields=oldSort.fields;
				sf = new SortField(column.dataField  , caseSensitive , descending );
				srt.fields.splice( 0 , 0 , sf);
				
			}
			else{
				
				sf = new SortField(column.dataField  , caseSensitive , descending );
				
				srt.fields=[sf];
				
			}
			
			obj.dataProvider.sort = srt;
			obj.dataProvider.refresh();
			
			
			
		}
		
		
		public static  function adgSort(obj:* , index:Number , caseSensitive:Boolean=false):void{
			
			var val:Boolean=true;
				var sort:Sort=obj.dataProvider.sort;
				var fields:Array=sort.fields;
				
				for(var i:Number=0 ; i<fields.length ; i++){
					if(fields[i].name==obj.columns[index].dataField)
					{
					val=!fields[i].descending;
					}
				}
			obj.dataProvider.sort.fields=[new SortField(obj.columns[index].dataField , caseSensitive , val)];
			obj.dataProvider.refresh();
			
	}
		
		public static function itemEdit(obj:* , row:Number ,column:Number , newData:*):void{
			 
			
			
			
			//obj.createItemEditor(columnIndex , rowIndex);
			
			
			obj.editedItemPosition={rowIndex: row  , columnIndex: column };
			
			
			trace(obj.itemEditorInstance , obj.editedItemRenderer);
			
			
			setTimeout(function():void{
				
				trace(obj.itemEditorInstance , obj.editedItemRenderer);
				
				TextInput(obj.itemEditorInstance).text=newData;
				
				var property:String = obj.columns[column].dataField;
				var data:Object = obj.itemEditorInstance.data;
				var typeInfo:String = "";
				var bChanged:Boolean=false;
				
				
				for each(var variable:XML in describeType(data).variable)
				{
					if (property == variable.@name.toString())
					{
						typeInfo = variable.@type.toString();
						break;
					}
				}
				
				if (typeInfo == "String")
				{
					if (!(newData is String))
						newData = newData.toString();
				}
				else if (typeInfo == "uint")
				{
					if (!(newData is uint))
						newData = uint(newData);
				}
				else if (typeInfo == "int")
				{
					if (!(newData is int))
						newData = int(newData);
				}
				else if (typeInfo == "Number")
				{
					if (!(newData is int))
						newData = Number(newData);
				}
				if (data[property] != newData)
				{
					bChanged = true;
					data[property] = newData;
				}
				if (bChanged && !(data is IPropertyChangeNotifier))
				{
					obj.dataProvider.itemUpdated(data, property);
				}
				
				
				
				if (obj.itemEditorInstance is IDropInListItemRenderer)
				{
					var listData:AdvancedDataGridListData = AdvancedDataGridListData(IDropInListItemRenderer(obj.itemEditorInstance).listData);
					listData.label = obj.columns[column].itemToLabel(data);
					IDropInListItemRenderer(obj.itemEditorInstance
					).listData = listData;
				}
				obj.itemEditorInstance.data = data;
				
				obj.destroyItemEditor();
				
				
			}  , 50);
			

			
		}
		
		
		
		
		
		
}
	
}