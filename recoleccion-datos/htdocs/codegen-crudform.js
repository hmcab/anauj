
conntg = null;
nschema = null;
ntable = null;
nprocd = null;
funcsql = null;
camposql = null;
restsql = null;

boolidx = false;
gidx = -1;

boolpidx = false;
pidx = -1;

updel = false;

function seleccion_funcion()
{
	var func = document.getElementById("funcionsql").value;
	if (func != null && func != "") {
		funcsql = func;
		conntg = "AND";
		mostrar_componente("div_create", true);
	} else {
		funcsql = null;
		mostrar_componente("div_create", false);
	}
	
	var table = document.getElementById("ntable").value;
	var schema = document.getElementById("nschema").value;
	nschema = schema;
	ntable = table;
}

function mostrar_componente(create, show) 
{
	var create = document.getElementById(create);
	if (show) {
		create.style.display = "block";
		// enfocamos componente
		posy = create.offsetTop-45;
		window.scrollTo(0,posy);
	} else {
		create.style.display = "none";
	}
}

function mostrar_componente_per(create, show)
{
	var create = document.getElementById(create);
	if (show) {
		create.style.display = "block";
		// enfocamos componente
		posy = create.offsetTop-45;
		window.scrollTo(0,posy);
	} else {
		create.style.display = "none";
	}
}

function addcampo()
{
	var campos = document.getElementById("campos");
	var icampos = campos.getElementsByTagName("input");
	var str = "";
	for (var i=0; i<icampos.length; i++) {
		if (icampos[i].checked) {
			if (str == "") {
				str = icampos[i].value;
			} else {
				str += "," + icampos[i].value;
			}					
		}
	}
	if (camposql == null || camposql == "") {
		camposql = str;
	} else {
		camposql += "," + str;
	}
	
	// resturamos graficamente los campos
	for (var i=0; i<icampos.length; i++) {
		icampos[i].checked = false;
	}
	
	parsetosql();
}

function addrestriccion()
{
	var camposr = document.getElementById("camposr");
	var icamposr = camposr.getElementsByTagName("input");
	
	var connt = document.getElementById("div_conector");
	var iconnt = connt.getElementsByTagName("input");
	
	var ct = "";
	if (iconnt[0].checked) {
		ct = iconnt[0].value;
	} else if (iconnt[1].checked) {
		ct = iconnt[1].value;
	} else {
		ct = "AND";
	}
	ct += ",";
	
	var str = ""; var ncmp = 0;
	for (var i=0; i<icamposr.length; i++) {
		if (icamposr[i].checked) {
			if (str == "") {
				str = icamposr[i].value;
			} else {
				str += "," + icamposr[i].value;
			}
			ncmp += 1;
		}
	}
	if (ncmp > 1) {
		str = ct + str;
	} else {
		str = str;
	}
	
	if (str != null && str != "") {
		if (restsql == null || restsql == "") {
			restsql = str;
		} else {
			restsql += ";" + str;
		}
	}

	// resturamos graficamente los campos
	for (var i=0; i<icamposr.length; i++) {
		icamposr[i].checked = false;
	}
	iconnt[0].checked = false;
	iconnt[1].checked = false;
	
	parsetosql();
}

function remcampo()
{
	if (camposql != null & camposql != "") {
		if (camposql.indexOf(",")) {
			var lastcomma = camposql.lastIndexOf(",");
			var newcamposql = camposql.substr(0, lastcomma);
			camposql = newcamposql;				
		} else {
			camposql = "";
		}
	}
	parsetosql();
}

function remrestriccion()
{
	if (restsql != null && restsql != "") {
		if (restsql.indexOf(";")) {
			var lastsemicomma = restsql.lastIndexOf(";");
			var newrestsql = restsql.substr(0,lastsemicomma);
			restsql = newrestsql;
		} else {
			restsql = "";
		}
	}
	parsetosql();
}

