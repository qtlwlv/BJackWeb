$(document).ready(function(){
  player_hit();
  player_stay();
});

function player_hit() {
  $(document).on("click", "form#hit input", function() {
    alert("Player Hits!");
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}

function player_stay() {
  $(document).on("click", "form#stay input", function() {
    alert("Player Stays!");
    $.ajax({
      type: 'POST',
      url: '/game/player/stay'
    }).done(function(msg){
      $("div#game").replaceWith(msg);
    });
    return false;
  });
}


