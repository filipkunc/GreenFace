// Copyright 2010 Filip Kunc. All rights reserved.

var exitImage = new Image();
exitImage.src = "Images/exit.png";

function FPExitFactory()
{
    this.image = exitImage;
    
    this.create = function(levelObjects, x, y)
    {
        levelObjects.push(new FPExit(x, y));
    }    
}

function FPExit(x, y)
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
        return new FPRect(this.x, this.y, 64.0, 64.0);
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
        	this.isVisible = false;
    }
    
    this.draw = function(context)
    {
        context.drawImage(exitImage, this.x, this.y);
    }
    
    this.toLevelString = function()
    {
        var levelString = new String('<FPExit>\n');
        levelString += '<x>' + this.x.toString() + '</x>\n';
        levelString += '<y>' + this.y.toString() + '</y>\n';
        levelString += '</FPExit>\n';
        return levelString;       
    }
}