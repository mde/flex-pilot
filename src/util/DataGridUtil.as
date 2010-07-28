package util
{
	import mx.collections.ICollectionView;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.DataGrid;
	import mx.controls.TextInput;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.controls.listClasses.IDropInListItemRenderer;
	import mx.events.FlexEvent;
	import mx.events.IndexChangedEvent;
	

	public class DataGridUtil
	{
		public function DataGridUtil()
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
		
		public static function itemEdit(obj:* , row:Number,column:Number , field:* , newValue:*):void{
			
			obj.dataProvider.getItemAt(row)[field]=newValue;
						
			obj.dataProvider.itemUpdated(obj.dataProvider.getItemAt(row));
			
			
			
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
		
		public static  function dgSort(obj:* , index:Number , caseSensitive:Boolean=false):void{
			
			var val:Boolean=true;
			var sort:Sort=obj.dataProvider.sort;
			
			if(sort){
				
			
			var fields:Array=sort.fields;
			
			
			
			for(var i:Number=0 ; i<fields.length ; i++){
				if(fields[i].name==obj.columns[index].dataField)
				{
					val=!fields[i].descending;
				}
			}
			
			
			}
			else{
				obj.dataProvider.sort=new Sort;
				val=true;

			}
			
			
			obj.dataProvider.sort.fields=[new SortField(obj.columns[index].dataField , caseSensitive , val)];
			obj.dataProvider.refresh();
			
		}
			
		
				
			
			
			
			
			
			
			
			
		}
		
		
	}
