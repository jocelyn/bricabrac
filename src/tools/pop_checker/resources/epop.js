
$(document).ready(function() {
		$("div.account").after("<div id=\"log\" ></div>");
		/*
		$('#messages div.message').click(function() {
			readEmail($(this));
			}
		);
		*/
		$('#messages div.message div.line > a').click(function() {
			readEmail($(this));
			}
		);
		$('#messages div.message div.line span.header-opt > a').click(function() {
			readEmail($(this));
			//$(this).stopPropagation();
			//return false;
			}
		);

		logThis("Start succeed");

		loadJS("jquery.textarearesizer.js");
		loadJS("jquery.autogrow.js");
		//logThis("Extra loading succeed");
	}
);

function logThis(msg) {
	$("#log").fadeIn("normal");
	$("#log").append("<div>" + msg + "</div>");
	$.ajax({
		url: "#",
		type: "GET",
		dataType: "text",
		timeout: 1000,
		success: function(txt) { $("#log").fadeOut(9000, function() { $("#log").empty(); }) }
	});

}
function loadJS(file) {
	$.getScript(file, function(){ logThis("[" + file + "] loaded"); });
}

var last_message_url="";

function readEmail(t) {
 logThis ("tag=" + t.attr("tagName") + "id=" + t.attr("id") + "class=" + t.attr("class"));
	if (t.attr("tagName") == "A") {
		e = t;
	} else {
 alert ("tag=" + t.attr("tagName") + "id=" + t.attr("id") + "class=" + t.attr("class"));
		e = $("div.line a", t);
	}
	url = "" + e.attr("href");
	logThis("Read " + url);
	//alert("old=" + last_message_url + " new=" + url);

	e.attr("href","#read");
	//$(this).removeAttr("href");

	message_div = e.parents(".message");

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
	//e.append("<textarea cols='100' rows='25' wrap='soft' readonly>" + m + "</textarea>");
	e.append("<div class=\"resizable-textarea\"><textarea>" + m + "</textarea></div>");

	//$('textarea.resizable:not(.processed)').TextAreaResizer();
	$('textarea').TextAreaResizer();
	$('textarea').autogrow();
	//$("textarea").addClass("jq");
}
