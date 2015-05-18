
var gameBoard;
var snake;
var food = {};
var gameExecutor;

var score;

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
  // alert(code);
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
    food.xPos = Math.floor(Math.random()*392+1);
    food.yPos = Math.floor(Math.random()*392+1);
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

  this.move = function(){
    newHead = this.getNewHead();
    bodyParts
    gameBoard.drawBody();
  };

};

function GameBoard(){

  this.drawBody = function(){
    bodyParts = snake.getBody
  };

  this.clearBoard = function(){
    $('#food').remove();
  };

  this.drawFood = function(){
    $('#gameField').append("<div id='food' style='margin-top:"+food.xPos+"px;margin-left:"+food.yPos+"px'></div>");
  };
};

