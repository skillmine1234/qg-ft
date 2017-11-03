class FundsTransferPolicy < DataAccessPolicy
  def notifications?
    show?
  end
end