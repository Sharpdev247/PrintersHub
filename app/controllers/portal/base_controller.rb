class Portal::BaseController < ApplicationController
  include AccountScoped

  layout "portal"
end
