var game = new Phaser.Game(800, 600, Phaser.CANVAS, 'phaser-example', this);

var ActiveCellIndication = function(scope){
    this.bitMapData = scope.game.make.bitmapData(scope.spriteWidth * scope.canvasZoom, scope.spriteHeight * scope.canvasZoom);

    this.addToWorld = function(x, y){
        this.bitMapData.addToWorld(x, y);
    };

    this.highLight = function(x, y){
        this.bitMapData.clear();
        this.bitMapData.rect(x * scope.canvasZoom + 1, y * scope.canvasZoom + 1, scope.canvasZoom, scope.canvasZoom, '#0f0');
        this.bitMapData.clear(x * scope.canvasZoom + 2, y * scope.canvasZoom + 2, scope.canvasZoom - 2, scope.canvasZoom - 2, '#000');
    }
};

var currentX = 0, currentY = 0;

//  Dimensions
var previewSize = 6;
var spriteWidth = 16;
var spriteHeight = 16;

//  UI
var ui;
var paletteArrow;
var coords;
var widthText;
var widthUp;
var widthDown;
var heightText;
var heightUp;
var heightDown;
var previewSizeUp;
var previewSizeDown;
var previewSizeText;
var frameText;


var rightCol = 532;

//  Drawing Area
var canvas;
var canvasBG;
var canvasGrid;
var canvasSprite;
var canvasZoom = 32;

//  Sprite Preview
var preview;
var previewBG;

//  Keys + Mouse
var keys;
var isDown = false;
var isErase = false;

//  Palette
var ci = 0;
var color = 0;
var palette = 0;
//var pmap = [0,1,2,3,4,5,6,7,8,9,'A','B','C','D','E','F'];

//  Data
var frame = 1;
var frames = [[]];

var timerCount = 0;
var timer;

var data;

var activeCellIndication;

var websocket;

var  Cells, Fractions, Players, Fraction, Player;

function create() {

    //   So we can right-click to erase
    document.body.oncontextmenu = function() { return false; };

    Phaser.Canvas.setUserSelect(game.canvas, 'none');
    Phaser.Canvas.setTouchAction(game.canvas, 'none');

    game.stage.backgroundColor = '#505050';

    createUI();
    createDrawingArea();
    createPreview();
    activeCellIndication = new ActiveCellIndication(this);
    activeCellIndication.addToWorld(10, 10);
    createEventListeners();

    resetData();

    //canvas.rect(10 * canvasZoom, 10 * canvasZoom, canvasZoom, canvasZoom, "#ffffff");

    loadState();

    startWebSocket();
}

function resetData() {

    data = [];

    for (var y = 0; y < spriteHeight; y++)
    {
        var a = [];

        for (var x = 0; x < spriteWidth; x++)
        {
            a.push('.');
        }

        data.push(a);
    }

}

function copyToData(src) {

    data = [];

    for (var y = 0; y < src.length; y++)
    {
        var a = [];

        for (var x = 0; x < src[y].length; x++)
        {
            a.push(src[y][x]);
        }

        data.push(a);
    }

}

function cloneData() {

    var clone = [];

    for (var y = 0; y < data.length; y++)
    {
        var a = [];

        for (var x = 0; x < data[y].length; x++)
        {
            var v = data[y][x];
            a.push(v);
        }

        clone.push(a);
    }

    return clone;

}

