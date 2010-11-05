package 
{
    
    import flash.display.DisplayObject;
    import flash.events.MouseEvent;
    
    import mx.containers.ControlBar;
    import mx.containers.Panel;
    import mx.containers.VBox;
    import mx.controls.Button;
    import mx.controls.Label;
    import mx.controls.Spacer;
    import mx.controls.TextInput;
    import mx.managers.PopUpManager;
    import mx.styles.StyleManager;

	public class GetDocumentName
	{
		private var panel:Panel;
		private var parent:DisplayObject;
		private var textInput:TextInput;	
		

        public function GetDocumentName(parent:DisplayObject) : void 
        {
        	var vb:VBox = new VBox();
        	vb.percentWidth = 100;
            var label:Label = new Label();
            var subHeader:Label = new Label();
            textInput = new TextInput();

            var cb:ControlBar = new ControlBar();
            cb.percentWidth = 100;
            var s:Spacer = new Spacer();
            var b1:Button = new Button();
            var b2:Button = new Button();

			this.parent = parent;

            s.width = 100;
            
            textInput.maxChars = 50;
            textInput.percentWidth = 100;
            textInput.automationName = "modalSaveCancelButton";

            b1.label = "Save";
            b1.addEventListener(MouseEvent.CLICK, setName);
            b1.automationName = "modalSaveSaveButton";
            b1.width = 80;
            b2.label = "Cancel";
            b2.automationName = "modalSaveCancelButton";
            b2.addEventListener(MouseEvent.CLICK, closePopUp);
            b2.width = 80;

            cb.addChild(s);
            cb.addChild(b2);
            cb.addChild(b1);

            label.text = "Project Name:";
            label.percentWidth = 100;

            subHeader.text = "Enter your project name, and then click Save.";
            subHeader.percentWidth = 100;


            vb.setStyle("paddingBottom", 5);
            vb.setStyle("paddingLeft", 5);
            vb.setStyle("paddingRight", 5);
            vb.setStyle("paddingTop", 5);
            vb.addChild(subHeader);
            vb.addChild(label);
            vb.addChild(textInput);
            
            panel = new Panel();
            panel.title = "Save Your Project";
            panel.width = 300;
            panel.height = 175;
            panel.addChild(vb);
            panel.addChild(cb);
            panel.automationName = "modalDialogSave";
        }

            private function setName(evt:MouseEvent):void 
            {                
                
                PopUpManager.removePopUp(panel);
            }

            private function closePopUp(evt:MouseEvent):void 
            {
                PopUpManager.removePopUp(panel);
            }

            public function ShowPopUp(defaultName:String="Untitled Project") : void 
            {
            	var projName:String;
            		
                PopUpManager.addPopUp(panel, parent, true);
                PopUpManager.centerPopUp(panel);
                this.textInput.text = defaultName;
                this.textInput.selectionBeginIndex = 0;
                this.textInput.selectionEndIndex = textInput.length;
                this.textInput.setFocus();
            }            		
	}
}