$(document).ready(function() {
	delete_line = function(event) {
		// Because you can click on the <i> element too
		var url = event.target.href || $(event.target).closest('a')[0].href;
		$(event.target).parents('tr').remove();
		// AJAX Call to the deletion method
		$.ajax({"url": url});
	}

	$('a.launch').bind('click', function(event){
		event.preventDefault();
		$.get(this.href, {}, function(response) { }) })

	$('a.remove').bind('click', function(event) {
		event.preventDefault();
		// If you press CTROL+Delete item, it will be deleted without confirmation
		if (event.ctrlKey) { delete_line(event); return; }
		// Change the messages when asking confirmation. That makes the UI more "human" ;)
		if (Math.random()*10 >= 5) {
			var yes = "Yes, I want to delete it";
			var no = "No, I don't want to delete it";
		} else {
			var yes = "Hell yes!";
			var no = "Nooop!";
		}
		bootbox.dialog("Do you really want to delete this element?", [
			{ "label" : no, "callback": function() {} },
			{ "label" : yes, "class" : "btn-danger", "callback": function() {delete_line(event)}
		}]);
	});
});
