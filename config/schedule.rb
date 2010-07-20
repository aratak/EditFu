every 1.day, :at => '12:30 am' do
  runner "Owner.deliver_scheduled_messages"
  runner "Owner.deliver_next_week_report"
end

