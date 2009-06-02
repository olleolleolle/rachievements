# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
    helper :all # include all helpers, all the time
    include ExceptionNotifiable

    layout "main"

    # See ActionController::RequestForgeryProtection for details
    # Uncomment the :secret if you're not using the cookie session store
    protect_from_forgery # :secret => '299a579a0d5c0a27f1777564a5f4e04e'

    protected

    def render_404
        render :template => "shared/404", :status => 404
        return false
    end

    def realm_from_params
        @realm = Realm.find_by_region_and_urltoken( params[:region], params[:realm] )
        if @realm.nil?
            return render_404
        end
        return true
    end

end
