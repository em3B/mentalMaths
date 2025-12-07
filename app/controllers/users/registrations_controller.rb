class Users::RegistrationsController < Devise::RegistrationsController
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?

    if resource.persisted?
      sign_in(resource)  # important so PaymentsController can access current_user
      redirect_to edit_payment_method_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
end
