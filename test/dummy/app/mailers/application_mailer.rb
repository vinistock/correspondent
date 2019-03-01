class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def purchase_email(purchase)
    @purchase = purchase
    mail(to: purchase.user.email, subject: purchase.name)
  end

  def refund_email(purchase)
    @purchase = purchase
    mail(to: purchase.user.email, subject: purchase.name)
  end
end
