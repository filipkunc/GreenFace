var paletteCanvas = null;
var levelCanvas = null;

window.onload = init;
window.onkeydown = keyDown;

function init()
{
    paletteCanvas = new FPPaletteCanvas('paletteCanvas');
	levelCanvas = new FPLevelCanvas('levelCanvas');
	
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

function createGameDocument()
{
    return new String( 
    '<!DOCTYPE html>\n' +
    '<html lang="en">\n' +
    '<head>\n' +
    '<title>Game Simulation</title>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPGraphics.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPPlatform.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPMovablePlatform.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPPlayer.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPDiamond.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPExit.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPElevator.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPTrampoline.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPMagnet.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/FPGame.js"></script>\n' +
    	'<script type="text/javascript" src="PortedClasses/Main.js"></script>\n' +    	
    	'<style type="text/css">\n' +
    		'body { font-family: Arial, Helvetica, sans-serif; margin: 0px; padding: 0px; background-color:rgb(150,150,150); }\n' +
    		'canvas { margin: 0px; padding: 0px; }\n' +
    	'</style>\n' +
    '</head>\n' +
    '<body onkeydown="keyDown(event);" onkeyup="keyUp(event);">\n' +
        createLevelScript() +
        '<canvas id="canvas" width="480" height="320">\n' +
        '</canvas>\n' +
    '</body>\n' +
    '</html>\n');
}

function createLevelScript()
{
    var levelScript = new String('<script type="text/javascript">\n');

    for (var i in levelCanvas.levelObjects)
    {
        var levelObject = levelCanvas.levelObjects[i];
        var str = levelObject.toLevelString(true);
        if (str != null)
            levelScript += str + '\n';
    }
    
    for (var i in levelCanvas.levelObjects)
    {
        var levelObject = levelCanvas.levelObjects[i];
        var str = levelObject.toLevelString(false);
        if (str != null)
            levelScript += str + '\n';
    }

    levelScript += 'runGame();\n';
    levelScript += '</script>\n';
    return levelScript;
}

function keyDown(e)
{
    switch (e.keyCode)
    {
        case 13: // enter
        {
            var documentString = createGameDocument();
            //alert(documentString);
        
            var newWindow = windowOpener(480, 295, 'Game Simulation', '');
            newWindow.document.write(documentString);
            newWindow.document.close();
        } break;
        case 8: // backspace
        case 46: // delete
        {
            levelCanvas.deleteSelected();
        } break;
    }
}