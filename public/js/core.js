/***************************/
//@Author: Adrian "yEnS" Mato Gondelle & Ivan Guardado Castro
//@website: www.yensdesign.com
//@email: yensamg@gmail.com
//@license: Feel free to use it, but keep this credits please!					
/***************************/

//OS elements
var main = $("#main");
var taskbar = $("#taskbar");
var clock = $("#clock");
var trash = $("#trash");
var icons = $(".icon");
var bill = $("#bill");
var upload = $("#upload");
var Page = new page();
//Mouse status
var mouseDiffY = 0;
var mouseDiffX = 0;
var mouseActiveIcon = 0;
var mouseActiveCloneIcon = 0;

function page() {
  this.forms = new Object();
  this.forms["upload"] = new form("Upload Pokemon", null, "openPKM();");
  this.forms["login"] = new form("Login", null, "loadUserBox();");
  this.dialog = null;
};

function form(title, validate, callback) {
  this.title = title;
  this.validate = function () {
    return eval(validate);
  };
  this.callback = function () {
    eval(callback)
  };
};

function open_form(name, id) {
  var form = Page.forms[name];
  form.name = name;
  if (id != null) {
    form.oid = id;
    form.url = "/form/" + name + "/" + id;
  } else if (id == null) {
    form.url = "/form/" + name;
  }
  boxyform(form);
};

function boxyform(form) {
  dialog = Page.dialog;
  if (dialog != null) {
    dialog.show();
    return true;
  } else if (dialog == null) {
    dialog = new Boxy(null, {
      title: form.title,
      show: false,
      closable: true,
      hideFade: true,
      hideShrink: false,
      FadeIn: true,
      afterHide: function (d) {
        dialog.unload();
        dialog = null;
      },
      behaviours: function (d) {
        d.find("form").submit(function () {
          if (form.validate != null) {
            if (form.validate() == false) {
              return false;
            }
          }
          dialog.setContent("<div style = \"min-width:100px; min-height:50px; margin:auto; padding-top: 40px; text-align:center\">Sending...</div>");
          $.post("/api/" + form.name, d.find("form").serialize(), function (data) {
            form.callback();
            dialog.setContent("<div style = \"min-width:100px; min-height:50px; margin:auto; padding-top: 40px; text-align:center\">Sent</div>");
            dialog.hideAndUnload();
          });
          return false;
        });
      }
    });
    dialog.setContent("<div style = \"min-width:100px; min-height:50px; text-align:right;\"><form id =\"" + form.name + "\"></form></div>");
    form.elem = $("form");
    form.elem.load(form.url, function () {
      dialog.show();
      form.elem.find("textarea:first").focus();
      dialog.center();
    });
  };
}

//update clock function
function updateClock(){
	var now = new Date();
	var hour = now.getHours();
	if(hour < 10) hour = "0" + hour;
    var mins = now.getMinutes();
	if(mins < 10) mins = "0" + mins;
    var secs = now.getSeconds();
	if(secs < 10) secs = "0" + secs;
	//print the current time in the clock division
	clock.html(hour + " : " + mins + " : " + secs);
	//recursive call
    setTimeout("updateClock()", 1000);
}

$(document).ready(function(){
	//cancel context menu
	$(document).bind("contextmenu",function(e){
		return false;
	});
	
	//show icons
	trash.css({'top':(main.height()) - (128 + taskbar.height()), 'left':main.width() - 128});
	icons.fadeIn(1500);
	taskbar.slideDown();
	
	//show current time
	updateClock();
	
	//mouse click
	icons.mousedown(function(e){
		//only accepts left click; all navs uses 0 but IE uses 1 lol...
		if(e.button <= 1){
			//calculate differences when user clicks the icon
			mouseDiffY = e.pageY - this.offsetTop;
			mouseDiffX = e.pageX - this.offsetLeft;
			if(mouseActiveIcon !=0){
				mouseActiveIcon.removeClass("active");
			}
			mouseActiveIcon = $(this);
			mouseActiveCloneIcon = mouseActiveIcon.clone(false).insertBefore(mouseActiveIcon);
		}
	});
	
	//moving mouse
	$(document).mousemove(function(e){
		if(mouseActiveIcon){
			//update position
			mouseActiveIcon.css({"top":e.pageY - mouseDiffY, "left":e.pageX - mouseDiffX, "opacity":0.35});
			var restaY = e.pageY - $(this).css("top");
			var restaX = e.pageX - $(this).css("left");
		}
	});
	
	//release mouse click
	$(document).mouseup(function(){
		if(mouseActiveIcon != 0){
			mouseActiveIcon.css({"opacity":1.0});
			mouseActiveIcon = 0;
			mouseActiveCloneIcon.remove();
			mouseActiveCloneIcon = 0;
		}
	});
	
	//mouse double click
	icons.dblclick(function(){
		
	});

        bill.dblclick(function(){
          open_window("bill");
        });

        upload.dblclick(function(){
            open_form("upload");
        });
	
	//custom context menu on right click
	main.mousedown(function(e){
		if(e.button == 2){
			alert("context menu");
		}
	});

});