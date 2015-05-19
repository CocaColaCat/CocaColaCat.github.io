
var gameBoard;
var snake;
var food = {};
var gameExecutor;

var score;

var moveDirection;

// game keys
var SPACE = 32;
var ESC = 27;
var LEFT_ARROW = 37;
var RIGHT_ARROW = 39;
var UP_ARROW = 38;
var DOWN_ARROW = 40;

$(document).ready(function(){
  $('body').keydown(keyPressedHandler);
});

function keyPressedHandler(e){
  code = (e.keyCode? e.keyCode : e.which);
  console.log(code);
  switch(code){
    case LEFT_ARROW:
      moveDirection = 'left';
      break;
    case RIGHT_ARROW:
      moveDirection = 'right';
      break;
    case UP_ARROW:
      moveDirection = 'up';
      break;
    case DOWN_ARROW:
      moveDirection = 'down';
      break;
    case SPACE:
      startGame();
      break;
    case ESC:
      endGame();
      break;
  }
};

function endGame(){
  food = {};
  gameBoard.clearBoard();
  clearInterval(gameExecutor);
};

function startGame(){
  gameBoard = new GameBoard();
  var gameSpeed = 100;
  moveDirection = 'right';

  snake = new Snake(80,80);
  // snake.onCrash(snakeCrashHandler);
  gameExecutor = setInterval(move, gameSpeed)
};

function move(){
  generateFood();
  snake.move();
  // if(snake.onFoodPosition())
    // eatFood();

  // updateScore();
};

function generateFood(){
  if(food.xPos == undefined){
    food.xPos = Math.floor(Math.random()*50+1)*8;
    food.yPos = Math.floor(Math.random()*50+1)*8;
    gameBoard.drawFood();
  }
};


function snakeCrashHandler(){
  endGame();
};

function BodyPart(x,y,direction){
  this.xPos = x;
  this.yPos = y;
  this.direction = direction;
};

function Snake(startX, startY){

  var bodyParts = [new BodyPart(startX,startY,'right')];

  this.getBody = function(){
    return bodyParts;
  };

  this.length = function(){
    return bodyParts.length
  };

  this.move = function(){
    gameBoard.clearBody();
    newHead = this.getNewHead();
    // console.log(newHead);
    for (var i = 0; i < this.length() - 1 ; i++) {
      bodyParts[i+1] = bodyParts[i];
    }
    bodyParts[0] = newHead;
    gameBoard.drawBody();
    this.checkCollision();
  };

  this.head = function(){
    return bodyParts[0];
  };

  this.checkCollision = function(){
    console.log(this.head());
    if (this.head().xPos < 0 || this.head().xPos > 400 || this.head().yPos < 0 || this.head().yPos > 400){
      endGame();
      // clearInterval(gameExecutor);
      alert('crash on border, game end');
    }
  };

  this.getNewHead = function(){
    currentHead = bodyParts[0];
    switch(moveDirection){
      case 'right':
        return new BodyPart(currentHead.xPos,currentHead.yPos+8,'right');
        break;
      case 'left':
        return new BodyPart(currentHead.xPos,currentHead.yPos-8,'left');
        break;
      case 'up':
        return new BodyPart(currentHead.xPos-8,currentHead.yPos,'up');
        break;
      case 'down':
        return new BodyPart(currentHead.xPos+8,currentHead.yPos,'down');
        break;
    }

  };

};

function GameBoard(){

  this.drawBody = function(){
    bodyParts = snake.getBody();
    for (var i = 0; i < bodyParts.length ; i++) {
      $('#gameField').append("<div class='bodyPart' style='top:"+bodyParts[i].xPos+"px;left:"+bodyParts[i].yPos+"px'></div>")
    }
  };

  this.clearBoard = function(){
    $('#food').remove();
    this.clearBody();
  };

  this.clearBody = function(){
    $('.bodyPart').remove();
  };

  this.drawFood = function(){
    $('#gameField').append("<div id='food' style='top:"+food.xPos+"px;left:"+food.yPos+"px'></div>");
  };

};

