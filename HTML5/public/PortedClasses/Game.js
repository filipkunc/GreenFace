// Copyright 2010 Filip Kunc. All rights reserved.

window.onload = init;

const FPS = 60;

var canvas = null;
var context = null;

var game = new FPGame();
var xhr = new XMLHttpRequest();
xhr.onreadystatechange = dataReceived;

function dataReceived(e)
{
    if (xhr.readyState == 4 && xhr.status == 200)
    {
        var xmlDoc = xhr.responseXML;
        
        var posX, posY, widthSegments, heightSegments;
        var playerOffsetX, playerOffsetY;
        var endX, endY;

        var x = xmlDoc.documentElement.childNodes;
        for (i = 0; i < x.length; i++)
        { 
            if (x[i].nodeType == 1)
            {
                y = x[i].childNodes;
                for (j = 0; j < y.length; j++)
                {
                    if (y[j].nodeType == 1)
                    {
                        if (y[j].nodeName == 'x')
                        {
                            posX = parseFloat(y[j].textContent);
                        }
                        else if (y[j].nodeName == 'y')
                        {
                            posY = parseFloat(y[j].textContent);
                        }
                        else if (y[j].nodeName == 'widthSegments')
                        {
                            widthSegments = parseInt(y[j].textContent);
                        }
                        else if (y[j].nodeName == 'heightSegments')
                        {
                            heightSegments = parseInt(y[j].textContent);
                        }
                        else if (y[j].nodeName == 'endX')
                        {
                            endX = parseFloat(y[j].textContent);
                        }
                        else if (y[j].nodeName == 'endY')
                        {
                            endY = parseFloat(y[j].textContent);
                        }
                    }
                }

                if (x[i].nodeName == 'FPPlayer')
                {
                    playerOffsetX = posX;
                    playerOffsetY = posY;
                }
                else if (x[i].nodeName == 'FPExit')
                {
                    game.addGameObject(new FPExit(posX, posY));
                }
                else if (x[i].nodeName == 'FPPlatform')
                {
                    game.addGameObject(new FPPlatform(posX, posY, widthSegments, heightSegments));
                }
                else if (x[i].nodeName == 'FPMovablePlatform')
                {
                    game.addGameObject(new FPMovablePlatform(posX, posY, widthSegments, heightSegments));
                }
                else if (x[i].nodeName == 'FPDiamond')
                {
                    game.addGameObject(new FPDiamond(posX, posY));
                }
                else if (x[i].nodeName == 'FPElevator')
                {
                    game.addGameObject(new FPElevator(posX, posY, endX, endY, widthSegments));
                }
                else if (x[i].nodeName == 'FPTrampoline')
                {
                    game.addGameObject(new FPTrampoline(posX, posY, widthSegments));
                }  
                else if (x[i].nodeName == 'FPMagnet')
                {
                    game.addGameObject(new FPMagnet(posX, posY, widthSegments));
                }          
            }
        }

        game.moveWorld(208.0 - playerOffsetX, 128.0 - playerOffsetY);
        setInterval(draw, 1000 / FPS); 
    }
}

function loadLevel(levelName)
{
    xhr.open("GET",levelName,false);    
    xhr.send();
}

var qsParm = new Array();
function qs() 
{
    var query = window.location.search.substring(1);
    var parms = query.split('&');
    for (var i=0; i<parms.length; i++) 
    {
        var pos = parms[i].indexOf('=');
        if (pos > 0) 
        {
            var key = parms[i].substring(0,pos);
            var val = parms[i].substring(pos+1);
            qsParm[key] = val;
        }
    }
}

function init()
{
    qs();
    
	canvas = document.getElementById('canvas');
	context = canvas.getContext('2d');
	
	loadLevel("Levels/" + qsParm['level']);	
}

var screenSaved = false;

function draw()
{
    game.update();
	context.fillRect(0, 0, canvas.width, canvas.height);
    game.draw(context);
    
    if (!screenSaved)
    {
        screenSaved = true;
        xhr.open("POST","Screenshots/" + qsParm['level'], true);
        xhr.send(canvas.toDataURL("image/png"));
    }
}

function keyDown(event)
{
    // left
    if (event.keyCode == 37)
        game.inputAcceleration.x = -1.0;
    // right
    else if (event.keyCode == 39)
        game.inputAcceleration.x = 1.0;
      
    // up    
    if (event.keyCode == 38)
        game.inputAcceleration.y = 1.0;
}

function keyUp(event)
{
    if (event.keyCode == 37 || event.keyCode == 39)
        game.inputAcceleration.x = 0.0;
    if (event.keyCode == 38)
        game.inputAcceleration.y = 0.0;
}
