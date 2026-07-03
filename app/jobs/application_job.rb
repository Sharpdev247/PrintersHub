class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::Deadlocked, attempts: 3, wait: :polynomially_longer
  discard_on ActiveJob::DeserializationError

  # Set Current context so audited writes inside jobs attribute correctly.
  # Subclasses pass account_id: and user_id: when enqueuing:
  #   MyJob.perform_later(record, account_id: account.id, user_id: user.id)
  before_perform do |job|
    opts = job.arguments.last.is_a?(Hash) ? job.arguments.last : {}

    Current.account = Account.find_by(id: opts[:account_id]) if opts[:account_id]
    Current.user    = User.find_by(id: opts[:user_id])        if opts[:user_id]

    Audited.store[:current_user] = Current.user || User.find_by(email: "system@printershub.internal")
  end
end