function parsetosql()
{
	var sql = "";
	sql = funcsql;
	
	if (camposql != null && camposql != "") {
		if (camposql.indexOf(",")) {
			var arrayc = camposql.split(",");
			sql += " " + arrayc[0];
			for (var i=1; i<arrayc.length; i++) {
				sql += ", " + arrayc[i];
			}
		} else {
			sql += " " + camposql;
		}
	}
	
	sql += " FROM " + ntable;
	
	if (conntg == null || conntg == "")
		conntg = "AND";
	
	if (restsql != null && restsql != "") {
		if (restsql.indexOf(";")) {
			var arrayr = restsql.split(";");
			var rs = "";
			for (var i=0; i<arrayr.length; i++) {
				var r = arrayr[i]; var r2 = "";
				if (r.indexOf(",")) {
					var arrayr2 = r.split(",");
					r2 = "(" + arrayr2[0];
					for (var j=1; j<arrayr2.length; j++) {
						r2 += " " + arrayr2[j];
					}
					r2 += ")";
				} else {
					r2 = r;
				}
				
				if (rs == "") {
					rs = r2;
				} else {
					//rs += " AND " + r2;
					rs += ", " + r2;
				}
			}
			sql += " WHERE " + rs;
			sql += " [" + conntg + "]";
		} else {
			sql += " WHERE " + restsql;
		}
	}
	
	if ((camposql == null || camposql == "") &&
		(restsql == null || restsql == "")) {
			sql = "";
	}
	
	document.getElementById("sql_text").innerHTML = sql;
}

function parsetosqlgui()
{
	var nfuncsql = funcsql;
	var lst = document.getElementById("funcionsql").options;
	var size = lst.length;
	
	for (var i=0; i<size; i++) {
		if (lst[i].value == funcsql) {
			document.getElementById("funcionsql").options[i].selected = 'selected';
		}
	}
	
	document.getElementById("nprocd").value = nprocd;
	document.getElementById("sql_text").innerHTML = "";			
	parsetosql();
}

// NombreSchema&NombreID&Nombre_tabla&Sentencia_SQL&Campos&Restricciones (6)
// NOMBRESCH&NOMID&NTABLA&INSERT&CAMPO1,CAMPO2&AND,CAMPO1,CAMPO2;OR,CAMPO3,CAMPO4;CAMPO5
// camposql = campo1,campo2,...,campoN
// restsql = rest1;AND,rest2,rest3;OR,rest4,rest5;rest6

// Tabla de sentencias CRUD
crud = null;
// CRUD personalizadas
crud_per = "";

function render_table()
{
	var divtable = document.getElementById("div_tabla");
	var tablecrud = document.getElementById("tabla_crud");
	
	if (tablecrud != null)
		divtable.removeChild(tablecrud);
	
	var table = document.createElement("table");
	table.setAttribute("id", "tabla_crud");
	table.setAttribute("name", "tabla_crud");
	var thead = document.createElement("thead");
	var tbody = document.createElement("tbody");
	
	if (crud != null)
	{
		var head = ["N", "Nombre de la tabla", "Nombre de operación", "Tipo de operación"];
		var size = crud.length;
		
		// Titulo
		var trt = document.createElement("tr");
		var tht = document.createElement("th");
		tht.setAttribute("colspan","6");
		tht.setAttribute("class","titulo");
		tht.appendChild(document.createTextNode("Tabla de configuración de funciones CRUD"));
		trt.appendChild(tht);
		thead.appendChild(trt);
		table.appendChild(thead);
		
		// Encabezado
		var tr = document.createElement("tr");
		for (var j=0; j<head.length; j++) {
			var th = document.createElement("th");
			th.appendChild(document.createTextNode(head[j]));
			tr.appendChild(th);
		}
		tr.appendChild(document.createElement("th")); // editar
		tr.appendChild(document.createElement("th")); // eliminar
		thead.appendChild(tr);
		table.appendChild(thead);
		
		for (var i=0; i<size; i++) {
			var tr = document.createElement("tr");
			
			// indice
			var tdn = document.createElement("td");
			tdn.appendChild(document.createTextNode(i+1));
			tr.appendChild(tdn);
			
			// campos (-conntg -nschema +ntable +nprocd +funcsql -camposql -restsql)
			var datacrud = crud[i].split("&");
			var sizecdc = 4;
			
			for (var j=2; j<=sizecdc; j++) {
				var td = document.createElement("td");
				td.appendChild(document.createTextNode(datacrud[j]));
				tr.appendChild(td);
			}
			
			// edit - del
			var tde = document.createElement("td");
			var tdd = document.createElement("td");
			var edit = document.createElement("button");
			var del = document.createElement("button");
			
			edit.appendChild(document.createTextNode("editar"));
			del.appendChild(document.createTextNode("eliminar"));
			edit.setAttribute("id", "editbutton");
			del.setAttribute("id", "delbutton");
			edit.setAttribute("onclick", "edit_func("+i+");");
			del.setAttribute("onclick", "del_func("+i+");");
			
			tde.appendChild(edit);
			tdd.appendChild(del);
			
			tr.appendChild(tde);
			tr.appendChild(tdd);
			
			//edit.onclick = edit_func;
			//del.onclick = del_func;
			
			tbody.appendChild(tr);
		}
		table.appendChild(tbody);
		divtable.appendChild(table);
	}
}

