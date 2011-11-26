function getCursorPosition(canvas, e)
{
    var x;
    var y;
    if (e.pageX || e.pageY) 
    {
        x = e.pageX;
        y = e.pageY;
    }
    else 
    {
        x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
        y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
    }
    
    x -= canvas.offsetLeft;
    y -= canvas.offsetTop;
    
    return new FPPoint(x, y);
}

function paletteClick(e)
{
    var cursor = getCursorPosition(paletteCanvas.canvas, e);
    
    paletteCanvas.activeFactory = null;
    
    var x = 8;
    var y = 5;
    
    for (i in paletteCanvas.objectPalette)
    {
        var factory = paletteCanvas.objectPalette[i];
        var rect = new FPRect(x, y, factory.image.width, factory.image.height);
        
        if (rect.containsPoint(cursor.x, cursor.y))
        {
            paletteCanvas.activeFactory = factory;
            break;   
        }
        
        y += factory.image.height + 5;
    }     
    
    paletteCanvas.draw();
}

function FPPaletteCanvas(canvasName)
{
    this.canvas = document.getElementById(canvasName);
    this.context = this.canvas.getContext('2d');
    
    this.canvas.height = document.height - 4;
    
    this.objectPalette = new Array();
    this.activeFactory = null;
    
    this.objectPalette.push(new FPPlayerFactory());
    this.objectPalette.push(new FPPlatformFactory());
    this.objectPalette.push(new FPMovablePlatformFactory());
    this.objectPalette.push(new FPElevatorFactory());
    this.objectPalette.push(new FPDiamondFactory());
    this.objectPalette.push(new FPMagnetFactory());
    //this.objectPalette.push(new FPSpeedPowerUpFactory());
    this.objectPalette.push(new FPTrampolineFactory());
    this.objectPalette.push(new FPExitFactory());
    
    this.canvas.addEventListener("click", paletteClick, false);
    
    this.draw = function()
    {
        this.context.fillStyle = "RGB(55,60,89)";
        this.context.fillRect(0, 0,  this.canvas.width, this.canvas.height);
        
        var x = 8;
        var y = 5;
        
        for (i in this.objectPalette)
        {
            var factory = this.objectPalette[i];
            this.context.drawImage(factory.image, x, y);
            
            if (this.activeFactory == factory)
            {
                this.context.strokeStyle = "white";
                this.context.strokeRect(x, y, factory.image.width, factory.image.height);           
            }
            
            y += factory.image.height + 5;
        }
    }    
}