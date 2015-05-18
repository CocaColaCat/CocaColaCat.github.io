
var gameBoard;
var snake;
var food = {};

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

function endGame(){

};

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
    // case ESC:
    //   endGame();
    //   break;
  }
};

function startGame(){
  gameBoard = new GameBoard();
  var gameSpeed = 100;

  // snake = new Snake(80, 80);
  // snake.onCrash(snakeCrashHandler);
  gameExecutor = setInterval(gameSpeed, move)

};


function move(){
  generateFood();
  // snake.move();
  // if(snake.onFoodPosition())
    // eatFood();

  // updateScore();
};

function generateFood(){
  if(food == undefined){
    food.xPos = 100;//Random.(1..400);
    food.yPos = 100;//Random.(1..400);
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

function snake(startX, startY){

  var bodyParts = [new BodyPart(startX,startY,'right')];

  this.getBody = function(){
    return bodyParts;
  };

};

function GameBoard(){

  this.drawBoard = function(){

  };

  this.drawFood = function(){
    $('#gameField').append("<div id='food' style='margin-top="+food.xPos+";margin-left="+food.yPos+"'></div>");
  };
};

