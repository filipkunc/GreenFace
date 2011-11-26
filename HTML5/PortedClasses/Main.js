// Copyright 2010 Filip Kunc. All rights reserved.

window.onload = init;

const FPS = 60;

var canvas = null;
var context = null;

var game = new FPGame();

function loadXMLDoc(dname)
{
    if (window.XMLHttpRequest)
        xhttp = new XMLHttpRequest();
    else
        xhttp = new ActiveXObject("Microsoft.XMLHTTP");

    xhttp.open("GET",dname,false);
    xhttp.send();
    return xhttp.responseXML;
}

function loadLevel(levelName)
{
    var xmlDoc = loadXMLDoc(levelName);
    
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
    
    game.moveWorld(240.0 - playerOffsetX, 160.0 - playerOffsetY);
    
}

function init()
{
	canvas = document.getElementById('canvas');
	context = canvas.getContext('2d');
	
	//loadLevel('Levels/Tutorial.greenlevel');
}

function runGame()
{
    setInterval(draw, 1000 / FPS);  
}

function draw()
{
    game.update();
	context.fillRect(0, 0, canvas.width, canvas.height);
    game.draw(context);
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
