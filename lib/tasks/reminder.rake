namespace :questions do
  desc <<-DESC
Sends reminder emails to users with open questions.

DESC
  task :reminder => :environment do
    QuestionMailer.question_reminders
  end
end
