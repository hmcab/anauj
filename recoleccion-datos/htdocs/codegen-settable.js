
var bar_state = null;
	    
function change_state_bar()
{
    var ntable = document.getElementById("spanntablev").innerHTML;
    
    if (bar_state) {
	set_style_bar(false);
	bar_state = false;
	ntable += ":off";
    } else {
	set_style_bar(true);
	bar_state = true;
	ntable += ":on";
    }
    document.getElementById("settable").value = ntable;
    var ftable = document.getElementById("ftable");
    ftable.submit();
}
function set_state_bar() 
{
    var bar = document.getElementById("bar");
    var act = bar.getAttribute("class");
    
    if (act == "on") {
	set_style_bar(true);
	bar_state = true;
    } else {
	set_style_bar(false);
	bar_state = false;
    }
}
function set_style_bar(on)
{
    var left = document.getElementById("side_left");
    var right = document.getElementById("side_right");
    var label = document.getElementById("label");
    if (on) {
	left.style.backgroundColor = "#dff2bf";
	right.style.backgroundColor = "#dff2bf";
	label.style.color = "#000000";
	label.innerHTML = "on";
    } else {
	left.style.backgroundColor = "#000000";
	right.style.backgroundColor = "#000000";
	label.style.color = "#ffffff";
	label.innerHTML = "off";
    }
}
