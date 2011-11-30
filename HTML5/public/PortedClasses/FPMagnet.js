// Copyright 2010 Filip Kunc. All rights reserved.

var magnetImage = new Image();
magnetImage.src = "Images/magnet.png";

function FPMagnetFactory()
{
    this.image = magnetImage;
    
    this.create = function(levelObjects, x, y)
    {
        levelObjects.push(new FPMagnet(x, y, 1));
    }    
}

function FPMagnet(x, y, widthSegments)
{
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
        return new FPRect(this.x, this.y, this.widthSegments * 32.0, 32.0);
    }
    
    this.move = function(offsetX, offsetY)
    {
        this.x += offsetX;
        this.y += offsetY;
    }
    
    this.update = function(game)
    {
        var player = game.player;
        var playerRect = player.rect();
    	var selfRect = this.rect();
    	selfRect.origin.y += 32.0;
    	selfRect.size.height += 32.0 * 4;
    	selfRect.origin.x += 18.0;
    	selfRect.size.width -= 18.0 * 2.0;
    	if (FPRectIntersectsRect(selfRect, playerRect))
    	{
    		if (player.moveY < 5.0)
    			player.moveY = lerp(player.moveY, 5.0, 0.3);
    	}
    }
    
    this.draw = function(context)
    {
        for (ix = 0; ix < this.widthSegments; ix++)
        {
            context.drawImage(magnetImage, this.x + ix * 32.0, this.y);
        }
    }
    
    this.toLevelString = function()
    {
        var levelString = new String('<FPMagnet>\n');
        levelString += '<x>' + this.x.toString() + '</x>\n';
        levelString += '<y>' + this.y.toString() + '</y>\n';
        levelString += '<widthSegments>' + this.widthSegments.toString() + '</widthSegments>\n';
        levelString += '</FPMagnet>\n';
        return levelString;        
    }
}