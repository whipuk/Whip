class RegistrationsController < Devise::RegistrationsController

	 # POST /resource
	def create
		build_resource(sign_up_params)
		resource.name = params[:name]
		resource.save
		yield resource if block_given?
		if resource.persisted?
			if resource.active_for_authentication?
				set_flash_message :notice, :signed_up if is_flashing_format?
				sign_up(resource_name, resource)
				respond_with resource, location: edit_user_path(resource)
			else
				set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
				expire_data_after_sign_in!
				respond_with resource, location: after_inactive_sign_up_path_for(resource)
			end
		else
			clean_up_passwords resource
			set_minimum_password_length
			respond_with resource
		end
	end

end