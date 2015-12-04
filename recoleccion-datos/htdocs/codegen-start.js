
var pass = null;
var msg = null;

// Registro de usuario

function checkRest(comp)
{
	var parent = comp.parentNode; // entrada
	var pparent = parent.parentNode; // todo
	var span = pparent.getElementsByTagName("span");
	var category = comp.getAttribute("class");
	var label;
	
	// span - titulo
	span = span[0];
	if (category != "radio") {
		label = span.innerHTML;
	} else if (category == "radio") {
		// parent : label
		// pparent : entradain
		// ppparent : entrada
		// pppparent : todo
		var ppparent = pparent.parentNode; // entrada
		var pppparent = ppparent.parentNode; // todo
		span = pppparent.getElementsByTagName("span");
		span = span[0];
		label = span.innerHTML;
	}
	
	var value = null;
	if (category == "radio") {
		var lstradio = document.getElementsByName(comp.getAttribute("name"));
		for (var i=0; i<lstradio.length; i++) {
			if (lstradio[i].checked) {
				value = lstradio[i].value;
			}
		}
	} else {
		value = comp.value;
	}
	
	if (value == null || value == "") {
		msg = "<span>*</span> Campo -" + label + "- debe ser especificado.";
		document.getElementById("divmsg").innerHTML = msg;
		return false;
	} 
	
	if (!checkField(comp,category)) {
		document.getElementById("divmsg").innerHTML = msg;
		return false;
	} else {
		msg = "";
		document.getElementById("divmsg").innerHTML = msg;
		return true;
	}
}

function checkField(comp, category) {
	var value = comp.value;
    switch(category) {
        
        case 'alfabetico':
            if (/^[a-zA-Z\s]+$/.test(value)) {
                return true;
            } else {
				msg = "<span>*</span> Sólo se permiten caracteres del alfabeto.";
                return false;
            }
            break;           
            
        case 'pass':
			if (value.length >= 8 &&				
					(/[a-z]/.test(value)) &&
					(/[0-9]/.test(value)) &&
					(/\W+/.test(value)) &&
					!(/\s+/.test(value)))
					 {
				pass = value;
				return true;
			} else {
				msg = "<span>*</span> Contraseña debe ser al menos de 8 caracteres que combine números, letras y símbolos como (!, &). Sin espacios.";
				return false;
			}
			break;
			
		case 'cpass':
			if (pass != null && pass == value) {
				return true;
			} else if (pass != null && pass != value) {
				msg = "<span>*</span> Contraseñas no coinciden.";
				return false;
			} else if (pass == null) {
				msg = "<span>*</span> Contraseña no aceptada.";
				return false;
			}
			break;
        
        case 'email':
            if( !(/\w{1,}[@][\w\-]{1,}([.]([\w\-]{1,})){1,3}$/.test(value)) ) {
                msg = "<span>*</span> Especifique un correo electrónico.";
                return false;
            } else {				
                return true;
            }
            break;
		
		case 'radio':
			if (value != null || value != "") {
				return true;
			} else {
				return false;
			}			
			break;
    }
    return false;
}

function registrar() 
{
	var freg = document.getElementById("freg");
	for (var i=0; i<freg.length; i++) {
		var elemt = freg[i].getAttribute("type");
		if (elemt == "text" ||
			elemt == "radio" ||
			elemt == "password") {
			if (!checkRest(freg[i])) {
				//alert(elemt);
				pass = null;
				document.getElementById("pass").value = "";
				document.getElementById("cpass").value = "";
				return;
			}
		}
	}
	freg.submit();
}

// Inicio de sesión
function iniciar()
{
	var user = document.getElementById("user").value;
	var pass = document.getElementById("pass").value;
	
	var schema = document.getElementById("schema");
	schema = schema.options[schema.selectedIndex];
	schema = schema.value;
	
	if (user == null || user == "") {
		var str = "<span>*</span> Especifique un usuario.";
		document.getElementById("divmsg").innerHTML = str;
		return;
	}
	if (pass == null || pass == "") {
		var str = "<span>*</span> Especifique la contraseña";
		document.getElementById("divmsg").innerHTML = str;
		return;
	}
	if (schema == null || schema == "") {
		var str = "<span>*</span> Seleccione un esquema de base de datos.";
		document.getElementById("divmsg").innerHTML = str;
		return;
	}
	
	document.getElementById("flogin").submit();
}