function createUI() {

    game.create.grid('uiGrid', 32 * 16, 32, 32, 32, 'rgba(255,255,255,0.5)');

    //  Create some icons
    var arrow = [
        '222222222222222222',
        '2................2',
        '2.......22.......2',
        '2......2222......2',
        '2.....222222.....2',
        '2....22222222....2',
        '2...2222222222...2',
        '2..222222222222..2',
        '2.2222.2222.2222.2',
        '2..22..2222..22..2',
        '2......2222......2',
        '2......2222......2',
        '2......2222......2',
        '2......2222......2',
        '2......2222......2',
        '2................2',
        '2................2',
        '222222222222222222'
    ];

    var arrowLeft = [
        '2222222222222222222',
        '2.................2',
        '2........2........2',
        '2.......222.......2',
        '2......2222.......2',
        '2.....2222........2',
        '2....2222.........2',
        '2...222222222222..2',
        '2..2222222222222..2',
        '2..2222222222222..2',
        '2...222222222222..2',
        '2....2222.........2',
        '2.....2222........2',
        '2......2222.......2',
        '2.......222.......2',
        '2........2........2',
        '2.................2',
        '2222222222222222222'
    ];

    var arrowRight = [
        '222222222222222222',
        '2................2',
        '2........2.......2',
        '2.......222......2',
        '2.......2222.....2',
        '2........2222....2',
        '2.........2222...2',
        '2..222222222222..2',
        '2..2222222222222.2',
        '2..2222222222222.2',
        '2..222222222222..2',
        '2.........2222...2',
        '2........2222....2',
        '2.......2222.....2',
        '2.......222......2',
        '2........2.......2',
        '2................2',
        '222222222222222222'
    ];

    var arrowBottom = [
        '222222222222222222',
        '2................2',
        '2................2',
        '2......2222......2',
        '2......2222......2',
        '2......2222......2',
        '2......2222......2',
        '2......2222......2',
        '2..22..2222..22..2',
        '2.2222.2222.2222.2',
        '2..222222222222..2',
        '2...2222222222...2',
        '2....22222222....2',
        '2.....222222.....2',
        '2......2222......2',
        '2.......22.......2',
        '2................2',
        '222222222222222222'
    ];
    var plus = [
        '2222222',
        '2.....2',
        '2..2..2',
        '2.222.2',
        '2..2..2',
        '2.....2',
        '2222222'
    ];

    var minus = [
        '2222222',
        '2.....2',
        '2.....2',
        '2.222.2',
        '2.....2',
        '2.....2',
        '2222222'
    ];



    game.create.texture('arrowLeft', arrowLeft, 3);
    game.create.texture('arrowRight', arrowRight, 3);
    game.create.texture('arrowTop', arrow, 3);
    game.create.texture('arrowBottom', arrowBottom, 3);
    game.create.texture('arrow', arrow, 1);
    game.create.texture('plus', plus, 3);
    game.create.texture('minus', minus, 3);


    ui = game.make.bitmapData(800, 32);

    // drawPalette();

    ui.addToWorld();

    var style = { font: "20px Courier", fill: "#fff", tabs: 80 };

    coords = game.add.text(rightCol, 8, "X: 0\tY: 0", style);

    timerLabel = game.add.text(rightCol + 150, 8, "Timer: 0", style);

    //game.add.text(12, 9, pmap.join("\t"), { font: "14px Courier", fill: "#000", tabs: 32 });
    //game.add.text(11, 8, pmap.join("\t"), { font: "14px Courier", fill: "#ffff00", tabs: 32 });

    // paletteArrow = game.add.sprite(8, 36, 'arrow');

    //  Change width

    widthText = game.add.text(rightCol, 60, "Current X: " + currentX, style);

    widthUp = game.add.sprite(rightCol + 50, 150, 'arrowLeft');
    widthUp.name = 'width';
    widthUp.inputEnabled = true;
    widthUp.input.useHandCursor = true;
    widthUp.events.onInputDown.add(sendLeft, this);

    widthDown = game.add.sprite(rightCol + 120, 150, 'arrowRight');
    widthDown.name = 'width';
    widthDown.inputEnabled = true;
    widthDown.input.useHandCursor = true;
    widthDown.events.onInputDown.add(sendRight, this);

    //  Change height

    heightText = game.add.text(rightCol, 100, "Current Y: " + currentY, style);

    heightUp = game.add.sprite(rightCol + 50, 220, 'arrowBottom');
    heightUp.name = 'height';
    heightUp.inputEnabled = true;
    heightUp.input.useHandCursor = true;
    heightUp.events.onInputDown.add(sendBottom, this);

    heightDown = game.add.sprite(rightCol + 120, 220, 'arrowTop');
    heightDown.name = 'height';
    heightDown.inputEnabled = true;
    heightDown.input.useHandCursor = true;
    heightDown.events.onInputDown.add(sendTop, this);


    //  Change preview

    previewSizeText = game.add.text(rightCol, 320, "Size: " + previewSize, style);

    previewSizeUp = game.add.sprite(rightCol + 180, 320, 'plus');
    previewSizeUp.inputEnabled = true;
    previewSizeUp.input.useHandCursor = true;
    previewSizeUp.events.onInputDown.add(increasePreviewSize, this);

    previewSizeDown = game.add.sprite(rightCol + 220, 320, 'minus');
    previewSizeDown.inputEnabled = true;
    previewSizeDown.input.useHandCursor = true;
    previewSizeDown.events.onInputDown.add(decreasePreviewSize, this);

}

