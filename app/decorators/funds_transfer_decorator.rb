class FundsTransferDecorator < ApplicationDecorator
  delegate_all
  
  def req_bitstream
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_req_bitstream_#{object.id}", 
      title: "request_message".humanize, 
      bitstream: object.audit_log.try(:request_bitstream), 
      ref_no: object.req_no,
      button: 'd_clip_button1',
      xml: 'req_xml'}
  end
  
  def rep_bitstream
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_rep_bitstream_#{object.id}", 
      title: "reply_message".humanize, 
      bitstream: object.audit_log.try(:reply_bitstream), 
      ref_no: (object.rep_no || 'Show'),
      button: 'd_clip_button2',
      xml: 'rep_xml'}
  end

  def reconciled_at
    object.reconciled_at.try(:strftime, "%d/%m/%Y %I:%M%p")
  end
    
  def address
    [:bene_address1, :bene_address2, :bene_address3, :bene_postal_code, :bene_city, :bene_state, :bene_country].each do |attr|
      a += object.send(attr)
    end
    a          
  end
  
  def transfer_amount
    h.number_to_currency(object.transfer_amount, unit: 'Rs ')
  end

  def status_code
    h.render partial: 'shared/status', locals: {id: "#{object.class.name.demodulize}_status_code_#{object.id}", object: object}
  end
  
  def picked_at
    object.picked_at.try(:strftime, "%d/%m/%Y %I:%M%p")
  end
  
  def notify_attempt_at
    object.notify_attempt_at.try(:strftime, "%d/%m/%Y %I:%M%p")
  end
  
  def notified_at
    object.notified_at.try(:strftime, "%d/%m/%Y %I:%M%p")
  end
  
  def steps
    h.link_to 'Show', h.send("steps_funds_transfer_path", object)
  end
  
  def ft_invoice_detail
    "test"
  end
end