function render_table_per()
{
	var data      = document.getElementById("div_crud_per").innerHTML;
	var datasplit = data.split("%");
	var datafmt   = "";
	crud_per      = "";
	
	var div_per   = document.getElementById("div_tabla_per");
	var tabla_per = document.getElementById("tabla_crud_per");
	
	if (tabla_per != null)
		div_per.removeChild(tabla_per);
		
	var table = document.createElement("table");
	table.setAttribute("id","tabla_crud_per");
	table.setAttribute("name", "tabla_crud_per");
	var thead = document.createElement("thead");
	var tbody = document.createElement("tbody");
	
	var head = ["N", "Nombre de la tabla", "Nombre de operación", "Tipo de operación"];
	
	if (data != null && datasplit.length > 0 && datasplit[0] != "")
	{
		var rows = datasplit.length;
		
		// Titulo
		var trt = document.createElement("tr");
		var tht = document.createElement("th");
		tht.setAttribute("colspan","6");
		tht.setAttribute("class","titulo");
		tht.appendChild(document.createTextNode("Tabla de configuración de funciones CRUD personalizadas"));
		trt.appendChild(tht);
		thead.appendChild(trt);
		table.appendChild(thead);
		
		// Encabezado
		var tr = document.createElement("tr");
		for (var j=0; j<head.length; j++) {
			var th = document.createElement("th");
			th.appendChild(document.createTextNode(head[j]));
			tr.appendChild(th);
		}
		tr.appendChild(document.createElement("th")); // editar
		tr.appendChild(document.createElement("th")); // eliminar
		thead.appendChild(tr);
		table.appendChild(thead);
		
		for (var i=0; i<rows; i++)
		{
			var tr = document.createElement("tr");
			
			// indice
			var tdn = document.createElement("td");
			tdn.appendChild(document.createTextNode(i+1));
			tr.appendChild(tdn);
			
			var datass = datasplit[i].split("&amp;");
			
			datafmt = "";
			for (var j=0; j<datass.length; j++) {
				if (datafmt == "")
					datafmt = datass[j];
				else
					datafmt += "&" + datass[j];
			}
			
			// campos
			for (var k=1; k<=3; k++) {
				var td = document.createElement("td");
				td.appendChild(document.createTextNode(datass[k]));
				tr.appendChild(td);
			}
			
			// edit-del
			var tde  = document.createElement("td");
			var tdd  = document.createElement("td");
			var edit = document.createElement("button");
			var del  = document.createElement("button");
			
			edit.appendChild(document.createTextNode("editar"));
			del.appendChild(document.createTextNode("eliminar"));
			edit.setAttribute("id", "editbutton");
			del.setAttribute("id", "delbutton");
			edit.setAttribute("onclick", "edit_func_per("+i+");");
			del.setAttribute("onclick", "del_func_per("+i+");");
			
			tde.appendChild(edit);
			tdd.appendChild(del);
			
			tr.appendChild(tde);
			tr.appendChild(tdd);
			
			tbody.appendChild(tr);
			
			if (crud_per == "")
				crud_per = datafmt;
			else
				crud_per += "%" + datafmt;
		}
		table.appendChild(tbody);
		div_per.appendChild(table);
	}
}

function addsql(str) 
{
	if (crud == null) {
		crud = new Array();
		crud[0] = str;
	} else {
		size = crud.length;
		ncrud = new Array(size);
		for (var i=0; i<size; i++) {
			ncrud[i] = crud[i];
		}
		crud = new Array(size+1);
		for (var i=0; i<size; i++) {
			crud[i] = ncrud[i];
		}
		crud[i] = str;
	}
	render_table();
}

function modsql(str, idx) 
{
	if (crud != null) {
		crud[idx] = str;
	}
}

function modsql_per(str, idx)
{
	if (crud_per != "")
	{
		var datasplit  = crud_per.split("%");
		datasplit[idx] = str;
		
		crud_per = datasplit[0];
		for (var i=1; i<datasplit.length; i++) {
			crud_per += "%" + datasplit[i];
		}
	}
}

