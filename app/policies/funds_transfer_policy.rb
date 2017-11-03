class FundsTransferPolicy < DataAccessPolicy
  def steps?
    show?
  end
end