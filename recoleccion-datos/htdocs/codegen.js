
// Enviar nombre de tabla, que esta bajo los
// li, para imprimir la tabla de configuracion
function make_table(comp)
{
	//alert("make table of configuration.");
	var vcomp = comp.getAttribute("id");
	document.getElementById("ntabla").value = vcomp;
	//alert(vcomp);
	//document.forms[0].submit();
	var ftablas = document.getElementById("ftablas");
	ftablas.submit();
}

function save_schema()
{
	//alert("save schema to file.");
	var fschema = document.getElementById("fschema");
	fschema.submit();
}

function export_app()
{
	//alert("export app.");
	var fapp = document.getElementById("fapp");
	fapp.submit();
}

function exec_app()
{
    //alert("exec app.");
    var fexec = document.getElementById("fexec");
    fexec.submit();
}

function view_table()
{
	//alert("view table.");
	var fvtablas = document.getElementById("fvtablas");
	fvtablas.submit();
}

//function init(){
//	var table = document.getElementById("table_campos");
//}

// Menu flotante
var prev_act = "none";
function show_menu_float(from)
{
	var menu = document.getElementById("menufloat");

	if (from == "elemt") {
		menu.style.display = "block";
	
		if (prev_act == "none_inter") {
			prev_act = "none";
			menu.style.display = "none";
		} else {
			prev_act = "elemt";
		}
	} else if (from == "body" && prev_act == "elemt") {
		prev_act = "none_inter";
	} else {
		prev_act = "none";
		menu.style.display = "none";		    
	} 
}

// Info case
var prev_act_info = "none";
var prev_info = null;

function hidden_all_except(id)
{
	var allinfo = document.getElementsByName("info_case");
	var sizinfo = allinfo.length;
	
	for (var i=0; i<sizinfo; i++) {
		var idi = allinfo[i].getAttribute("id");
		if (idi != id) {
			allinfo[i].style.display = "none";
		}
	}
}

function show_info_aux(from, id)
{
	hidden_all_except(id);
	
	var info = document.getElementById(id);
	if (from == "elemt") {
		info.style.display = "block";
		
		if (prev_act_info == "none_inter" && prev_info == info) {
			prev_act_info = "none";
			info.style.display = "none";
		} else {
			prev_act_info = "elemt";
		}
	} else if (from == "body" && prev_act_info == "elemt") {
		prev_act_info = "none_inter";
	} else {
		prev_act_info = "none";
		info.style.display = "none";		
	}
	prev_info = info;
}
function show_info(id)
{
	show_info_aux("elemt", id);
}

function show_comps(from)
{
	show_menu_float(from);
	if (prev_info != null) {
		show_info_aux(from, prev_info.getAttribute("id"));
	} else {
		hidden_all_except("none");
	}
}
