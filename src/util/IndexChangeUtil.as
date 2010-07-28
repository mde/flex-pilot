package util
{
	
	public class IndexChangeUtil
	{
		public function IndexChangeUtil()
		{
		}
		
		public static function headerShift(obj:* , oldIndex:Number , newIndex:Number):void{
			
			var columns:* = obj.columns;
			var col:* = columns[oldIndex];
			columns[oldIndex]=columns[newIndex];
			columns[newIndex]=col;
			
			obj.columns=columns;
			
			
		}
	}
}