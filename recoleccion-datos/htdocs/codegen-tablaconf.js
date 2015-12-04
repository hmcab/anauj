
// ***
// Restriccion de valores
// Solo numeros para tamfisico
// Manejo apropiado para < y >
// ***

// edit_text edit_select edit_textarea
parent = null;
input = null;
select = null;
textarea = null;
save = null;
cancel = null;
remove = null;
oldvalue = null;
idcomp = null;

libre = true;

// -------------------------------------------- Restriccion de campos

function checkcontent(data, comp) 
{
	switch (comp)
	{
		case "textarea":
		{
			//if (/^[0-9a-zA-Z\s-_\[\]\",]+$/.test(data) &&
			// a-zA-z0-9_
			if (/^[\w{1,}\s\[\]\",]+$/.test(data) &&
				verificarLista(data)) {
				return true;
			} else {
				return false;
			}
			break;
		}
		case "text":
		{
			// a-zA-Z_-espacio
			if (!(/^\s+$/.test(data)) && /^[a-zA-Z_\-\s]+$/.test(data)) {
				return true;
			} else {
				return false;
			}
			break;
		}
		case "num":
		{
			// 0-9
			if (/^[0-9]+$/.test(data)) {
				return true;
			} else {
				return false;
			}
			break;
		}
	}
	return false;
}

// -------------------------------------------- Configuracion de tabla

function edit_field(comp, nomcomp)
{
	if (libre) {
	
		if (nomcomp == 'label' || nomcomp == 'tamfisico') 
		{
			edit_text(comp, nomcomp); // text
		}
		else if (nomcomp == 'opciones')
		{
			edit_textarea(comp, nomcomp); // textarea
		} else
		{
			edit_select(comp,nomcomp); // select
		}
		libre = false;
	}
}

// -------------------------------------------- textarea

function edit_textarea(comp, nomcomp) 
{
	var value = comp.innerHTML;
	oldvalue = value;
	idcomp = nomcomp;
	
	textarea = document.createElement("textarea");
	textarea.setAttribute("id", "idtextarea");
	
	save = document.createElement("button");
	cancel = document.createElement("button");
	remove = document.createElement("button");
	contsave = document.createTextNode("Guardar");
	contcancel = document.createTextNode("Cancelar");
	contremove = document.createTextNode("Remover lista");
	save.appendChild(contsave);			
	cancel.appendChild(contcancel);
	remove.appendChild(contremove);
	
	parent = comp.parentNode;
	
	save.onclick = save_textarea;
	cancel.onclick = cancel_textarea;
	remove.onclick = remove_list_textarea;
	
	//input.setAttribute("id", "idtextarea");
	textarea.setAttribute("rows", "10");
	textarea.setAttribute("cols", "20");
	//textarea.setAttribute("value", value);
	contarea = document.createTextNode(value);
	textarea.appendChild(contarea);			
	
	parent = comp.parentNode;
	
	parent.removeChild(comp);
	parent.appendChild(textarea);
	parent.appendChild(save);
	parent.appendChild(cancel);
	parent.appendChild(remove);
	//comp.parentNode.appendChild(button);
}

function save_textarea() // ---------------------- check content
{
	//var newvalue = input.getAttribute("value");
	var newvalue = document.getElementById("idtextarea").value;
	
	if (checkcontent(newvalue, "textarea"))
	{
		parent.removeChild(textarea);
		parent.removeChild(save);
		parent.removeChild(cancel);
		parent.removeChild(remove);
		
		if (idcomp != null) {
			var newtextarea = null;
			if (newvalue == null || newvalue == "") {
				newtextarea = "<span onclick=edit_field(this,'"+idcomp+"');>"+oldvalue+"</span>";	
			} else {
				newtextarea = "<span onclick=edit_field(this,'"+idcomp+"');>"+newvalue+"</span>";
			}
			parent.innerHTML = newtextarea;
		}
		reset_comps();
	}
	else {
		document.getElementById("div_msgerror").innerHTML = "<span>*</span> Especificación del campo es incorrecto.";
	}	
}

function cancel_textarea()
{
	parent.removeChild(textarea);
	parent.removeChild(save);
	parent.removeChild(cancel);
	parent.removeChild(remove);
	
	if (idcomp != null) {
		var oldtextarea = "<span onclick=edit_field(this,'"+idcomp+"');>"+oldvalue+"</span>";
		parent.innerHTML = oldtextarea;
	}
	
	reset_comps();
}

function remove_list_textarea() 
{
	parent.removeChild(textarea);
	parent.removeChild(save);
	parent.removeChild(cancel);
	parent.removeChild(remove);
	
	var emptytextarea = "<span onclick=edit_field(this,'"+idcomp+"');>opciones</span>";
	parent.innerHTML = emptytextarea;
	
	reset_comps();
}

// -------------------------------------------- select

function edit_select(comp,nomcomp)
{
	var value = comp.innerHTML;
	oldvalue = value;
	idcomp = nomcomp;
	
	select = document.createElement("select");
	select.setAttribute("id", "idselect");
	
	save = document.createElement("button");
	cancel = document.createElement("button");
	contsave = document.createTextNode("Guardar");
	contcancel = document.createTextNode("Cancelar");
	save.appendChild(contsave);			
	cancel.appendChild(contcancel);
	
	parent = comp.parentNode;
	
	save.onclick = save_select;
	cancel.onclick = cancel_select;

	opcs = []; rest = false;
	
	if (nomcomp == 'tipoelemt' ||
		nomcomp == 'restriccion' ||
		nomcomp == 'show')
	{
		if (nomcomp == 'tipoelemt') {
			opcs = ["text", "select", "select_date", "checkbox", "radio", "password", "textarea"]; // hidden
		}
		else if (nomcomp == 'restriccion') {
			opcs = ["numérico entero [0-9]", "numérico real [.0-.9]", "alfanumérico [a-z0-9]", "alfabético [a-z]", "alfanumérico_esp [a-z0-9*]", "booleano", "email"];
			opcsr = ["numerico", "numericoReal", "alfanumerico", "alfabetico", "alfanumerico_esp", "booleano", "email"];
			rest = true;
		}
		else {
			opcs = ["t", "f"];
		}
			
		for (var i=0; i<opcs.length; i++) 
		{
			option = document.createElement("option");
			if (rest) {
				option.setAttribute("value", opcsr[i]);
				optioncont = document.createTextNode(opcs[i]);
			} else {
				option.setAttribute("value", opcs[i]);
				optioncont = document.createTextNode(opcs[i]);
			}
			option.appendChild(optioncont);
			select.appendChild(option);
		}
		
		rest = false;
		parent.removeChild(comp);
		parent.appendChild(select);
		parent.appendChild(save);
		parent.appendChild(cancel);
	}
}

function save_select()
{
	var newvalue = document.getElementById("idselect").value;
	parent.removeChild(select);
	parent.removeChild(save);
	parent.removeChild(cancel);
	
	if (idcomp != null) {
		var newselect = null;
		if (newvalue == null || newvalue == "") {
			newselect = "<span onclick=edit_field(this,'"+idcomp+"');>"+oldvalue+"</span>";
		} else {
			newselect = "<span onclick=edit_field(this,'"+idcomp+"');>"+newvalue+"</span>";
		}	
		parent.innerHTML = newselect;
	}
	
	reset_comps();
}

function cancel_select()
{
	parent.removeChild(select);
	parent.removeChild(save);
	parent.removeChild(cancel);
	
	if (idcomp != null) {
		var oldselect = "<span onclick=edit_field(this,'"+idcomp+"');>"+oldvalue+"</span>";
		parent.innerHTML = oldselect;
	}
	
	reset_comps();
}

// -------------------------------------------- text

function edit_text(comp, nomcomp) 
{
	var value = comp.innerHTML;
	oldvalue = value;
	idcomp = nomcomp;

	input = document.createElement("input");
	save = document.createElement("button");
	cancel = document.createElement("button");
	contsave = document.createTextNode("Guardar");
	contcancel = document.createTextNode("Cancelar");
	
	save.appendChild(contsave);			
	cancel.appendChild(contcancel);
	save.onclick = save_text;
	cancel.onclick = cancel_text;
	
	input.setAttribute("id", "idtext");
	input.setAttribute("type", "text");
	input.setAttribute("value", value);
	
	parent = comp.parentNode;
	
	parent.removeChild(comp);
	parent.appendChild(input);
	parent.appendChild(save);
	parent.appendChild(cancel);
	//comp.parentNode.appendChild(button);
}

function save_text() // ---------------------- check content
{
	//var newvalue = input.getAttribute("value");
	var newvalue = document.getElementById("idtext").value;
	var type = "";
	
	// Edicion de campo label o tamfisico
	if (/^label$/.test(idcomp)) {
		type = "text";
	}
	else if (/^tamfisico$/.test(idcomp)) {
		type = "num";
	}
	
	if (checkcontent(newvalue,type))
	{	
		parent.removeChild(input);
		parent.removeChild(save);
		parent.removeChild(cancel);
		
		if (idcomp != null) {
			var newtext = null;
			if (newvalue == null || newvalue == "") {
				newtext = "<span onclick=edit_field(this,'"+idcomp+"');>"+oldvalue+"</span>";
			} else {
				newtext = "<span onclick=edit_field(this,'"+idcomp+"');>"+newvalue+"</span>";
			}
			parent.innerHTML = newtext;
		}
		
		reset_comps();
	} else {
		document.getElementById("div_msgerror").innerHTML = "<span>*</span> Especificación del campo es incorrecto.";
	}
}

function cancel_text()
{
	parent.removeChild(input);
	parent.removeChild(save);
	parent.removeChild(cancel);
	
	if (idcomp != null) {
		var oldtext = "<span onclick=edit_field(this,'"+idcomp+"');>"+oldvalue+"</span>";
		parent.innerHTML = oldtext;
	}
	
	reset_comps();
}

function reset_comps()
{
	parent = null;
	input = null;
	select = null;
	textarea = null;
	save = null;
	cancel = null;
	remove = null;
	oldvalue = null;
	idcomp = null;
	libre = true;
}

function modf_table() 
{
	var data = "";
	
	var nesquema = document.getElementById("spanschemav").innerHTML;
	var ntabla = document.getElementById("spanntablev").innerHTML;
	
	var table = document.getElementById ("table_campos");
	
	for (var i = 0; i < table.rows.length; i++) 
	{
		var row = table.rows[i];
		for (var j = 0; j < row.cells.length; j++) 
		{
			var cell = row.cells[j];
			var span = cell.getElementsByTagName("span");
			span = span[0];
			if (span != undefined) {
				//message += i + ". row " + j + ". cell: " + span + "\n";
				//data += span.innerHTML;
				if (j < row.cells.length-1) {
					data += span.innerHTML + ":";
				} else {
					//alert(span.innerHTML); opciones
					//data += span.innerHTML;					
					//data += "opciones";
					// :v-m,v-m&
					var lst = span.innerHTML;
					var nlst = "";
					if (verificarLista(lst)) {
						nlst = crearLista(lst);
					} else {
						nlst = "";
					}
					data += nlst;
				}
			}
		}
		if (data != "" && i < table.rows.length-1)
			data += "&"
	}
	
	//alert(data);
	//verificarLista("");
	
	// Enviamos datos para modificar tabla de conf
	var fmtablas = document.getElementById("fmtablas");
	document.getElementById("nmtabla").value = ntabla;
	document.getElementById("dmtabla").value = data;
	fmtablas.submit();
}

// -----------------------------------------------------------------------------
// Verificacion y creacion de lista para conf de tabla
// -----------------------------------------------------------------------------

function verificarLista(lst) 
{
	var pass = true;
	var pattern = /^\[(\"\w+\")\s+(\"\w+\")\]$/;
	var array = lst.split(/,/);
	
	for (var i=0; i<array.length; i++) {
		var sublst = array[i];
		if (!pattern.test(sublst)) {
			pass = false;
			break;
		}
	}
	return pass;
}

function crearLista(lst) 
{
	// Formato mas simple va ma, vb mb, vc mc ,vdmd (Intentar)
	// Primero chequear si formato es ["a" "va"],["b" "vb"],["c" "vc"]
	// var pattern = /^\[(\"\w+\")\s+(\"\w+\")\]$/; // work
	
	//var pattern = /^\[(\"\w+\")\s+(\"\w+\")\]$/; // work
	var pattern = /^\[(\"[0-9a-zA-Z\-\s\_]+\")\s+(\"[0-9a-zA-Z\-\s\_]+\")\]$/; // work
	var array = lst.split(/,/);
	
	var nlst = "";
	for (var i=0; i<array.length; i++) {
		var sublst = array[i];
		if (pattern.test(sublst)) {
			var vyv = "";
			if (i <array.length-1)
				vyv = sublst.replace(pattern, "$1-$2,");
			else
				vyv = sublst.replace(pattern, "$1-$2");
			//alert(vyv);
			nlst += vyv;
		}
	}
	return nlst;
}