function edit_func(idx)
{
	// campos (nschema ntable nprocd funcsql -camposql -restsql)
	conntg = nschema = ntable = nprocd = funcsql = camposql = restsql = null;
	boolidx = true;
	gidx = idx;
	
	if (crud != null)
	{
		var data = crud[idx].split("&");
		
		conntg   = data[0];
		nschema  = data[1];
		ntable   = data[2];
		nprocd   = data[3];
		funcsql  = data[4];
		camposql = data[5];
		
		if (data.length > 6) {
			restsql = data[6];
		}
		
		parsetosqlgui();
		mostrar_componente("div_create", true);
	}
}

function del_func(idx)
{
	if (crud != null)
	{				
		size = crud.length;
		if (size > 1) {
			var ncrud = new Array(size-1);
			var j=0;
			
			for (var i=0; i<size; i++) {
				if (i == idx) {
					continue;
				} else {
					ncrud[j] = crud[i];
					j++;
				}
			}
			crud = new Array(size-1);
			for (var i=0; i<size-1; i++) {
				crud[i] = ncrud[i];
			}
		} else {
			crud = null;
		}
	}
	render_table();
	reset_gui();
	//save_crud_in_file();
}

function edit_func_per(idx)
{
	if (crud_per != "")
	{
		var datasplit = crud_per.split("%");
		var size = datasplit.length;
		
		var nprocd_per, lsql, datafmt;
		nprocd_per = lsql = datafmt = "";
		
		if (idx >= 0 && idx < size)
		{
			datafmt    = datasplit[idx].split("&");
			nprocd_per = datafmt[2];
			lsql       = datafmt[4];
			
			document.getElementById("nprocd_per").value = nprocd_per;
			document.getElementById("lsql").innerHTML   = lsql;
			document.getElementById("lsql").value       = lsql;
			// Simular presionamiento de tecla
			simulateKeyPress('[',"lsql");
			
			boolpidx = true;
			pidx = idx;
			
			mostrar_componente_per("div_create_per",true);
		}
	}
}

function del_func_per(idx)
{
	if (crud_per != "")
	{
		var datasplit = crud_per.split("%");
		var size = datasplit.length;
		
		var datafmt = "";
		
		for(var i=0; i<size; i++)
		{
			if (i != idx)
			{
				if (datafmt == "")
					datafmt = datasplit[i];
				else
					datafmt += "%" + datasplit[i];
			}
		}
		
		crud_per = datafmt;
		document.getElementById("div_crud_per").innerHTML = crud_per;
		
		render_table_per();
	}
}

function save_sql()
{
	nprocd = document.getElementById("nprocd").value;

	if ((nschema  != null && nschema  != "") &&
		(ntable   != null && ntable   != "") &&
		(nprocd   != null && nprocd   != "") &&		
		(funcsql  != null && funcsql  != "") &&
		(camposql != null && camposql != "")) 
	{
		// !(/^\s+$/.test(nprocd))) 
		if (/^[a-zA-Z_\-\/]+$/.test(nprocd))
		{
			var sqlf = conntg +"&"+ nschema +"&"+ ntable +"&"+ nprocd +"&"+ funcsql +"&"+ camposql;
			
			if (restsql != null && restsql != "") {
				sqlf += "&" + restsql;
			}
			
			if (boolidx && gidx >= 0) {
				modsql(sqlf,gidx);
			} else {
				addsql(sqlf);
			}
			document.getElementById("msg_cruderror").innerHTML = "";
			reset_gui();
		} else {
			var nomproc_error = "<p>*</p> Especificación del nombre del procedimiento es incorrecto.";
			document.getElementById("msg_cruderror").innerHTML = nomproc_error;
		}
	}
}

