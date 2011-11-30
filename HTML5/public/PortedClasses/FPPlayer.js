// Copyright 2010 Filip Kunc. All rights reserved.

var playerImage = new Array();
playerImage[0] = new Image();
playerImage[0].src = "Images/W_01.png";
playerImage[1] = new Image();
playerImage[1].src = "Images/W_02.png";
playerImage[2] = new Image();
playerImage[2].src = "Images/W_03.png";
playerImage[3] = new Image();
playerImage[3].src = "Images/W_04.png";

var jumpImage = new Array();
jumpImage[0] = new Image();
jumpImage[0].src = "Images/WJ_01.png";
jumpImage[1] = new Image();
jumpImage[1].src = "Images/WJ_02.png";

var speedImage = new Image();
speedImage.src = "Images/speed.png";

const tolerance = 3.0;
const maxSpeed = 5.8;
const speedPowerUp = 1.5;
const upSpeed = 7.0;
const maxFallSpeed = -15.0;
const acceleration = 1.1;
const deceleration = 1.1 * 0.2;
const changeDirectionSpeed = 3.0;
const maxSpeedUpCount = 60 * 6; // 60 FPS * 6 sec
const mathPi = 3.1415926535;
const playerSize = 64.0;

function FPPlayerFactory()
{
    this.image = playerImage[3];
    
    this.create = function(levelObjects, x, y)
    {
        var player = new FPPlayer();
        player.x = x;
        player.y = y;
        levelObjects.push(player);
    }    
}

