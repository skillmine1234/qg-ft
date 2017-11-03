class FtAuditStepDecorator < ApplicationDecorator

  delegate_all

  def step_name
    h.render partial: 'shared/backend', locals: {id: "#{object.class.name.demodulize}_status_code_#{object.id}", object: object}
  end

  def req_reference
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_req_bitstream_#{object.id}", 
      title: "request_message".humanize, 
      bitstream: object.req_bitstream, 
      ref_no: object.req_reference}
  end

  def rep_reference
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_rep_bitstream_#{object.id}", 
      title: "reply_message".humanize, 
      bitstream: object.rep_bitstream, 
      ref_no: (object.rep_reference || 'show')}
  end

  def status_code
    h.render partial: 'shared/status', locals: {id: "#{object.class.name.demodulize}_status_code_#{object.id}", object: object}
  end

end
