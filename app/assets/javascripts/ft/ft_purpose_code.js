$(document).ready(function(){

  if($('#ft_purpose_code_allowed_transfer_types').val() == 'APBS'){
    $('#ft_purpose_code_allow_only_registered_bene').prop("checked",false);
      $('#ft_purpose_code_allow_only_registered_bene').prop('disabled',true);
    }
  else {
    $('#ft_purpose_code_allow_only_registered_bene').prop('disabled',false);
  }

  $("#ft_purpose_code_allowed_transfer_types").on("change", function () {
    if ($(this).val() == 'APBS'){
      $('#ft_purpose_code_allow_only_registered_bene').prop("checked",false);
      $('#ft_purpose_code_allow_only_registered_bene').prop('disabled',true);
    }
    else {
      $('#ft_purpose_code_allow_only_registered_bene').prop('disabled',false);
    }
  });

  if($('#ft_purpose_code_is_frozen').val() == 'Y'){
    $('#ft_purpose_code_code').prop('readonly',true);
    $('#ft_purpose_code_allow_only_registered_bene').prop('disabled',true);
    $('#ft_purpose_code_allowed_transfer_types').prop('disabled',true);
  }
  
  $('#ft_purpose_code_form').bind('submit', function() {
    $(this).find(':input').removeAttr('disabled');
  });

  $('#ft_purpose_code_allowed_transfer_types').multiselect({selectedList: 4});
});