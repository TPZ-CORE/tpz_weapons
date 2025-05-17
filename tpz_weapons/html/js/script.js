

document.addEventListener('DOMContentLoaded', function() { 
  $("#weapons").fadeOut(); 
}, false);

function CloseNUI() {
  $("#weapons").fadeOut();
	$.post('http://tpz_weapons/close', JSON.stringify({}));
}

$(function() {

	window.addEventListener('message', function(event) {
		
    var item = event.data;

		if (item.type == "enable") {
			document.body.style.display = item.enable ? "block" : "none";

      if (item.enable) {
        $("#weapons").fadeIn(1000);
      }

    } else if (item.action == 'updatePlayerAccountInformation'){

      $("#main-account-dollars").text("$" + Math.round(item.accounts.dollars));

    } else if (item.action == "close") {
      CloseNUI();
    }

  });
  
});
