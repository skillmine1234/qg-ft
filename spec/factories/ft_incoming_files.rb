# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ft_incoming_file do
    file_name {Factory(:incoming_file).file_name}
    customer_code "12345"
  end
end