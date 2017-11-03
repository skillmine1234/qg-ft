$(document).ready(function(){
  $(".request-link").on("click", function () {
    var request = $(this).data('request');
    display_beautified_data(request, ".request", "#requestText");
  });

  $(".reply-link").on("click", function () {
    var reply = $(this).data('reply');
    display_beautified_data(reply, ".reply", "#replyText");
  });
  
  function display_beautified_data(string, html_ele, modal){
    var xml_result = beautify_xml(string);
    $(html_ele).text("");
    if (xml_result != 'xml_parse_err') {
      $(html_ele).text(xml_result);  
    }
    else {
      var json_result = beautify_json(string);
      if (json_result != 'json_parse_err') {
        $(html_ele).text(json_result);  
      }
    }
    $(modal).modal();
  }
});