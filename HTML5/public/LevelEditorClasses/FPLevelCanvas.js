var oldCursor = null;
var isMiddleMouse = false;
var isDown = false;

const FPDragHandleNone = 0;
const FPDragHandleTopLeft = 1;
const FPDragHandleBottomLeft = 2;
const FPDragHandleTopRight = 3;
const FPDragHandleBottomRight = 4;
const FPDragHandleMiddleLeft = 5;
const FPDragHandleMiddleTop = 6;
const FPDragHandleMiddleRight = 7;
const FPDragHandleMiddleBottom = 8;

function levelMouseDown(e)
{
    isDown = true;
    
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
    else if (levelCanvas.currentHandle == FPDragHandleNone)
    {
        levelCanvas.draggedObject = levelCanvas.objectUnderMouse(cursor.x, cursor.y);
        if (levelCanvas.draggedObject == null)
        {
            levelCanvas.selectionStart = new FPPoint(cursor.x, cursor.y);
            levelCanvas.selectionEnd = new FPPoint(cursor.x, cursor.y);
        }
        else if (!levelCanvas.draggedObject.selected)
        {
            levelCanvas.deselectAll();
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
    var cursor = getCursorPosition(levelCanvas.canvas, e);
    
    if (!isDown)
    {
        if (levelCanvas.draggedObject != null)
        {
            var draggedObjectRect = levelCanvas.draggedObject.rect();
            var handleRect = new FPRect(0.0, 0.0, 14.0, 14.0);
            
            levelCanvas.currentHandle = FPDragHandleNone;
        
            for (var handle = FPDragHandleTopLeft; handle <= FPDragHandleMiddleBottom; handle++)
            {
    			var handlePoint = levelCanvas.pointFromHandle(handle, draggedObjectRect);

    			handleRect.origin.x = handlePoint.x - handleRect.size.width / 2.0;
    			handleRect.origin.y = handlePoint.y - handleRect.size.height / 2.0;

    			if (handleRect.containsPoint(cursor.x, cursor.y))
    			{
    				levelCanvas.currentHandle = handle;
    				break;			
    			}
    		}
    		
    		levelCanvas.draw();
	    }
        
        return;
    }
    
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
        else if (levelCanvas.currentHandle != FPDragHandleNone)
        {
            levelCanvas.resizeDraggedObject(widthSegments, heightSegments);
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
    isDown = false;
    
    if (levelCanvas.selectionStart != null)
    {
        levelCanvas.draggedObject = null;
        
        levelCanvas.selectObjects();
        
        levelCanvas.selectionStart = null;
        levelCanvas.selectionEnd = null;
    }
    
    paletteCanvas.activeFactory = null;
    oldCursor = null;
    
    levelCanvas.draw();
    paletteCanvas.draw();
}

function FPLevelCanvas(canvasName)
{
    this.canvas = document.getElementById(canvasName);
    this.context = this.canvas.getContext('2d');
    
    this.canvas.width = document.width - 110;
    this.canvas.height = document.height - 4;
    
    this.levelObjects = new Array();
    
    this.draggedObject = null;
    
    this.selectionStart = null;
    this.selectionEnd = null;
    
    this.canvas.addEventListener('mousedown', levelMouseDown, false);
    this.canvas.addEventListener('mousemove', levelMouseMove, false);
    this.canvas.addEventListener('mouseup', levelMouseUp, false);
    
    this.currentHandle = FPDragHandleNone;
    
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
            
            if (levelObject.selected || levelObject == this.draggedObject)
            {
                var levelObjectRect = levelObject.rect();
                this.context.strokeStyle = "rgba(255,255,255, 1.0)";
                this.context.strokeRect(levelObjectRect.origin.x, levelObjectRect.origin.y, levelObjectRect.size.width, levelObjectRect.size.height);
            }          
            
             if (levelObject == this.draggedObject)
                this.drawHandles(levelObject); 
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
    
    this.deselectAll = function()
    {
        for (i in this.levelObjects)
        {
            var levelObject = this.levelObjects[i];
            levelObject.selected = false;
        }
    }
    
    this.moveSelected = function(offsetX, offsetY)
    {
        for (i in this.levelObjects)
        {
            var levelObject = this.levelObjects[i];
            if (levelObject.selected || levelObject == this.draggedObject)
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
        this.levelObjects = this.levelObjects.filter(function (obj) { return !obj.selected && obj != this.draggedObject; });
        this.draw();
    }
    
    this.pointFromHandle = function(handle, rect)
    {
        switch (handle)
        {
    		case FPDragHandleTopLeft:
    			return new FPPoint(rect.origin.x, rect.origin.y);
    		case FPDragHandleBottomLeft:
    			return new FPPoint(rect.origin.x, rect.origin.y + rect.size.height);
    		case FPDragHandleTopRight:
    			return new FPPoint(rect.origin.x + rect.size.width, rect.origin.y);
    		case FPDragHandleBottomRight:
    			return new FPPoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);

    		case FPDragHandleMiddleLeft:
    			return new FPPoint(rect.origin.x, rect.origin.y + rect.size.height / 2.0);
    		case FPDragHandleMiddleTop:
    			return new FPPoint(rect.origin.x + rect.size.width / 2.0, rect.origin.y);
    		case FPDragHandleMiddleRight:
    			return new FPPoint(rect.origin.x + rect.size.width, rect.origin.y + rect.size.height / 2.0);
    		case FPDragHandleMiddleBottom:
    			return new FPPoint(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height);

    		default:
    			return new FPPoint(0.0, 0.0);
    	}
    }
    
    this.drawHandles = function(levelObject)
    {
        for (var handle = FPDragHandleTopLeft; handle <= FPDragHandleMiddleBottom; handle++)
        {
    		/*if (!widthHandles && [self isWidthHandle:handle])
    			continue;

    		if (!heightHandles && [self isHeightHandle:handle])
    			continue;		*/

    		if (handle == this.currentHandle)
    		    this.context.fillStyle = "rgba(255, 0, 0, 0.8)";
    		else
    		    this.context.fillStyle = "rgba(255, 255, 128, 0.8)";

            var levelObjectRect = levelObject.rect();
    		var handlePoint = this.pointFromHandle(handle, levelObjectRect);
    		this.context.fillRect(handlePoint.x - 3.0, handlePoint.y - 3.0, 6.0, 6.0);
    	}
    }
    
    this.resizeDraggedObject = function(widthSegments, heightSegments)
    {
        switch (this.currentHandle)
        {
		case FPDragHandleTopLeft:
			this.resizeDraggedObjectTop(heightSegments);
			this.resizeDraggedObjectLeft(widthSegments);
			break;
		case FPDragHandleTopRight:
            this.resizeDraggedObjectTop(heightSegments);
			this.resizeDraggedObjectRight(widthSegments);
			break;
		case FPDragHandleBottomLeft:
			this.resizeDraggedObjectBottom(heightSegments);
			this.resizeDraggedObjectLeft(widthSegments);
			break;
		case FPDragHandleBottomRight:
			this.resizeDraggedObjectBottom(heightSegments);
			this.resizeDraggedObjectRight(widthSegments);
			break;
		case FPDragHandleMiddleTop:
			this.resizeDraggedObjectTop(heightSegments);
			break;
		case FPDragHandleMiddleBottom:
			this.resizeDraggedObjectBottom(heightSegments);
			break;
		case FPDragHandleMiddleLeft:
			this.resizeDraggedObjectLeft(widthSegments);
			break;
		case FPDragHandleMiddleRight:
		    this.resizeDraggedObjectRight(widthSegments);
			break;
		}
    }
    
    this.resizeDraggedObjectLeft = function(widthSegments)
    {
    	if (this.draggedObject.widthSegments - widthSegments < 1)
    		widthSegments = 0;

        this.draggedObject.move(widthSegments * 32.0, 0.0);
    	oldCursor.x += widthSegments * 32.0;
    	this.draggedObject.widthSegments -= widthSegments;
    }
    
    this.resizeDraggedObjectRight = function(widthSegments)
    {
    	if (this.draggedObject.widthSegments + widthSegments < 1)
    		widthSegments = 0;

    	oldCursor.x += widthSegments * 32.0;
    	this.draggedObject.widthSegments += widthSegments;
    }
    
    this.resizeDraggedObjectTop = function(heightSegments)
    {
    	if (this.draggedObject.heightSegments - heightSegments < 1)
    		heightSegments = 0;

        this.draggedObject.move(0.0, heightSegments * 32.0);
    	oldCursor.y += heightSegments * 32.0;
    	this.draggedObject.heightSegments -= heightSegments;
    }
    
    this.resizeDraggedObjectBottom = function(heightSegments)
    {
    	if (this.draggedObject.heightSegments + heightSegments < 1)
    		heightSegments = 0;

    	oldCursor.y += heightSegments * 32.0;
    	this.draggedObject.heightSegments += heightSegments;
    }    
}