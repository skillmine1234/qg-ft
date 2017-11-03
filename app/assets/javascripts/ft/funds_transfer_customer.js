$(document).ready(function(){

  $('#funds_transfer_customer_allowed_relns').multiselect({selectedList: 6});
  
  var mandatory_mark = '*';
  if($('#funds_transfer_customer_use_std_relns').attr('checked')){
    $('#funds_transfer_customer_allowed_relns').val('');
    $('#funds_transfer_customer_allowed_relns').multiselect('disable');
    $("#funds_transfer_customer_allowed_relns").prop('required',false);
    $("#allowed_relns_lbl").text($("#allowed_relns_lbl").text().replace(mandatory_mark,'')); 
  }
  else{
    $('#funds_transfer_customer_allowed_relns').multiselect('enable');
    $("#funds_transfer_customer_allowed_relns").prop('required',true);
    $("#allowed_relns_lbl").text(mandatory_mark + $("#allowed_relns_lbl").text().replace(/\*/g, ''));
  }

  $("#funds_transfer_customer_use_std_relns").on("click", function () {
    if ($(this).attr('checked')){
      $('#funds_transfer_customer_allowed_relns').val('');
      $('#funds_transfer_customer_allowed_relns').multiselect('disable');
      $('#funds_transfer_customer_allowed_relns').multiselect('refresh');
      $("#funds_transfer_customer_allowed_relns").prop('required',false);
      $("#allowed_relns_lbl").text($("#allowed_relns_lbl").text().replace(mandatory_mark,'')); 
    }
    else{
      $('#funds_transfer_customer_allowed_relns').multiselect('enable');
      $("#funds_transfer_customer_allowed_relns").prop('required',true);
      if (!$("#funds_transfer_customer_is_retail").attr('checked')){
        $('#funds_transfer_customer_allowed_relns').multiselect('checkAll',true);
        $('#funds_transfer_customer_allowed_relns').multiselect('refresh');
      }
      else{
        $('#funds_transfer_customer_allowed_relns').multiselect('checkAll',true);
        $('#funds_transfer_customer_allowed_relns').find("option[value=AUS]").removeAttr("selected");
        $('#funds_transfer_customer_allowed_relns').multiselect('refresh');
      }
      $("#allowed_relns_lbl").text(mandatory_mark + $("#allowed_relns_lbl").text().replace(/\*/g, ''));
    }
  });
	
  if(!$('#funds_transfer_customer_allow_imps').attr('checked')){
		$('#funds_transfer_customer_mmid').val('');
    $('#funds_transfer_customer_mmid').prop('disabled',true);
  }
	else {
		$('#funds_transfer_customer_mmid').prop('disabled',false);
	}

  $("#funds_transfer_customer_allow_imps").on("click", function () {
    if (!$(this).attr('checked')){
      $('#funds_transfer_customer_mmid').val('');
      $('#funds_transfer_customer_mmid').prop('disabled',true);
    }
    else{
      $('#funds_transfer_customer_mmid').prop('disabled',false);      
    }
  });

  $("#funds_transfer_customer_is_retail").on("click", function () {
    if ($(this).attr('checked')){
      $('#funds_transfer_customer_customer_id').val('');
      $('#funds_transfer_customer_customer_id').prop('disabled',true);
    }
    else{
      $('#funds_transfer_customer_customer_id').prop('disabled',false);      
    }
  });
  
  if(!$('#funds_transfer_customer_allow_apbs').is(":checked")){
		$('#funds_transfer_customer_apbs_user_no').val('');
    $('#funds_transfer_customer_apbs_user_no').prop('readOnly',true);
		$('#funds_transfer_customer_apbs_user_name').val('');
    $('#funds_transfer_customer_apbs_user_name').prop('readOnly',true);
  }
	else {
		$('#funds_transfer_customer_apbs_user_no').prop('readOnly',false);
    $('#funds_transfer_customer_apbs_user_name').prop('readOnly',false);
	}

  $("#funds_transfer_customer_allow_apbs").on("click", function () {
    if (!$(this).is(":checked")){
  		$('#funds_transfer_customer_apbs_user_no').val('');
      $('#funds_transfer_customer_apbs_user_no').prop('readOnly',true);
  		$('#funds_transfer_customer_apbs_user_name').val('');
      $('#funds_transfer_customer_apbs_user_name').prop('readOnly',true);
    }
  	else {
  		$('#funds_transfer_customer_apbs_user_no').prop('readOnly',false);
      $('#funds_transfer_customer_apbs_user_name').prop('readOnly',false);   
    }
  });
	
  $('#funds_transfer_customer_form').bind('submit', function() {
      $(this).find(':input').removeAttr('disabled');
  });

  if ($("#funds_transfer_customer_notify_on_status_change").attr('checked')) {
    toggle_required_fields('Y');
  }
  else {
    toggle_required_fields('N'); 
  }

  $("#funds_transfer_customer_notify_on_status_change").on("change",function(){
    if ($(this).attr('checked')) {
      toggle_required_fields('Y');
    } 
    else {
      toggle_required_fields('N'); 
    }
  });

  function toggle_required_fields(notify_on_status_change){
    var mandatory_mark = "*";
    if (notify_on_status_change == 'Y') {
      $("#funds_transfer_customer_notify_app_code").prop('required',true);
      $("#notify_app_code_lbl").text(mandatory_mark + $("#notify_app_code_lbl").text().replace(/\*/g, ''));
    }
    else {
      $("#funds_transfer_customer_notify_app_code").prop('required',false);
      $("#notify_app_code_lbl").text($("#notify_app_code_lbl").text().replace(mandatory_mark,''));
    }
  }

});