function save_sql_per()
{
	var nschema_per = document.getElementById("nschema_per").value;
	var ntable_per  = document.getElementById("ntable_per").value;
	var nprocd_per  = document.getElementById("nprocd_per").value;
	var fsql_per    = document.getElementById("fsql_per").value;
	var campos_per  = document.getElementById("lcampos").value;
	var rests_per   = document.getElementById("lrest").value;
	var sql_per     = document.getElementById("lsql").value;
	
	var div_crud_per      = document.getElementById("div_crud_per");
	var msg_crudper_error = document.getElementById("msg_crudper_error");
	
	
	if ((nschema_per != null && nschema_per != "") &&
		(ntable_per  != null && ntable_per  != "") &&
		(nprocd_per  != null && nprocd_per  != "") &&
		(campos_per  != null && campos_per  != "") &&
		(fsql_per    != null && fsql_per    != "") &&
		(sql_per     != null && sql_per     != ""))
	{
		if (/^[a-zA-Z_\-\/]+$/.test(nprocd_per))
		{
			var data = nschema_per +"&"+ ntable_per +"&"+ nprocd_per;
			data += "&" + fsql_per +"&"+ sql_per; // +"&"+ campos_per;
			
			// Agrega _per a cada restriccion
			//rests_per = fix_rests(rests_per);
			
			if (fsql_per == "SELECT" && rests_per != "" ||
				fsql_per == "UPDATE" && updel 			|| 
				fsql_per == "DELETE")
			{
				data += "&" + rests_per;
				
			} else if (fsql_per == "INSERT" ||
					   fsql_per == "UPDATE" && !updel) { //(fsql_per != "SELECT") {
				
				data += "&" + campos_per;
				if (rests_per != "")
					data += "," + rests_per;
					
			} else {
				
				return;
			}
			
			// Comprobamos formacion de la instruccion SQL
			if (check_sql_per(fsql_per, sql_per))
			{
				// Modificamos o añadimos nueva conf CRUD personalizada
				if (boolpidx && pidx >= 0)
				{
					modsql_per(data,pidx);
					
				} else
				{
					if (crud_per == "") {
						crud_per = data;
					} else {
						crud_per += "%" + data;
					}
				}
				
				div_crud_per.innerHTML = crud_per;
				msg_crudper_error.innerHTML = "";
				
				reset_gui_per();
				render_table_per();
			
			} else {
				
				var sql_error = "<p>*</p> Especificación de instrucción SQL es incorrecta.";
				msg_crudper_error.innerHTML = sql_error;
			}
			
		} else
		{
			var nomproc_error = "<p>*</p> Especificación del nombre del procedimiento es incorrecto.";
			msg_crudper_error.innerHTML = nomproc_error;
		}
	}
}

function check_sql_per(fsql_per, sql_per)
{
	// insert into tabla () values ()
	// select () from tabla where ()
	// update tabla set () where ()
	// delete from tabla where ()
	
	var insert_into = sql_per.indexOf("insert into ");
	var select      = sql_per.indexOf("select ");
	var update      = sql_per.indexOf("update ");
	var delete_from = sql_per.indexOf("delete from ");
	
	var values      = sql_per.indexOf("values ");
	var from        = sql_per.indexOf("from ");
	var where       = sql_per.indexOf("where ");
	var set_        = sql_per.indexOf("set ");
	
	switch (fsql_per)
	{
		case "INSERT":
			if (insert_into >= 0 && values > insert_into) {
				return true;
			}
			break;
		
		case "SELECT":
			if (select >= 0 && from > select && where > from) {
				return true;
			}
			break;
		
		case "UPDATE":
			if (update >= 0 && set_ > update && where > set_) {
				return true;
			}
			break;
		
		case "DELETE":
			if (delete_from >= 0 && where > delete_from) {
				return true;
			}
			break;
	}
	return false;
}

function fix_rests(rts)
{
	if (rts != "")
	{
		var larray  = rts.split(",");
		var lsize   = larray.length;
		var nrts    = "";
		
		for (var i=0; i<lsize; i++)
		{
			if (nrts == "") {
				nrts = larray[i] + "_per";
			} else {
				nrts += "," + larray[i] + "_per";
			}
		}
		return nrts;
	}
	return rts;
}

function cancel_sql()
{
	reset_gui();
}
function cancel_sql_per()
{
	reset_gui_per()
}

function reset_gui()
{
	conntg = null;
	nschema = null;
	ntable = null;
	nprocd = null;
	funcsql = null;
	camposql = null;
	restsql = null;
	
	boolidx = false;
	gidx = -1;
	
	document.getElementById("funcionsql").options[0].selected = 'selected';
	document.getElementById("conntg").options[0].selected = 'selected';
	document.getElementById("nprocd").value = "";
	document.getElementById("sql_text").innerHTML = "";
	document.getElementById("msg_cruderror").innerHTML = "";
	
	mostrar_componente("div_create", false);
}

