var paletteCanvas = null;
var levelCanvas = null;
var xhr = new XMLHttpRequest();

window.onload = init;
window.onkeydown = keyDown;

function loadXMLDoc(dname)
{
    xhr.open("GET",dname,false);
    xhr.send();
    return xhr.responseXML;
}

function loadLevel(levelName)
{
    var xmlDoc = loadXMLDoc(levelName);
    
    if (xmlDoc == null)
        return;
    
    var posX, posY, widthSegments, heightSegments;
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
                var player = new FPPlayer();
                player.x = posX;
                player.y = posY;
                levelCanvas.levelObjects.push(player);
            }
            else if (x[i].nodeName == 'FPExit')
            {
                levelCanvas.levelObjects.push(new FPExit(posX, posY));
            }
            else if (x[i].nodeName == 'FPPlatform')
            {
                levelCanvas.levelObjects.push(new FPPlatform(posX, posY, widthSegments, heightSegments));
            }
            else if (x[i].nodeName == 'FPMovablePlatform')
            {
                levelCanvas.levelObjects.push(new FPMovablePlatform(posX, posY, widthSegments, heightSegments));
            }
            else if (x[i].nodeName == 'FPDiamond')
            {
                levelCanvas.levelObjects.push(new FPDiamond(posX, posY));
            }
            else if (x[i].nodeName == 'FPElevator')
            {
                var elevatorStart = new FPElevator(posX, posY, endX, endY, widthSegments);
                var elevatorEnd = new FPElevatorEnd(elevatorStart);
                levelCanvas.levelObjects.push(elevatorStart);
                levelCanvas.levelObjects.push(elevatorEnd);
            }
            else if (x[i].nodeName == 'FPTrampoline')
            {
                levelCanvas.levelObjects.push(new FPTrampoline(posX, posY, widthSegments));
            }  
            else if (x[i].nodeName == 'FPMagnet')
            {
                levelCanvas.levelObjects.push(new FPMagnet(posX, posY, widthSegments));
            }          
        }
    }
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
    
    paletteCanvas = new FPPaletteCanvas('paletteCanvas');
	levelCanvas = new FPLevelCanvas('levelCanvas');
	
	loadLevel("Levels/" + qsParm['level']);
	
	paletteCanvas.draw();
	levelCanvas.draw();	
}

function windowOpener(windowWidth, windowHeight, windowName, windowUri)
{
    var centerWidth = (window.screen.width - windowWidth) / 2;
    var centerHeight = (window.screen.height - windowHeight) / 2;

    var newWindow = window.open(windowUri, windowName, 'resizable=0,width=' + windowWidth + 
        ',height=' + windowHeight + 
        ',left=' + centerWidth + 
        ',top=' + centerHeight);

    newWindow.focus();
    return newWindow;
}

function createLevelXml()
{
    var levelXml = new String('<?xml version="1.0" encoding="utf-8"?>\n');
    levelXml += '<IronJumpLevel>\n';
    
    for (var i in levelCanvas.levelObjects)
    {
        var levelObject = levelCanvas.levelObjects[i];
        var str = levelObject.toLevelString();
        if (str != null)
            levelXml += str;
    }
    
    levelXml += '</IronJumpLevel>\n';
    return levelXml;
}

function keyDown(e)
{
    switch (e.keyCode)
    {
        case 13: // enter
        {
            var documentString = createLevelXml();
            xhr.open("POST","Levels/" + qsParm['level'], true);
            xhr.send(documentString);            
            windowOpener(480, 295, 'Game Simulation', 'game/level/' + qsParm['level']);
        } break;
        case 8: // backspace
        case 46: // delete
        {
            levelCanvas.deleteSelected();
        } break;
    }
}