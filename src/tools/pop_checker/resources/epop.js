
$(document).ready(function() {
		$("div.account").after("<div id=\"log\"></div>");
		/*
		$('#messages div.message').click(function() {
			readEmail($(this));
			}
		);
		*/
		$('#messages div.message div.synopsis > a').click(function() {
			readEmail($(this));
			}
		);
		$('#messages div.message div.line span.header-opt > a').click(function() {
			readEmail($(this));
			//$(this).stopPropagation();
			//return false;
			}
		);

		loadJS("jquery.textarearesizer.js");
		loadJS("jquery.autogrow.js");
		//logThis("Extra loading succeed");
		loadToolbar();
		logThis("Start completed");
	}
);

function loadToolbar() {
	msgs = $("#messages .info")
	msgs.prepend("<div id=\"toolbar\"></div>");
	tb = $("#toolbar", msgs);
	tb.append ("<form><input type=\"checkbox\" checked name=\"details\">details</input></form>");

	$("form", tb).submit(function () { return false; }); // so it won't submit
	$('form [name=details]', tb).click(function() {
			applyDetailsOption($(this));
		}
	);
}

function logThis(msg) {
	$("#log").stop(true,true);
	$("#log").fadeIn("normal");
	$("#log").append("<div>" + msg + "</div>");
	$.ajax({
		url: "#",
		type: "GET",
		dataType: "text",
		timeout: 1000,
		success: function(txt) { $("#log").fadeOut(6000, function() { $("#log").empty(); }) }
	});

}
function loadJS(file) {
	//fn = file;
	fn = "../../res/" + file;
	try {
		$.getScript(fn, function(){ logThis("[" + fn + "] loaded"); });
	} catch (error) {
		logThis("Could not load script [" + fn + "]");
	}
}

var last_message_url="";

function restore_href_on_link(a_link, a_url) {
	//logThis("restore href=" + a_url + " instead of " + a_link.attr("href"));
	a_link.attr("href", a_url);
}

function applyDetailsOption(e) {
	if (e) {
		d = e;
	} else {
		d = $('#messages form [name=details]');
	}
	if (d) {
		if (d.attr("checked")) { 
			showDetails(); 
		} else { 
			hideDetails(); 
		} 
	}
}


function showDetails(m) {
	logThis("Show details");
	if (m) {
		$(".details", m).fadeIn(); 
	} else {
		$(".details").each(function() { $(this).fadeIn(); });
	}
}
function hideDetails(m) {
	logThis("Hide details");
	if (m) {
		$(".details", m).fadeOut(); 
	} else {
		$(".details").each(function() { $(this).fadeOut(); });
	}
}

function readEmail(t) {
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
			error: function() { restore_href_on_link(e, url_to_restore); },
			success: function(txt) { restore_href_on_link(e, url_to_restore); }
		});
	} else {
		cleanRead();
		last_message_url = url;
		message_div.prepend ("<a id=\"popa\" name=\"read\" />");
		message_div.append("<div id=\"popb\"/>");
		pop = $("#popb")
		pop.empty();
		pop.append("<div id=\"popt\">");
		//pop.append (e.text())
		pop.append ("<div id=\"loading\">loading ... <span class=\"loading\"/></div>\n");
		pop.append ("</div>\n");
		pop.show("normal");
		$("#loading .loading").animate({ width: "90%"}, {queue:true, duration: 3000 })
			.animate({width: "10%"} , 1500);

		showDetails(message_div);

		$.ajax({
			url: url,
			type: "GET",
			dataType: "text",
			timeout: 1000,
			error: function() { alert ("Error loading: " + url); restore_href_on_link(e, url); },
			success: function(html) {  restore_href_on_link(e, url); showMessage(html,pop); }
		});

	}
}

function cleanRead() {
	$("#popb").each(function(){ $(this).remove(); });
	$("#popa").each(function(){ $(this).remove(); });
	applyDetailsOption();
}

function showMessage(m,e) {
	$("#loading", e).each(function(){ $(this).remove(); });
	//e.append("<textarea cols='100' rows='25' wrap='soft' readonly>" + m + "</textarea>");
	e.append("<div class=\"resizable-textarea\"><textarea>" + m + "</textarea></div>");

	//$('textarea.resizable:not(.processed)').TextAreaResizer();
	try { $('textarea').TextAreaResizer(); } catch (error) { logThis("TextAreaResizer: Exception raised in showMessage(..)"); }
	try { $('textarea').autogrow(); } catch (error) { logThis("autogrow: Exception raised in showMessage(..)"); }
}