function reset_gui_per()
{
	boolpidx = false;
	pidx = -1;
	
	updel = false;
	
	document.getElementById("nprocd_per").value = "";
	document.getElementById("fsql_per").value = "";
	document.getElementById("lcampos").innerHTML = "";
	document.getElementById("lrest").innerHTML = "";
	document.getElementById("lsql").innerHTML = "";
	document.getElementById("lsql").value = "";
	document.getElementById("updel").checked = false;
	document.getElementById("msg_crudper_error").innerHTML = "";
	document.getElementById("lstmatch").innerHTML = "";
	
	mostrar_componente("div_create_per", false);
}

function save_crud_in_file()
{
	var str = "";
	var actualtable = document.getElementById("ntable").value;
	
	if (crud != null)
	{
		var size = crud.length;
		
		// Guardamos solo los datos de la tabla actual
		// no todos los de la estructura.
		
		for (var i=0; i<size; i++) {
			var row = crud[i].split("&");
			var ntable = row[2]; // ntable
			if (ntable == actualtable)
			{
				if (str == "") {
					str = crud[i];
				} else {
					str += "%" + crud[i];
				}
			}
		}
		
		document.getElementById("datacrud").value = str;
		var fcrud = document.getElementById("fcrud");
		fcrud.submit();
	}
	else
	{
		// Para remover las configuraciones de una tabla en especifico
		// en la estructura racket. Ocurre cuando el usuario elimina
		// todas las configuraciones bajo la interfaz grafica.
		str = "remove_crud_table:" + actualtable;
		document.getElementById("datacrud").value = str;
		var fcrud = document.getElementById("fcrud");		
		fcrud.submit();
	}
	
	// Preparamos y guardamos todas las configuraciones
	// CRUD personalizadas.
		
	if (crud_per != "")
	{
		document.getElementById("datacrudp").value = crud_per;
		var fcrudp = document.getElementById("fcrudp");
		fcrudp.submit();
	} 
	else
	{
		str = "remove_crud_per_table:" + actualtable;
		document.getElementById("datacrudp").value = str;
		var fcrudp = document.getElementById("fcrudp");
		fcrudp.submit();
	}
}

function load_crud()
{
	var tabla_aux = document.getElementById("tabla_crud_aux");
	if (tabla_aux != null) 
	{		
		for (var i=0; i<tabla_aux.rows.length; i++) 
		{
			var row = tabla_aux.rows[i];
			for (var j=0; j<row.cells.length; j++) 
			{
				var cell = row.cells[j];
				var span = cell.getElementsByTagName("span");
				span = span[0];
				if (span != undefined)
				{
					var data = span.innerHTML;
					var datasplit = data.split("&amp;"); 
					// Lamentablemente convierte separador & en &amp;
					
					// conntg nschema ntable nprocd funcsql camposql *restsql
					var size = datasplit.length;
					
					str = datasplit[0];
					str += "&" + datasplit[1];
					str += "&" + datasplit[2];
					str += "&" + datasplit[3];
					str += "&" + datasplit[4];
					str += "&" + datasplit[5];
					
					if (size > 6) {
						str += "&" + datasplit[6];
					}
					
					addsql(str); 
				}
			}
		}
	}
	render_table_per();
}

function setconntg()
{
	conntg = document.getElementById("conntg").value;
	if (conntg == null || conntg == "")
		conntg = "AND";
	parsetosql();
}

function simulateKeyPress(chr,elemt)
{
	try
	{
		var pressEvent = document.createEvent('KeyboardEvent');
		pressEvent.initKeyEvent("keypress",true,true,window,
								false,false,false,false,
								0, chr.charCodeAt(0));
		
		var input = document.getElementById(elemt);
		
		input.dispatchEvent(pressEvent);
	} catch (e) {
		alert("Tu navegador no soporta función de simulación de tecleo! Lo sentimos.");
	}
}

function activar_updel(comp)
{
	if (comp.checked) {
		updel = true;
	} else {
		updel = false;
	}
}

function init_crudform()
{
	mostrar_componente("div_create", false);
	mostrar_componente_per("div_create_per", false);
	document.getElementById("lcampos").setAttribute("readonly","true");
	document.getElementById("lrest").setAttribute("readonly","true");
	document.getElementById("sql_text").setAttribute("readonly","true");
	load_crud();
}

function init()
{
	// codegen-crudform
	init_crudform();
	// codegen-crudpers
	init_crudpers();
	// codegen-settable
	set_state_bar();	
}