function createDrawingArea() {

    game.create.grid('drawingGrid', 16 * canvasZoom, 16 * canvasZoom, canvasZoom, canvasZoom, 'rgba(0,191,243,0.3)');

    canvas = game.make.bitmapData(spriteWidth * canvasZoom, spriteHeight * canvasZoom);
    canvasBG = game.make.bitmapData(canvas.width + 2, canvas.height + 2);

    canvasBG.rect(0, 0, canvasBG.width, canvasBG.height, '#fff');
    canvasBG.rect(1, 1, canvasBG.width - 2, canvasBG.height - 2, '#3f5c67');

    var x = 10;
    var y = 10;

    canvasBG.addToWorld(x, y);
    canvasSprite = canvas.addToWorld(x + 1, y + 1);
    canvasGrid = game.add.sprite(x + 1, y + 1, 'drawingGrid');
    canvasGrid.crop(new Phaser.Rectangle(0, 0, spriteWidth * canvasZoom, spriteHeight * canvasZoom));


    //activeCellIndication.rect(0, 0, canvasBG.width / 2, canvasBG.height / 2, '#0f0');

}

function resizeCanvas() {

    canvas.resize(spriteWidth * canvasZoom, spriteHeight * canvasZoom);
    canvasBG.resize(canvas.width + 2, canvas.height + 2);

    canvasBG.rect(0, 0, canvasBG.width, canvasBG.height, '#fff');
    canvasBG.rect(1, 1, canvasBG.width - 2, canvasBG.height - 2, '#3f5c67');

    canvasGrid.crop(new Phaser.Rectangle(0, 0, spriteWidth * canvasZoom, spriteHeight * canvasZoom));

}

function createPreview() {

    preview = game.make.bitmapData(spriteWidth * previewSize, spriteHeight * previewSize);
    previewBG = game.make.bitmapData(preview.width + 2, preview.height + 2);

    previewBG.rect(0, 0, previewBG.width, previewBG.height, '#fff');
    previewBG.rect(1, 1, previewBG.width - 2, previewBG.height - 2, '#3f5c67');

    var x = rightCol;
    var y = 350;

    previewBG.addToWorld(x, y);
    preview.addToWorld(x + 1, y + 1);

}

function resizePreview() {

    preview.resize(spriteWidth * previewSize, spriteHeight * previewSize);
    previewBG.resize(preview.width + 2, preview.height + 2);

    previewBG.rect(0, 0, previewBG.width, previewBG.height, '#fff');
    previewBG.rect(1, 1, previewBG.width - 2, previewBG.height - 2, '#3f5c67');

}

function refresh() {

    //  Update both the Canvas and Preview
    canvas.clear();
    preview.clear();

    for (var y = 0; y < spriteHeight; y++)
    {
        for (var x = 0; x < spriteWidth; x++)
        {
            var i = data[y][x];

            if (i !== '.' && i !== ' ')
            {
                color = game.create.palettes[palette][i];
                canvas.rect(x * canvasZoom, y * canvasZoom, canvasZoom, canvasZoom, color);
                preview.rect(x * previewSize, y * previewSize, previewSize, previewSize, color);
            }
        }
    }

}

function createEventListeners() {

    keys = game.input.keyboard.addKeys(
        {
            //'erase': Phaser.Keyboard.X,
            'up': Phaser.Keyboard.UP,
            'down': Phaser.Keyboard.DOWN,
            'left': Phaser.Keyboard.LEFT,
            'right': Phaser.Keyboard.RIGHT
        }
    );

    //keys.erase.onDown.add(cls, this);
    keys.up.onDown.add(sendTop, this);
    keys.down.onDown.add(sendBottom, this);
    keys.left.onDown.add(sendLeft, this);
    keys.right.onDown.add(sendRight, this);

    game.input.mouse.capture = true;
    game.input.onDown.add(onDown, this);
    game.input.onUp.add(onUp, this);
    game.input.addMoveCallback(paint, this);
}

