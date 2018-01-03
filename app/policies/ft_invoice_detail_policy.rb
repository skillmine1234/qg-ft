class FtInvoiceDetailPolicy < DataAccessPolicy
  def steps?
    show?
  end
end