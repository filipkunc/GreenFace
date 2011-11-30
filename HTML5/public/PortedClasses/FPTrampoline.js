// Copyright 2010 Filip Kunc. All rights reserved.

var trampolineImage = new Array();
trampolineImage[0] = new Image();
trampolineImage[0].src = "Images/trampoline01.png";
trampolineImage[1] = new Image();
trampolineImage[1].src = "Images/trampoline02.png";
trampolineImage[2] = new Image();
trampolineImage[2].src = "Images/trampoline03.png";

function FPTrampolineFactory()
{
    this.image = trampolineImage[0];
    
    this.create = function(levelObjects, x, y)
    {
        levelObjects.push(new FPTrampoline(x, y, 1));
    }    
}

function FPTrampoline(x, y, widthSegments)
{
    this.animationCounter = 0;
    this.textureIndex = 0;
    this.textureDirection = 1;
    this.x = x;
    this.y = y;
    this.widthSegments = widthSegments;
    this.isVisible = true;
    this.selected = false;

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
        return new FPRect(this.x, this.y, this.widthSegments * 64.0, 32.0);
    }
    
    this.move = function(offsetX, offsetY)
    {
        this.x += offsetX;
        this.y += offsetY;
    }
    
    this.update = function(game)
    {
        var playerRect = game.player.rect();
        var selfRect = this.rect();

        if (!FPRectIntersectsRect(playerRect, selfRect))
    	{
    		playerRect.size.height += tolerance;
    		if (FPRectIntersectsRect(playerRect, selfRect))
    		{
    		    var player = game.player;
    			player.moveY = 9.5;
    		}
    	}

    	for (i in game.gameObjects)
    	{
    	    var gameObject = game.gameObjects[i];
    		if (gameObject.isMovable())
    		{    		    
    			var gameObjectRect = gameObject.rect();
    			gameObjectRect.size.height += tolerance;
    			var intersection = FPRectIntersection(gameObjectRect, selfRect);
    			if (!intersection.isEmpty() && intersection.size.width > 30.0)
    			{
    				gameObject.moveY = 8.0;
    			}
    		}
    	}

    	if (++this.animationCounter > 5)
    	{
    		this.textureIndex += this.textureDirection;
    		if (this.textureIndex < 0 || this.textureIndex >= 2)
    		{
    			this.textureIndex -= this.textureDirection;
    			this.textureDirection = -this.textureDirection;
    		}
    		this.animationCounter = 0;
    	}
    }
    
    this.draw = function(context)
    {
        for (ix = 0; ix < this.widthSegments; ix++)
        {
            context.drawImage(trampolineImage[this.textureIndex], this.x + ix * 64.0, this.y);
        }
    }
    
    this.toLevelString = function()
    {
        var levelString = new String('<FPTrampoline>\n');
        levelString += '<x>' + this.x.toString() + '</x>\n';
        levelString += '<y>' + this.y.toString() + '</y>\n';
        levelString += '<widthSegments>' + this.widthSegments.toString() + '</widthSegments>\n';
        levelString += '</FPTrampoline>\n';
        return levelString;        
    }
}