function cls() {

    resetData();
    refresh();

}


function drawPalette() {

    //  Draw the palette to the UI bmd
    ui.clear(0, 0, 32 * 16, 32);

    var x = 0;

    for (var clr in game.create.palettes[palette])
    {
        ui.rect(x, 0, 32, 32, game.create.palettes[palette][clr]);
        x += 32;
    }

    ui.copy('uiGrid');

}

function sendLeft() {
    sendAction('left');
}

function sendRight() {
    sendAction('right');
}

function sendTop() {
    sendAction('top');
}

function sendBottom() {
    sendAction('bottom');
}

function sendAction(action) {
    var data = {
        "from_x": currentX,
        "from_y": currentY,
        "direction": action,
        "player_name": $("#player").val()
    };
    if (!timer) {
        /*$.post('/move', data, function(data) {
            timerCount = 1;
            timer = setInterval(timerHandler, 1000);

            console.log(data);
        });*/
        doSend("move", data);
        timerCount = 1;
        timer = setInterval(timerHandler, 1000);
    }
}

function increaseSize(sprite) {

    if (sprite.name === 'width')
    {
        if (spriteWidth === 16)
        {
            return;
        }

        spriteWidth++;
    }
    else if (sprite.name === 'height')
    {
        if (spriteHeight === 16)
        {
            return;
        }

        spriteHeight++;
    }

    resetData();
    resizeCanvas();
    resizePreview();

    widthText.text = "Current X: " + currentX;
    heightText.text = "Current Y: " + currentY;

}

function decreaseSize(sprite) {

    if (sprite.name === 'width')
    {
        if (spriteWidth === 4)
        {
            return;
        }

        spriteWidth--;
    }
    else if (sprite.name === 'height')
    {
        if (spriteHeight === 4)
        {
            return;
        }

        spriteHeight--;
    }

    resetData();
    resizeCanvas();
    resizePreview();

    widthText.text = "Width: " + spriteWidth;
    heightText.text = "Height: " + spriteHeight;

}

function increasePreviewSize() {

    if (previewSize === 16)
    {
        return;
    }

    previewSize++;
    previewSizeText.text = "Size: " + previewSize;

    resizePreview();
    refresh();

}

function decreasePreviewSize() {

    if (previewSize === 1)
    {
        return;
    }

    previewSize--;
    previewSizeText.text = "Size: " + previewSize;

    resizePreview();
    refresh();

}

function timerHandler() {
    timerLabel.text = "Timer: " + (timerCount--);
    if (timerCount < 0) {
        clearInterval(timer);
        timer = null;
    }
}

function loadState() {
    $.getJSON("/state", function(data){
        //data = $.parseJson(data);

        Cells = data.cells;

        updateFractions(data.fractions);
        updatePlayers(data.players);
        drawCells(Cells);
    });
}

function drawCells(cells) {
    $.each(cells, function(i,cell){
        paint2({x: cell.x, y: cell.y, color: cell.color });
    });
}

function updateFractions(fractions){
    Fractions = fractions;
}

function updatePlayers(players){
    Players = players;
    var playersContainer = $('#players-container');
    $.each(players, function(i,player){
        playersContainer.append('<li> <a href="#"  onClick="$(\'#player\').val(' + player.fraction + '); return false;">' + player.color + '</a></li>')
    });
}

function updatePlayer(player){
    Player = player;
    $('#player').val(player.color)
}


function shiftLeft() {

    canvas.moveH(-canvasZoom);
    preview.moveH(-previewSize);

    for (var y = 0; y < spriteHeight; y++)
    {
        var r = data[y].shift();
        data[y].push(r);
    }

}

function shiftRight() {

    canvas.moveH(canvasZoom);
    preview.moveH(previewSize);

    for (var y = 0; y < spriteHeight; y++)
    {
        var r = data[y].pop();
        data[y].splice(0, 0, r);
    }

}

