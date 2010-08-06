$(document).ready(function(){
    function update_stat(name,value){
      $.post("/system/pokemon/"+$(".pokemon").attr("id")+"/edit",{m: name, v: value}, function(data){
        alert(data);
      });
    }

    function log(message) {
        $("<div/>").text(message).prependTo("#log");
        $("#log").attr("scrollTop", 0);
    }
    $("#pokemon").autocomplete({
        source: "/system/search/pokemon",
        minLength: 2,
        select: function(event, ui) {
            $("#pokemon").val(ui.item.name);
            update_stat("dex", ui.item.id);
            $("p.attr#dex").text("#"+ui.item.id);
            $("#picon").attr("src","/i/pokemon/"+ui.item.id+".png");
        },
        focus: function(event, ui) {
            $("#pokemon").val(ui.item.name);
            $("p.attr#dex").text("#"+ui.item.id);
            $("#picon").attr("src","/i/pokemon/"+ui.item.id+".png");
        }
    }).data("autocomplete")._renderItem = function(ul,item){
        return $("<li></li>")
            .data("item.autocomplete",item)
            .append("<img src='/i/pokemon/"+item.id+".png' height='40' width='40' style='float:left'><a style='float:left'>"+item.name+"</a>")
            .appendTo( ul )
    };
    var moves = $(".move");
    moves.each(function(){
    $(this).autocomplete({
        source: "/system/search/move",
        minLength: 2,
        select: function(event, ui) {
            $(this).val(ui.item.name);
            $.post("/system/pokemon/"+$(".pokemon").attr("id")+"/move",{n: $(this).attr("id"), v: ui.item.id}, function(data){
              alert(data);
            });
        },
        focus: function(event, ui) {
            $(this).val(ui.item.name);
        }
    }).data("autocomplete")._renderItem = function(ul,item){
        return $("<li></li>")
            .data("item.autocomplete",item)
            .append("<a style='float:left'>"+item.name+"</a>")
            .appendTo( ul )
    }
    });

$("#item").autocomplete({
        source: "/system/search/item",
        minLength: 2,
        select: function(event, ui) {
            $("#item").val(ui.item.name);
            update_stat("held",ui.item.id);
        },
        focus: function(event, ui) {
            $("#item").val(ui.item.name)
        }
    }).data("autocomplete")._renderItem = function(ul,item){
        return $("<li></li>")
            .data("item.autocomplete",item)
            .append("<a style='float:left'>"+item.name+"</a>")
            .appendTo( ul )
    };
});