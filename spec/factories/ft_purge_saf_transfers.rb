FactoryGirl.define do
  factory :ft_purge_saf_transfer do
    sequence(:reference_no) {|n| "#{n}" }
    from_req_timestamp Time.now
    to_req_timestamp Time.now
  end
end
