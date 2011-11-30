// Copyright 2010 Filip Kunc. All rights reserved.

var elevatorImage = new Array();
elevatorImage[0] = new Image();
elevatorImage[0].src = "Images/vytah01.png";
elevatorImage[1] = new Image();
elevatorImage[1].src = "Images/vytah02.png";
elevatorImage[2] = new Image();
elevatorImage[2].src = "Images/vytah03.png";

const speed = 2.0;

function FPElevatorFactory()
{
    this.image = elevatorImage[0];
    
    this.create = function(levelObjects, x, y)
    {
        var elevator = new FPElevator(x, y, x, y + 96, 1);
        levelObjects.push(elevator);
        levelObjects.push(new FPElevatorEnd(elevator));
    }    
}

function FPElevator(x, y, endX, endY, widthSegments)
{
    this.x = x;
    this.y = y;
    this.startX = x;
    this.startY = y;
    this.endX = endX;
    this.endY = endY;
    this.widthSegments = widthSegments;
    this.textureIndex = 0;
    this.animationCounter = 0;
    this.movingToEnd = true;
    this.affectedObjects = null;
    this.isVisible = true;
    this.selected = false;
    this.elevatorEnd = null;

    this.isPlatform = function()
    {
        return true;
    }
    
    this.isMovable = function()
    {
        return false;
    }
    
    this.rect = function()
    {
        return new FPRect(this.x, this.y, this.widthSegments * 32.0, 32.0);
    }
    
    this.move = function(offsetX, offsetY)
    {
        this.x += offsetX;
        this.y += offsetY;
        this.startX += offsetX;
        this.startY += offsetY;
        if (this.elevatorEnd == null)
        {
            this.endX += offsetX;
            this.endY += offsetY;
        }
    }
    
    this.elevatorCollision = function(game, diffX, diffY)
    {
        var player = game.player;
        var playerRect = player.rect();
        playerRect.size.height -= tolerance;        
        var moveRect = FPRectWithMove(this.rect(), diffX, diffY);
        
        if (diffY > 0.0)
        {
            if (FPRectIntersectsRectWithTolerance(playerRect, moveRect))
                diffY = 0.0;
            else
            {
                for (i in game.gameObjects)
                {
                    var gameObject = game.gameObjects[i];
                    if (gameObject.isMovable())
                    {
                        if (FPRectIntersectsRectWithTolerance(gameObject.rect(), moveRect))
                        {
                            diffY = 0.0;
                            break;
                        }
                    }
                }
            }
        }
        
        if (Math.abs(diffX) > 0.0)
        {
            if (FPRectIntersectsRectWithTolerance(playerRect, moveRect))
                diffX = 0.0;
            else
            {   
                for (i in game.gameObjects)
                {
                    var gameObject = game.gameObjects[i];
                    var gameObjectRect = gameObject.rect();
                    gameObjectRect.size.height -= tolerance;
                    if (gameObject.isMovable())
                    {
                        if (FPRectIntersectsRectWithTolerance(gameObjectRect, moveRect))
                        {
                            diffX = 0.0;
                            break;
                        }
                    }
                }
            }
        }
        
        playerRect.size.height += tolerance * 2.0;
        
        if (FPRectIntersectsRectWithTolerance(playerRect, moveRect))
        {
            game.moveWorld(-diffX, 0.0);
            player.collisionLeftRight(game);
            game.moveWorld(0.0, -diffY);
        }
        else
        {
            for (i in this.affectedObjects)
            {
                var gameObject = this.affectedObjects[i];
                moveRect = FPRectWithMove(gameObject.rect(), diffX, diffY);
                if (FPRectIntersectsRectWithTolerance(playerRect, moveRect))
                {
                    game.moveWorld(-diffX, 0.0);
                    player.collisionLeftRight(game);
                    game.moveWorld(0.0, -diffY);
                    break;
                }
            }
        }
        
        var movableOnElevator = null;
        var movableRect;
        
        for (i in game.gameObjects)
        {
            var movable = game.gameObjects[i];
            if (movable.isMovable())
            {
                moveRect = FPRectWithMove(this.rect(), diffX, diffY);
                movableRect = movable.rect();
                movableRect.size.height += tolerance;
                if (movableRect.bottom() < moveRect.bottom() &&
                    FPRectIntersectsRectWithTolerance(movableRect, moveRect))
                {
                    movableOnElevator = movable;
                    break;                        
                }
                else
                {
                    for (j in this.affectedObjects)
                    {
                        var gameObject = this.affectedObjects[j];
                        moveRect = FPRectWithMove(gameObject.rect(), diffX, diffY);
                        if (movableRect.bottom() < moveRect.bottom() &&
                            FPRectIntersectsRectWithTolerance(movableRect, moveRect))
                        {
                            movableOnElevator = movable;
                            break;                        
                        }
                    }
                }
            }
        }
        
        if (movableOnElevator != null)
        {
            var movableRect = FPRectWithMove(movableOnElevator.rect(), diffX, diffY);
            movableOnElevator.move(diffX, 0.0);
            if (movableOnElevator.collisionLeftRight(game))
                movableOnElevator.move(-diffX, 0.0);
            if (FPRectIntersectsRectWithTolerance(playerRect, movableRect))
            {
                game.moveWorld(-diffX, 0.0);
                player.collisionLeftRight(game);
            }
            movableOnElevator.move(0.0, diffY);
            if (FPRectIntersectsRectWithTolerance(playerRect, movableRect))
            {
                game.moveWorld(0.0, -diffY);
            }
        }
        
        this.x += diffX;
        this.y += diffY;
        
        for (i in this.affectedObjects)
        {
            var gameObject = this.affectedObjects[i];
            gameObject.move(diffX, diffY);
        }
    }
    
    this.initAffectedObjectsIfNeeded = function(game)
    {
        if (this.affectedObjects == null)
        {
            this.affectedObjects = new Array();
            var selfRect = this.rect();
            
            for (i in game.gameObjects)
            {
                var gameObject = game.gameObjects[i];
                if (gameObject == this)
                    continue;
                    
                var gameObjectRect = gameObject.rect();
                gameObjectRect.size.height += tolerance;
                if (FPRectIntersectsRect(gameObjectRect, selfRect))
                    this.affectedObjects.push(gameObject);
            }
            
            for (i in game.gameObjects)
            {
                var gameObject = game.gameObjects[i];
                if (gameObject == this)
                    continue;
                    
                if (contains(this.affectedObjects, gameObject))
                    continue;
                    
                var gameObjectRect = gameObject.rect();
                gameObjectRect.size.height += tolerance;
                
                for (j in this.affectedObjects)
                {
                    if (FPRectIntersectsRect(gameObjectRect, this.affectedObjects[j].rect()))
                        this.affectedObjects.push(gameObject);
                }
            }
        }
    }
    
    this.update = function(game)
    {
        var diffX = 0.0, diffY = 0.0;

    	if (this.movingToEnd)
    	{
    		diffX = this.endX - this.x;
    		diffY = this.endY - this.y;
    	}
    	else
    	{
    		diffX = this.startX - this.x;
    		diffY = this.startY - this.y;
    	}

    	diffX = absmin(diffX, speed);
    	diffY = absmin(diffY, speed);

    	if (Math.abs(diffX) < 0.1 && Math.abs(diffY) < 0.1)
    	{
    		this.movingToEnd = !this.movingToEnd;
    	}

        this.initAffectedObjectsIfNeeded(game);
        this.elevatorCollision(game, diffX, diffY);

    	if (this.textureIndex > 2)
    		this.textureIndex = 2;	

    	if (this.textureIndex < 0)
    		this.textureIndex = 0;

    	if (diffY < 0.0)
    	{
    		if (++this.animationCounter > 2)
    		{
    			this.animationCounter = 0;
    			if (++this.textureIndex >= 2)
    				this.textureIndex = 2;
    		}
    	}
    	else if (diffY > 0.0)
    	{
    		if (++this.animationCounter > 2)
    		{
    			this.animationCounter = 0;
    			if (--this.textureIndex < 0)
    				this.textureIndex = 0;
    		}
    	}
    	else
    	{
    		this.textureIndex = 1;
    	}
    }
    
    this.draw = function(context)
    {
        for (ix = 0; ix < this.widthSegments; ix++)
        {
            context.drawImage(elevatorImage[this.textureIndex], this.x + ix * 32.0, this.y);
        }
    }
    
    this.toLevelString = function()
    {
        var levelString = new String('<FPElevator>\n');
        levelString += '<x>' + this.x.toString() + '</x>\n';
        levelString += '<y>' + this.y.toString() + '</y>\n';
        levelString += '<endX>' + this.endX.toString() + '</endX>\n';
        levelString += '<endY>' + this.endY.toString() + '</endY>\n';
        levelString += '<widthSegments>' + this.widthSegments.toString() + '</widthSegments>\n';
        levelString += '</FPElevator>\n';
        return levelString;
    }
}

function FPElevatorEnd(elevator)
{
    this.elevator = elevator;
    this.elevator.elevatorEnd = this;
    
    this.rect = function()
    {
        return new FPRect(this.elevator.endX, this.elevator.endY, this.elevator.widthSegments * 32.0, 32.0);
    }
    
    this.move = function(offsetX, offsetY)
    {
        this.elevator.endX += offsetX;
        this.elevator.endY += offsetY;
    }
    
    this.draw = function(context)
    {
        context.globalAlpha = 0.5;
        for (ix = 0; ix < this.elevator.widthSegments; ix++)
        {
            context.drawImage(elevatorImage[this.elevator.textureIndex], this.elevator.endX + ix * 32.0, this.elevator.endY);
        }        
        context.globalAlpha = 1.0;        
        
        var start = this.elevator.rect().center();
        var end = this.rect().center();

        context.strokeStyle = "rgb(0,255,0)";
        context.beginPath();
        context.moveTo(start.x, start.y);
        context.lineTo(end.x, end.y);
        context.stroke();
    }
    
    this.toLevelString = function()
    {
        return null;
    }
}