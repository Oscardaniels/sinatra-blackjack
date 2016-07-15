 $(document).ready(function() {
  $('#hit_form input').click(function(){
    $.ajax({
      type: 'POST',
      url: '/game/player/hit'
    }).done(function(msg){
      alert(msg);
    });





    return false;
  });
});