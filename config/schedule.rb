every 1.day, :at => '12:30 am' do
  runner "Owner.deliver_scheduled_messages"
end
