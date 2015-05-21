
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
  // gameBoard.clearBoard();
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
  if(snake.onFoodPosition())
    eatFood();
  updateScore();
};

function eatFood(){
  snake.eatFood();
};

function generateFood(){
  if(food.xPos == undefined){
    food.xPos = Math.floor(Math.random()*50)*8;
    food.yPos = Math.floor(Math.random()*50)*8;
    gameBoard.drawFood();
  }
};

function updateScore(){
  gameBoard.updateScore();
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
    return bodyParts.length;
  };

  this.move = function(){
    gameBoard.clearBody();
    newHead = this.getNewHead();
    bodyParts.pop();
    bodyParts.unshift(newHead);
    gameBoard.drawBody();
    this.checkCollision();
  };

  this.head = function(){
    return bodyParts[0];
  };

  this.tail = function(){
    return bodyParts[this.length()-1];
  };

  this.checkCollision = function(){
    if (this.head().xPos < 0 || this.head().xPos > 392 || this.head().yPos < 0 || this.head().yPos > 392){
      endGame();
      clearInterval(gameExecutor);
      alert('crash on border, game end');
    }
  };

  this.onFoodPosition = function(){
    if (this.head().xPos == food.xPos && this.head().yPos == food.yPos){
      return true;
    }else{
      return false;
    }
  };

  this.eatFood = function(){
    newTail = this.getNewTail();
    bodyParts.push(newTail);
    food = {}
    gameBoard.clearFood();
    gameBoard.drawBody();
  };

  this.getNewTail = function(){
    currentTail = this.tail();
    switch(moveDirection){
      case 'right':
        return new BodyPart(currentTail.xPos-8,currentTail.yPos,moveDirection);
        break;
      case 'left':
        return new BodyPart(currentTail.xPos+8,currentTail.yPos,moveDirection);
        break;
      case 'up':
        return new BodyPart(currentTail.xPos,currentTail.yPos+8,moveDirection);
        break;
      case 'down':
        return new BodyPart(currentTail.xPos,currentTail.yPos-8,moveDirection);
        break;
    }
  };

  this.getNewHead = function(){
    currentHead = this.head();
    switch(moveDirection){
      case 'right':
        return new BodyPart(currentHead.xPos+8,currentHead.yPos,moveDirection);
        break;
      case 'left':
        return new BodyPart(currentHead.xPos-8,currentHead.yPos,moveDirection);
        break;
      case 'up':
        return new BodyPart(currentHead.xPos,currentHead.yPos-8,moveDirection);
        break;
      case 'down':
        return new BodyPart(currentHead.xPos,currentHead.yPos+8,moveDirection);
        break;
    }
  };

};

function GameBoard(){

  this.drawBody = function(){
    bodyParts = snake.getBody();
    for (var i = 0; i < bodyParts.length ; i++) {
      $('#gameField').append("<div class='bodyPart' style='top:"+bodyParts[i].yPos+"px;left:"+bodyParts[i].xPos+"px'></div>")
    }
  };

  this.clearBoard = function(){
    this.clearFood();
    this.clearBody();
  };

  this.clearFood = function(){
    $('#food').remove();
  };

  this.clearBody = function(){
    $('.bodyPart').remove();
  };

  this.drawFood = function(){
    $('#gameField').append("<div id='food' style='top:"+food.yPos+"px;left:"+food.xPos+"px'></div>");
  };

  this.updateScore = function(){
    // console.log(snake.length());
    $('#gameScore').html(snake.length());
  };

};

