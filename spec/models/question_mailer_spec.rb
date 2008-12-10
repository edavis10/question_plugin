require File.dirname(__FILE__) + '/../spec_helper'

describe QuestionMailer do
  it 'should be a subclass of Redmines Mailer' do
    QuestionMailer.ancestors.should include(Mailer)
  end
end

describe QuestionMailer, '#asked_question' do
  it 'should create a mail message' do
    mail = QuestionMailer.create_asked_question
    mail.should be_an_instance_of(TMail::Mail)
  end
  
  it 'should have the prefix of [Question]'
  it 'should be sent to the assigned_to user'
  it 'should not be sent to the anyone user'
end
