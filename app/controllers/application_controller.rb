class ApplicationController < ActionController::Base
  include ApplicationSecurity
  include SetupEnvironment
  include SetCurrentRequestDetails
  include ExceptionHandlers
  include Authorization
  include NavbarSetup
end
