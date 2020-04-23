class UpdateUser
  attr_accessor :user, :organisation, :current_user

  def initialize(user:, organisation:, current_user:)
    self.user = user
    self.organisation = organisation
    self.current_user = current_user
  end

  def call
    result = Result.new(true)

    User.transaction do
      user.organisation = organisation

      begin
        UpdateUserInAuth0.new(user: user).call
      rescue Auth0::Exception => e
        result.success = false
        Rails.logger.error("Error updating user #{user.email} to Auth0 during UpdateUser with #{e.message}.")
        raise ActiveRecord::Rollback
      end

      user.changed_attributes&.each do |key, value|
        user.create_activity key: "user.update.#{key}", owner: current_user
      end

      user.save
    end

    result
  end
end