function FPPlayer()
{
    this.x = 480.0 / 2.0 - playerSize / 2.0;
    this.y = 320.0 / 2.0 - playerSize / 2.0;
    this.moveX = 0.0;
    this.moveY = 0.0;
    this.jumping = false;
    this.speedUpCounter = 0;
    this.alpha = 1.0;
    this.isVisible = true;
    this.moveCounter = 3;
    this.jumpCounter = 0;
    this.animationCounter = 0;
    this.leftOriented = false;
    this.selected = false;
    
    this.rect = function()
    {
        return new FPRect(this.x, this.y, playerSize, playerSize);
    }
    
    this.move = function(offsetX, offsetY)
    {
        this.x += offsetX;
        this.y += offsetY;
    }
    
    this.update = function(game)
    {
        var inputAcceleration = game.inputAcceleration;
    	var moveLeftOrRight = false;
    	
    	if (this.speedUpCounter > 0)
    	{
    	    if (++this.speedUpCounter > maxSpeedUpCount)
    	    {
    	        this.speedUpCounter = 0;
	        }
	    }
	    
	    var currentMaxSpeed = this.speedUpCounter > 0 ? maxSpeed * speedPowerUp : maxSpeed;
	    
    	if (inputAcceleration.x < 0.0)
    	{
    		if (this.moveX < 0.0)
    			this.moveX += Math.abs(inputAcceleration.x) * acceleration * changeDirectionSpeed;
    		if (this.moveX < maxSpeed)
    			this.moveX += Math.abs(inputAcceleration.x) * acceleration;
    		moveLeftOrRight = true;
    		this.leftOriented = true;
    	}
    	else if (inputAcceleration.x > 0.0)
    	{
    		if (this.moveX > 0.0)
    			this.moveX -= Math.abs(inputAcceleration.x) * acceleration * changeDirectionSpeed;
    		if (this.moveX > -maxSpeed)
    			this.moveX -= Math.abs(inputAcceleration.x) * acceleration;
    		moveLeftOrRight = true;
    		this.leftOriented = false;
    	}
    	if (!this.jumping && inputAcceleration.y > 0.0)
    	{
    		if (this.moveY < upSpeed)
    			this.moveY = upSpeed;
    		this.jumping = true;
    	}

    	if (!moveLeftOrRight)
    	{
    		if (Math.abs(this.moveX) < deceleration)
    			this.moveX = 0.0;
    		else if (this.moveX > 0.0)
    			this.moveX -= deceleration;
    		else if (this.moveX < 0.0)
    			this.moveX += deceleration;
    	}	

    	this.moveY -= deceleration;
    	if (this.moveY < maxFallSpeed)
    		this.moveY = maxFallSpeed;
    	this.jumping = true;
    	
    	game.moveWorld(this.moveX, 0.0);
    	if (this.collisionLeftRight(game))
    		this.moveX = 0.0;
    	game.moveWorld(0.0, this.moveY);
    	this.collisionUpDown(game);
    	
    	this.alpha += 0.07;
    	if (this.alpha > mathPi)
    	    this.alpha -= mathPi;
    	    
    	var moveSpeed = Math.abs(this.moveX);

        if (this.jumping)
        {
            this.moveCounter = 3;
            this.animationCounter++;

            if (this.animationCounter > 10)
            {
                if (++this.jumpCounter >= 2)
                {
                    this.jumpCounter = 1;
                    this.animationCounter = 10;
                }
            }
        }
        else
        {
            this.jumpCounter = 0;
            this.animationCounter += Math.max(moveSpeed / maxSpeed, 0.6);

            if (this.animationCounter > 5)
            {
                if (!moveLeftOrRight && moveSpeed < 3.5)
                {
                    if (++this.moveCounter >= 4)
                    {
                        this.moveCounter = 3;
                        this.animationCounter = 6;
                    }
                    else
                    {
                        this.animationCounter = 0;
                    }            
                }
                else
                {
                    if (++this.moveCounter >= 4)
                        this.moveCounter = 0;
                    this.animationCounter = 0;
                }
            }
        }
    }
    
    this.collisionLeftRight = function(game)
    {
    	var isColliding = false;

    	for (i in game.gameObjects)
    	{
    	    var platform = game.gameObjects[i];
    	    if (platform.isPlatform())
    		{
    			var intersection = FPRectIntersection(platform.rect(), this.rect());
    			if (intersection.isEmptyWithTolerance())
    			    continue;

    			if (platform.rect().left() > this.rect().left())
    			{
    			    if (platform.isMovable())
    			    {
    			        platform.move(intersection.size.width, 0.0);
    			        if (platform.collisionLeftRight(game))
    			        {
    			            platform.move(-intersection.size.width, 0.0);
    			            game.moveWorld(intersection.size.width, 0.0);
    			            isColliding = true;
			            }
			        }
			        else
			        {
			            game.moveWorld(intersection.size.width, 0.0);
			            isColliding = true;
		            }
    			}
    			else if (platform.rect().right() < this.rect().right())
    			{
    				if (platform.isMovable())
    			    {
    			        platform.move(-intersection.size.width, 0.0);
    			        if (platform.collisionLeftRight(game))
    			        {
    			            platform.move(intersection.size.width, 0.0);
    			            game.moveWorld(-intersection.size.width, 0.0);
    			            isColliding = true;
			            }
			        }
			        else
			        {
			            game.moveWorld(-intersection.size.width, 0.0);
			            isColliding = true;
		            }
    			}
    		}
    	}

    	return isColliding;
    }

    this.collisionUpDown = function(game)
    {
    	var isColliding = false;

    	for (i in game.gameObjects)
    	{
    	    var platform = game.gameObjects[i];
    		if (platform.isPlatform())
    		{
    			var intersection = FPRectIntersection(platform.rect(), this.rect());
    			if (intersection.isEmptyWithTolerance())
    				continue;

    			if (platform.rect().bottom() < this.rect().bottom())
    			{
    				if (this.moveY > 0.0)
    					this.moveY = 0.0;
    			
    				game.moveWorld(0.0, -intersection.size.height);
    				isColliding = true;
    			}
    			else if (this.moveY < 0.0)
    			{
    				if (platform.rect().top() > this.rect().bottom() - tolerance + this.moveY)
    				{
    					this.moveY = 0.0;
    					this.jumping = false;
    					game.moveWorld(0.0, intersection.size.height);
    					isColliding = true;
    				}
    			}
    			else if (platform.rect().top() > this.rect().bottom() - tolerance)
    			{
    				this.jumping = false;
    				game.moveWorld(0.0, intersection.size.height);
    				isColliding = true;
    			}
    		}
    	}

    	return isColliding;
    }    
    
    this.draw = function(context)
    {
        context.save();
        
        if (this.leftOriented)
        {
            context.translate(this.x + playerSize, this.y);
            context.scale(-1, 1);
        }
        else
        {
            context.translate(this.x, this.y);
        }
        
        if (this.jumping)
            context.drawImage(jumpImage[this.jumpCounter], 0, 0);
        else
            context.drawImage(playerImage[this.moveCounter], 0, 0);
        
        context.restore();
        
        if (this.speedUpCounter > 0)
            this.drawSpeedUp(context);
    }
    
    this.drawSpeedUp = function(context)
    {
        context.globalAlpha = Math.abs(Math.sin(this.alpha)) * 0.5 + 0.5;
        context.drawImage(jumpImage, 240 - playerSize, 160 - playerSize);
        context.globalAlpha = 1.0;
    }
    
    this.toLevelString = function()
    {
        var levelString = new String('<FPPlayer>\n');
        levelString += '<x>' + this.x.toString() + '</x>\n';
        levelString += '<y>' + this.y.toString() + '</y>\n';
        levelString += '</FPPlayer>\n';
        return levelString;
    }
}