$(document).ready( function(){
var input_change = function(){$("input").change(function (){
  if ($(this).val() > 31) {
    $(this).css("background","red");
  } else {
    $(this).css("background","green");
    $(this).replaceWith("<p class='"+$(this).attr("class")+"'>"+$(this).val()+"</p>");
    input_change();
  };
  $("p.attr").click(function () {
    $(this).replaceWith("<input class='"+$(this).attr("class")+"' type='text' value='"+$(this).text()+"'>");
    input_change();
    $('input').focus();
  });
  });
};
$("p.attr").click(function () {
  $(this).replaceWith("<input class='"+$(this).attr("class")+"' type='text' value='"+$(this).text()+"'>");
  input_change();
  $('input').focus();
});
});