function shiftUp() {

    canvas.moveV(-canvasZoom);
    preview.moveV(-previewSize);

    var top = data.shift();
    data.push(top);

}

function shiftDown() {

    canvas.moveV(canvasZoom);
    preview.moveV(previewSize);

    var bottom = data.pop();
    data.splice(0, 0, bottom);

}

function onDown(pointer) {

    /*if (pointer.y <= 32)
     {
     setColor(game.math.snapToFloor(pointer.x, 32) / 32);
     }
     else
     {
     isDown = true;

     if (pointer.rightButton.isDown)
     {
     isErase = true;
     }
     else
     {
     isErase = false;
     }

     paint(pointer);
     }*/

}


function onUp(pointer) {
    var x = game.math.snapToFloor(pointer.x - canvasSprite.x, canvasZoom) / canvasZoom;
    var y = game.math.snapToFloor(pointer.y - canvasSprite.y, canvasZoom) / canvasZoom;

    if (x < 0 || x >= spriteWidth || y < 0 || y >= spriteHeight)
    {
        return;
    }

    if (data[y][x] == $('#player').val() /*player.color*/) {
        currentX = x;
        currentY = y;
        widthText.text = "Current X: " + currentX;
        heightText.text = "Current Y: " + currentY;
        activeCellIndication.highLight(x, y);
    }
}

function paint(pointer) {

    //  Get the grid loc from the pointer
    var x = game.math.snapToFloor(pointer.x - canvasSprite.x, canvasZoom) / canvasZoom;
    var y = game.math.snapToFloor(pointer.y - canvasSprite.y, canvasZoom) / canvasZoom;

    if (x < 0 || x >= spriteWidth || y < 0 || y >= spriteHeight)
    {
        return;
    }

    coords.text = "X: " + x + "\tY: " + y;

    if (!isDown)
    {
        return;
    }

    if (isErase)
    {
        data[y][x] = '.';
        canvas.clear(x * canvasZoom, y * canvasZoom, canvasZoom, canvasZoom, color);
        preview.clear(x * previewSize, y * previewSize, previewSize, previewSize, color);
    }
    else
    {
        //data[y][x] = pmap[colorIndex];
        canvas.rect(x * canvasZoom, y * canvasZoom, canvasZoom, canvasZoom, color);
        preview.rect(x * previewSize, y * previewSize, previewSize, previewSize, color);
    }

}

function paint2(pointer) {

    //  Get the grid loc from the pointer
    var x = pointer.x;
    var y = pointer.y;

    if (x < 0 || x >= spriteWidth || y < 0 || y >= spriteHeight)
    {
        return;
    }

    coords.text = "X: " + x + "\tY: " + y;



    if (isErase)
    {
        data[y][x] = '.';
        canvas.clear(x * canvasZoom, y * canvasZoom, canvasZoom, canvasZoom, color);
        preview.clear(x * previewSize, y * previewSize, previewSize, previewSize, color);
    }
    else
    {
        data[y][x] = pointer.color;
        canvas.rect(x * canvasZoom, y * canvasZoom, canvasZoom, canvasZoom, pointer.color);
        preview.rect(x * previewSize, y * previewSize, previewSize, previewSize, pointer.color);
    }

}

function startWebSocket() {
    websocket = new WebSocket("ws:/" + window.location.hostname + ":4567/");
    websocket.onopen = function(evt) { onOpen(evt) };
    websocket.onclose = function(evt) { onClose(evt) };
    websocket.onmessage = function(evt) { onMessage(evt) };
    websocket.onerror = function(evt) { onError(evt) };
}

function onOpen(evt) {
    console.log("CONNECTED");
    //doSend("WebSocket rocks");
}

function onClose(evt) {
    console.log("DISCONNECTED");
}

function onMessage(evt) {
    console.log(evt);
    var data = $.parseJSON(evt.data);

    if (data.cells instanceof Array) {
        drawCells(data.cells);
    }
}

function onError(evt) {
    console.error(evt)
}

function doSend(eventName, data) {
    websocket.send(JSON.stringify(
        {
            eventName: eventName,
            data: data
        }
    ));
}
