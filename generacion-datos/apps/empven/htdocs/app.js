
// Reparar orden de elementos div bajo
// form-real
function fixOrderFormDivs()
{
    var formreal = document.getElementById("form-real");
    var divs = formreal.getElementsByTagName("div");

    var size = divs.length;    
    
    var formtmp = document.createElement("ftmp");
    var div = formreal.lastChild;
    while (div != null) {
        var divc = div.cloneNode(true);
        formtmp.appendChild(divc);
        formreal.removeChild(div);
        div = formreal.lastChild;
    }
    
    formreal = document.getElementById("form-real");
    var ndiv = formtmp.firstChild;
    while (ndiv != null) {
        var divc = ndiv.cloneNode(true);
        formreal.appendChild(divc);
        formtmp.removeChild(ndiv);
        ndiv = formtmp.firstChild;
    }
}

function init()
{
    //alert("init");
    fixOrderFormDivs();
    document.getElementById("msgrest").style.display = "none";
}

felemt = null;

function process_crud_form(nameform)
{
    // Recojemos nombres de elementos del form-a-ejecutar (_crud)
    // quitamos _crud
    var form = document.getElementById(nameform);
    var elemts = form.getElementsByTagName("input");
    
    felemt = null;
    for (var i=0; i<elemts.length; i++) 
    {
        var nelemt = elemts[i].getAttribute("id");
        if (nelemt != null)
        {
            var crud = "_crud";
            var size = nelemt.length;
            var csize = crud.length;
            nelemt = nelemt.substr(0,size-csize);
            addelemt(nelemt);
        }
    }
    
    var formreal = document.getElementById("form_real"); 
    
    // Tomamos los valores de los elementos del form-real que
    // coincidan con los del form-a-ejecutar previamente
    // recolectados
    for (var i=0; i<felemt.length; i++)
    {
        // real form element
        var realElemt = document.getElementById(felemt[i]);
        if (realElemt != null)
        {
            var fieldcrud = felemt[i] + "_crud";
            var classElemt = realElemt.getAttribute("class"); // new
            
            // get data from real form element
            // and associate to form submit
            if (classElemt == "date") 
            {
                var selectdate = realElemt.getElementsByTagName("select");
                var day = selectdate[0].value;
                var month = selectdate[1].value;
                var year = selectdate[2].value;
                var date = year +"-"+ month +"-"+ day;
                fillcrudform(nameform, fieldcrud, date);
            }  
            else 
            {
                // restrictions
                if (checkRestrictions(realElemt)) {
                    if (realElemt.getAttribute("type") == "radio") {
                        realElemt = document.getElementsByName(realElemt.getAttribute("name"));
                        for (var j=0; j<realElemt.length; j++) {
                            if (realElemt[j].checked) {
                                var data = realElemt[j].value;
                                fillcrudform(nameform, fieldcrud, data);
                                break;
                            }
                        }
                    } else if (realElemt.getAttribute("type") == "checkbox") {
                        realElemt = document.getElementsByName(realElemt.getAttribute("name"));
                        var dataCheck = "";
                        for (var j=0; j<realElemt.length; j++) {
                            if (realElemt[j].checked) {
                                var data = realElemt[j].value;
                                if (dataCheck == "") {
                                    dataCheck = data;
                                } else {
                                    dataCheck += "," + data;
                                }
                            }
                        }
                        fillcrudform(nameform, fieldcrud, dataCheck);
                    } else {
                        var data = realElemt.value;
                        fillcrudform(nameform, fieldcrud, data);
                    }
                    //printCheckSuccess(realElemt);
                } else {
                    cleancrudform(nameform);
                    //printCheckError();
                    return;
                }
            }
        }
    }
    
    // check submit form
    var crudform = document.getElementById(nameform);
    var crudformc = crudform.getAttribute("class");
    var crudelemts = crudform.getElementsByTagName("input");
    
    if (crudformc == "delete-form")
    {
        for (var i=0; i<crudelemts.length; i++)
        {
            var velemt = crudelemts[i].value;
            var nelemt = crudelemts[i].getAttribute("name");
            
            if (velemt != null && nelemt != null && nelemt.indexOf("_del") < 0) {
                for (var j=0; j<crudelemts.length; j++) {
                    var size = nelemt.length;
                    var _crud = "_crud";
                    var csize = _crud.length;
                    var selemt = nelemt.substr(0,size-csize);
                    selemt += "_del_crud";
                    
                    var jelemt = crudelemts[j].getAttribute("name");
                    if (selemt == jelemt) {
                        crudelemts[j].value = "INV-" + velemt;
                    }
                }
            }
        }
    }
    
    crudform.submit();
}

