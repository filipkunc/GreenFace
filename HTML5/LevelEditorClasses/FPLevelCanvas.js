var oldCursor = null;
var isMiddleMouse = false;

function levelMouseDown(e)
{
    var cursor = getCursorPosition(levelCanvas.canvas, e);
    
    if (e.button == 1)
        isMiddleMouse = true;
    else
        isMiddleMouse = false;
        
    if (isMiddleMouse)
    {
        alignCursorOnGrid(cursor);
    } 
    else if (paletteCanvas.activeFactory != null)
    {
        alignCursorOnGrid(cursor);

        var beforeLength = levelCanvas.levelObjects.length;
        paletteCanvas.activeFactory.create(levelCanvas.levelObjects, cursor.x, cursor.y);
        levelCanvas.draggedObject = levelCanvas.levelObjects[beforeLength];
        levelCanvas.draw();
    }
    else
    {
        levelCanvas.draggedObject = levelCanvas.objectUnderMouse(cursor.x, cursor.y);
        if (levelCanvas.draggedObject == null)
        {
            levelCanvas.selectionStart = new FPPoint(cursor.x, cursor.y);
            levelCanvas.selectionEnd = new FPPoint(cursor.x, cursor.y);
        }
    }
    
    oldCursor = new FPPoint(cursor.x, cursor.y);
}

function alignCursorOnGrid(cursor)
{
    cursor.x -= 16.0;
    cursor.y -= 16.0;
    cursor.x = Math.round(cursor.x / 32.0) * 32.0;
    cursor.y = Math.round(cursor.y / 32.0) * 32.0;
}

function levelMouseMove(e)
{
    if (oldCursor == null)
        return;
    
    var cursor = getCursorPosition(levelCanvas.canvas, e);
    
    if (isMiddleMouse)
    {
       alignCursorOnGrid(cursor);
       levelCanvas.moveAll(cursor.x - oldCursor.x, cursor.y - oldCursor.y);
       oldCursor.x = cursor.x;
       oldCursor.y = cursor.y;
       levelCanvas.draw();
    }    
    else if (levelCanvas.selectionEnd != null)
    {    
        levelCanvas.selectionEnd = new FPPoint(cursor.x, cursor.y);
        levelCanvas.draw();
    }
    else if (levelCanvas.draggedObject != null)
    {
        alignCursorOnGrid(cursor);
        
        var widthSegments = Math.floor((cursor.x - oldCursor.x + 16.0) / 32.0);
        var heightSegments = Math.floor((cursor.y - oldCursor.y + 16.0) / 32.0);
        
        if (paletteCanvas.activeFactory != null)
        {
        	var draggedObjectLocation = new FPPoint(oldCursor.x, oldCursor.y);
        	if (widthSegments < 0)
        		draggedObjectLocation.x += widthSegments * 32.0;
        	if (heightSegments < 0)
        		draggedObjectLocation.y += heightSegments * 32.0;

        	widthSegments = Math.max(Math.abs(widthSegments), 1);
        	heightSegments = Math.max(Math.abs(heightSegments), 1);

            levelCanvas.draggedObject.x = draggedObjectLocation.x;
            levelCanvas.draggedObject.y = draggedObjectLocation.y;

            levelCanvas.draggedObject.widthSegments = widthSegments;
            levelCanvas.draggedObject.heightSegments = heightSegments;
        }
        else
        {
            widthSegments *= 32.0;
            heightSegments *= 32.0;
            
            levelCanvas.moveSelected(widthSegments, heightSegments);
            
            oldCursor.x += widthSegments;
            oldCursor.y += heightSegments;
        }

        levelCanvas.draw();
    }
}

function levelMouseUp(e)
{
    if (levelCanvas.selectionStart != null)
    {
        levelCanvas.selectObjects();
        
        levelCanvas.selectionStart = null;
        levelCanvas.selectionEnd = null;
    }
    
    levelCanvas.draggedObject = null;
    paletteCanvas.activeFactory = null;
    oldCursor = null;
    
    levelCanvas.draw();
    paletteCanvas.draw();
}

