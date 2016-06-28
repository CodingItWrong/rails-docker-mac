class TaskMailer < ApplicationMailer
  default from: "example@example.com", to: "example@example.com"

  def task_created_email
    mail(subject: "Task Created")
  end
end
