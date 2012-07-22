class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper
  include GamesHelper
  include ApplicationHelper
end
