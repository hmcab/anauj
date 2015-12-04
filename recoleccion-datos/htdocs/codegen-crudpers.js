
lstval = null;
lstmat = null;
cpidx = -1;

// Campos INSERT
function getInsertValues()
{
    var sqlv = document.getElementById("lsql").value;
    var lcampos = document.getElementById("lcampos");
    
    var first, last;
    first = last = -1;
    
    first = sqlv.indexOf("(");
    last = sqlv.indexOf(")");
    
    if (first >= 0 && last >= 0)
    {
        var data = sqlv.substring(first+1,last);
        lcampos.innerHTML = data;
    } else {
        lcampos.innerHTML = "";
    }
}

function getSelectValues()
{
    var sqlv = document.getElementById("lsql").value;
    var lcampos = document.getElementById("lcampos");
    var lrest = document.getElementById("lrest");
    
    var first, last, selectlen=7, wherelen=6;
    first = last = -1;
    
    first = sqlv.indexOf("select ") + selectlen;
    last  = sqlv.indexOf(" from");
    
    if (first >= 0 && last >= 0)
    {
        var data = sqlv.substring(first,last);
        lcampos.innerHTML = data;
    } else {
        lcampos.innerHTML = "";
    }
    
    if (sqlv.indexOf("where ") > 0)
    {
        var whereinic = sqlv.indexOf("where ");
        var afterwhere = sqlv.substring(whereinic + wherelen, sqlv.length);
        var rests = getSelectRest(afterwhere);
        lrest.innerHTML = rests;
    } else {
        lrest.innerHTML = "";
    }
}

function getUpdateValues()
{
    var sqlv    = document.getElementById("lsql").value;
    var lcampos = document.getElementById("lcampos");
    var lrest   = document.getElementById("lrest");
    
    var first, last, setlen=4, wherelen=6;
    first = last = -1;
    
    first = sqlv.indexOf("set ") + setlen;
    last = sqlv.indexOf(" where");
    
    if (first >= 0 && last >= 0)
    {
        var data = sqlv.substring(first,last);
        data = getUpdateRest(data);
        lcampos.innerHTML = data;
    } else {
        lcampos.innerHTML = "";
    }
    
    if (sqlv.indexOf("where ") > 0)
    {
        var whereinic = sqlv.indexOf("where ");
        var afterwhere = sqlv.substring(whereinic + wherelen, sqlv.length);
        var rests = getUpdateRest(afterwhere);
        lrest.innerHTML = rests;
    } else {
        lrest.innerHTML = "";
    }
}

function getDeleteValues()
{
    var sqlv    = document.getElementById("lsql").value;
    var lcampos = document.getElementById("lcampos");
    var lrest   = document.getElementById("lrest");
    
    var first = sqlv.indexOf("from ");
    var last  = sqlv.indexOf(" where");
    var fromlen  = 5;
    var wherelen = 6;
    var nomtable = sqlv.substring(first+fromlen,last);
    
    if (first >= 0 && last >= 0 && /^\s*[a-zA-Z\.]+\s*$/.test(nomtable) &&
        sqlv.indexOf("where ") > 0)
    {
        var whereinic = sqlv.indexOf("where ");
        var afterwhere = sqlv.substring(whereinic + wherelen, sqlv.length);
        var rests = getDeleteRest(afterwhere);
        lcampos.innerHTML = nomtable;
        lrest.innerHTML = rests;
        
    } else {
        lcampos.innerHTML = "";
        lrest.innerHTML = "";
    }
}

function getDeleteRest(rests)
{
    return getSelectRest(rests);    
}

