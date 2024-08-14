namespace :user do
  desc "Send due reminder emails to users"
  task due_reminder: :environment do
    User.due_reminder
  end
end