function FPLevelCanvas(canvasName)
{
    this.canvas = document.getElementById(canvasName);
    this.context = this.canvas.getContext('2d');
    
    this.canvas.width = document.width - 107;
    this.canvas.height = document.height - 4;
    
    this.levelObjects = new Array();
    
    this.draggedObject = null;
    
    this.selectionStart = null;
    this.selectionEnd = null;
    
    this.canvas.addEventListener('mousedown', levelMouseDown, false);
    this.canvas.addEventListener('mousemove', levelMouseMove, false);
    this.canvas.addEventListener('mouseup', levelMouseUp, false);
    
    this.drawGrid = function()
    {
        this.context.strokeStyle = "rgba(255,255,255, 0.2)";
        
        var rect = new FPRect(0, 0, this.canvas.width, this.canvas.height);
        
        for (var y = rect.origin.y; y < rect.size.height; y += 32)
    	{
    	    this.context.beginPath();
    	    this.context.moveTo(rect.origin.x, y);	
    	    this.context.lineTo(rect.size.width, y);
    	    this.context.stroke();
    	}

    	for (var x = rect.origin.x; x < rect.size.width; x += 32)
    	{
    	    this.context.beginPath();
    		this.context.moveTo(x, rect.origin.y);	
    		this.context.lineTo(x, rect.size.height);
    		this.context.stroke();
    	}
    }
    
    this.draw = function()
    {
        this.context.fillStyle = "rgb(55,60,89)";        
        this.context.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        this.drawGrid();
        
        for (i in this.levelObjects)
        {
            var levelObject = this.levelObjects[i];
            levelObject.draw(this.context);
            
            if (levelObject.selected)
            {
                var levelObjectRect = levelObject.rect();
                this.context.strokeStyle = "rgba(255,255,255, 1.0)";
                this.context.strokeRect(levelObjectRect.origin.x, levelObjectRect.origin.y, levelObjectRect.size.width, levelObjectRect.size.height);
            }           
        }
        
        if (this.selectionStart != null)
        {
            this.context.fillStyle = "rgba(255,255,255, 0.15)";
            this.context.strokeStyle = "rgba(255,255,255, 1.0)";
            
            var selectionRect = FPRectFromPoints(this.selectionStart, this.selectionEnd);
            
            this.context.fillRect(selectionRect.origin.x, selectionRect.origin.y, selectionRect.size.width, selectionRect.size.height);
            this.context.strokeRect(selectionRect.origin.x, selectionRect.origin.y, selectionRect.size.width, selectionRect.size.height);
        }
    }
    
    this.objectUnderMouse = function(x, y)
    {
        for (i in this.levelObjects)
        {
            var levelObject = this.levelObjects[i];
            
            if (levelObject.rect().containsPoint(x, y))
                return levelObject;
        }
        
        return null;
    }
    
    this.selectObjects = function()
    {
        var selectionRect = FPRectFromPoints(this.selectionStart, this.selectionEnd);
        
        for (i in this.levelObjects)
        {
            var levelObject = this.levelObjects[i];
            
            if (FPRectIntersectsRect(selectionRect, levelObject.rect()))
                levelObject.selected = true;                
            else
                levelObject.selected = false;
        }
    }
    
    this.moveSelected = function(offsetX, offsetY)
    {
        for (i in this.levelObjects)
        {
            var levelObject = this.levelObjects[i];
            if (levelObject.selected)
                levelObject.move(offsetX, offsetY);
        }        
    }
    
    this.moveAll = function(offsetX, offsetY)
    {
        for (i in this.levelObjects)
        {
            var levelObject = this.levelObjects[i];
            levelObject.move(offsetX, offsetY);
        }
    }
    
    this.deleteSelected = function()
    {
        this.levelObjects = this.levelObjects.filter(function (obj) { return !obj.selected; });
        this.draw();
    }
}