function getSelectRest(rests)
{
    rests = rests.replace(/\(/g,"");
    rests = rests.replace(/\)/g,"");
    rests = rests.replace(/=/g,"");
    rests = rests.replace(/\$/g,"");
    rests = rests.replace(/[0-9]*/g,"");
    //rests = rests.replace(/=\$[0-9]*/g,"");
    rests = rests.replace(/\s+AND\s*/g,",");
    rests = rests.replace(/\s+OR\s*/g,",");
    
    rests = rests.replace(/\s+and\s*/g,",");
    rests = rests.replace(/\s+or\s*/g,",");
    
    rests = rests.replace(/\'[a-zA-z0-9\-\/]*\'/g,"");
    
    return rests;
}

function getUpdateRest(rests)
{
    rests = rests.replace(/\(/g,"");
    rests = rests.replace(/\)/g,"");
    rests = rests.replace(/=/g,"");
    rests = rests.replace(/\$/g,"");
    rests = rests.replace(/[0-9]*/g,"");
    //rests = rests.replace(/=\$[0-9]*/g,"");
    rests = rests.replace(/\s+AND\s*/g,",");
    rests = rests.replace(/\s+OR\s*/g,",");
    
    rests = rests.replace(/\s+and\s*/g,",");
    rests = rests.replace(/\s+or\s*/g,",");
    
    rests = rests.replace(/\'[a-zA-z0-9\-\/]*\'/g,"");
    return rests;
}

function cargarValoresCrud()
{
    var campos = document.getElementById("lst_campos").value;
    var funcs = document.getElementById("lst_sql").value;
    
    var lstcam = campos.split(",");
    var lstfun = funcs.split(",");
    
    lstval = lstcam.concat(lstfun);
}

function getKeyCode(event)
{
    var evt = event || window.event;
    var keycode = evt.charCode || evt.keyCode;
    return keycode;
}

function getMatches(p)
{
    var smatch = "";
    for (var i=0; i<lstval.length; i++)
    {
        var val = lstval[i];
        if (val.indexOf(p) >= 0)
        {
            if (smatch == "")
                smatch = val;
            else
                smatch += "," + val;
        }
    }
    
    if (smatch != "") {
        lstmat = smatch.split(",");
    } else {
        lstmat = null;
    }
    
    document.getElementById("lstmatch").innerHTML = smatch;
}

function getNextMatch()
{
    if (lstmat != null && lstmat.length > 0)
    {
        var size = lstmat.length;
        
        cpidx += 1;
        if (cpidx >= 0 && cpidx < size)
            return lstmat[cpidx];
        else {
            cpidx = -1;
            return lstmat[0];
        }
    }
    
    return null;
}

var patron = "";
var patronPos = -1;

function crearPatron(event)
{
    var sqlElemt = document.getElementById("lsql");
    var lcampos  = document.getElementById("lcampos");
    var lrest    = document.getElementById("lrest");
    var fsql_per = document.getElementById("fsql_per");
    var keycode  = getKeyCode(event);
    //alert(keycode);
    
    // 32       espacio
    // 9        tab
    // 8        return
    // 13       enter
    // 97-122   a-z
    // 65-90    A-Z
    // 44       ,
    
    if (keycode >= 65 && keycode <= 90 ||
        keycode >= 97 && keycode <= 122)
        {
            if (patron == "")
                patronPos = sqlElemt.selectionStart;
                
            patron += String.fromCharCode(keycode);
            getMatches(patron);
        }
    else if (keycode == 9)
        {
            match = getNextMatch();
            if (patronPos >= 0 && match != null)
            {
                var newvalue =
                    sqlElemt.value.substring(0,patronPos) 
                        + match +
                    sqlElemt.value.substring((patronPos + patron.length),sqlElemt.value.length);
            
                sqlElemt.value = newvalue;
                sqlElemt.selectionStart = sqlElemt.selectionEnd = (patronPos + match.length);
                patron = match;
            }
            
            event.preventDefault();
        }
    else if (keycode == 44 || keycode == 32 || keycode == 8)
        {
            patron = "";
            patronPos = -1;
            lstmat = null;
        }
    
    if (sqlElemt.value.indexOf("insert into") >= 0)
    {
        fsql_per.value = "INSERT";
        getInsertValues(); 
        
    } else if (sqlElemt.value.indexOf("select") >= 0)
    {
        fsql_per.value = "SELECT";
        getSelectValues(); 
        
    } else if (sqlElemt.value.indexOf("update") >= 0)
    {
        fsql_per.value = "UPDATE";
        getUpdateValues();
         
    } else if (sqlElemt.value.indexOf("delete") >= 0)
    {
        fsql_per.value = "DELETE";
        getDeleteValues();
    }
}

function init_crudpers()
{
    cargarValoresCrud();
    var sql = document.getElementById("lsql");
    sql.addEventListener("keypress",crearPatron);
}
