# NOTE: Encryption keys are now configured in config/application.rb
# (Rails 8.1 requires this — initializers run too late for encryption setup).

# Password complexity requirements
module Devise
  module Models
    module Validatable
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end
    end
  end
end

# Custom password validator for strong passwords
class StrongPasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?
    unless value.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}\z/)
      record.errors.add(attribute, :weak_password,
        message: "must include at least one uppercase letter, one lowercase letter, one number, and one special character")
    end
  end
end
