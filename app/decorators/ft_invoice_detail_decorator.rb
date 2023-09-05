class FtInvoiceDetailDecorator < ApplicationDecorator
  delegate_all
  
  def req_bitstream
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_req_bitstream_#{object.id}", 
      title: "request_message".humanize, 
      bitstream: object.audit_log.request_bitstream, 
      ref_no: object.req_no,
      button: 'd_clip_button1',
      xml: 'req_xml'}
  end
  
  def rep_bitstream
    h.render partial: 'shared/bitstream', locals: {id: "#{object.class.name.demodulize}_rep_bitstream_#{object.id}", 
      title: "reply_message".humanize, 
      bitstream: object.audit_log.reply_bitstream, 
      ref_no: (object.rep_no || 'Show'),
      button: 'd_clip_button2',
      xml: 'rep_xml'}
  end

  def invoice_date
    object.invoice_date.try(:strftime, "%d/%m/%Y %I:%M%p")
  end
  
  def advice_sent_at
    object.advice_sent_at.try(:strftime, "%d/%m/%Y %I:%M%p")
  end

  def status_code
    h.render partial: 'shared/status', locals: {id: "#{object.class.name.demodulize}_status_code_#{object.id}", object: object}
  end

  def steps
    h.link_to 'Show', h.send("steps_ft_invoice_detail_path", object)
  end
end