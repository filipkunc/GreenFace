// Copyright 2010 Filip Kunc. All rights reserved.

var diamondImage = new Image();
diamondImage.src = "Images/diamond.png";

function FPDiamondFactory()
{
    this.image = diamondImage;
    
    this.create = function(levelObjects, x, y)
    {
        levelObjects.push(new FPDiamond(x, y));
    }    
}

function FPDiamond(x, y)
{
    this.x = x;
    this.y = y;
    this.isVisible = true;
    this.selected = false;

    this.isPlatform = function()
    {
        return false;
    }
    
    this.isMovable = function()
    {
        return false;
    }
    
    this.rect = function()
    {
        return new FPRect(this.x, this.y, 32.0, 32.0);
    }
    
    this.move = function(offsetX, offsetY)
    {
        this.x += offsetX;
        this.y += offsetY;
    }
    
    this.update = function(game)
    {
        if (!this.isVisible)
            return;
        
        var intersection = FPRectIntersection(game.player.rect(), this.rect());
        if (!intersection.isEmpty())
        {
            game.diamondsPicked++;
        	this.isVisible = false;
    	}
    }
    
    this.draw = function(context)
    {
        context.drawImage(diamondImage, this.x, this.y);
    }
    
    this.toLevelString = function()
    {
        var levelString = new String('<FPDiamond>\n');
        levelString += '<x>' + this.x.toString() + '</x>\n';
        levelString += '<y>' + this.y.toString() + '</y>\n';
        levelString += '</FPDiamond>\n';
        return levelString;
    }
}