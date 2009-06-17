$(document).ready(function() {
		/*
		$('#messages div.message div.line a').click(function() {
			readEmail($(this));
			}
		);
		*/
		$('#messages div.message').click(function() {
			readEmail($(this));
			}
		);
	}
);

var last_message_url="";

function readEmail(t) {
	// if (last_message) { last_message.fadeOut("slow"); }
	e = $("div.line a", t);
	url = "" + e.attr("href");
	//alert("old=" + last_message_url + " new=" + url);

	e.attr("href","#read");
	//$(this).removeAttr("href");

	message_div = e.parents(".message");
	/*
	message_div.unbind('click');
	message_div.click(function() {
				cleanRead();
				$(this).click(function() { readEmail($(this)); });
			}
		);
	*/

	if (url == last_message_url) {
		cleanRead();
		url_to_restore = "" + last_message_url;
		last_message_url = "";
		$.ajax({
			url: "#",
			type: "GET",
			dataType: "text",
			timeout: 1,
			error: function() { e.attr("href", url_to_restore); },
			success: function(txt) { e.attr("href", url_to_restore); }
		});
	} else {
		cleanRead();
		last_message_url = url;
		message_div.prepend ("<a id=\"popa\" name=\"read\" />");
		message_div.append("<div id=\"popb\"/>");
		pop = $("#popb")
		pop.empty();
		pop.append("<div id=\"popt\">" + e.text() + "</div>\n");
		/*
		$("#popt").click(function() {
				$(this).parent().remove();
				});
		*/
		pop.show("normal");
		$.ajax({
			url: url,
			type: "GET",
			dataType: "text",
			timeout: 1000,
			error: function() { alert ("Error loading: " + url); e.attr("href", url); },
			success: function(html) { showMessage(html,pop); e.attr("href", url); }
		});
	}
}

function cleanRead() {
	$("#popb").each(function(){ $(this).remove(); });
	$("#popa").each(function(){ $(this).remove(); });
}

function showMessage(m,e) {
	e.append("<textarea cols='100' rows='25' wrap='soft' readonly>" + m + "</textarea>");
}
