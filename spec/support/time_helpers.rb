# 日付を固定してテストするため（travel_to など）
RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
end