function checkRestrictions(realElemt)
{
    var divparent = realElemt.parentNode;
    var category = divparent.getAttribute("class");
    
    var span = divparent.getElementsByTagName("span");
    span = span[0];
    var namefield = span.innerHTML;
    
    var chk = check_field(realElemt, category);
    
    if (chk) {
        printCheckSuccess(realElemt);
    } else {
        printCheckError(namefield);
    }
    
    return chk;
}

function fillcrudform(nameform, fieldcrud, data)
{
    // submit form
    var form = document.getElementById(nameform);
    var elemts = form.getElementsByTagName("input");
    
    for (var i=0; i<elemts.length; i++)
    {
        var nelemt = elemts[i].getAttribute("id");
        if (nelemt == fieldcrud)
        {
            elemts[i].value = data;
        }
    }
}

function cleancrudform(nameform)
{
    var form = document.getElementById(nameform);
    var elemts = form.getElementsByTagName("input");
    for (var i=0; i<elemts.length; i++) {
        var type = elemts[i].getAttribute("type");
        if (type == "hidden") {
            elemts[i].value = "";
        }
    }
}

function printCheckError(namefield) {
    var str = namefield +": Especificación de caracteres incorrectos.";
    document.getElementById("msgrest").innerHTML = str;
    document.getElementById("msgrest").style.display = "block";
}
function printCheckSuccess(realElemt) {
    realElemt.style.borderColor = "#dff2bf";
    //document.getElementById("msgrest").style.display = "none";    
}

function addelemt(nelemt)
{
    if (felemt == null) {
        felemt = new Array(1);
        felemt[0] = nelemt;
    } else {
        var size = felemt.length;
        var felemt_aux = new Array(size);
        for (var i=0; i<size; i++) {
            felemt_aux[i] = felemt[i];
        }
        felemt = new Array(size+1);
        for (var i=0; i<size; i++) {
            felemt[i] = felemt_aux[i];
        }
        felemt[i] = nelemt;
    }
}



function check_field(comp, category) {
    switch(category) {
        case 'numerico':
            if (/^-{0,1}[0-9]+$/.test(comp.value)) {
                return true;
            } else {
                return false;
            }
            break;
        case 'numericoReal':
            if (/^-{0,1}[0-9]*\.[0-9]+$/.test(comp.value)) {
                return true;
            } else {
                return false;
            }
            break;
        
        case 'alfabetico':
            if (/^[a-zA-Z\s]+$/.test(comp.value)) {
                return true;
            } else {
                return false;
            }
            break;
            
        case 'alfanumerico':
            if (/^[0-9a-zA-Z\s]+$/.test(comp.value)) {
                return true;
            } else {
                return false;
            }
            break;
        
        case 'alfanumerico_esp':
            if (/^[0-9a-zA-Z@#.,\/\-\s]+$/.test(comp.value)) {
                return true;
            } else {
                return false;
            }
            break;
            
        case 'booleano':
            if (comp.value == "true" ||
                comp.value == "false") {
                return true;
            } else {
                return false;
            }
            break;
                
        
        case 'email':
            if( !(/\w{1,}[@][\w\-]{1,}([.]([\w\-]{1,})){1,3}$/.test(comp.value)) ) {
                return false;
            } else {
                return true;
            }
            break;
    }
    return false;
}

