class BackupControllerController < ApplicationController

  def download_backup
    if !logged_in?
      access_denied
      return
    end
    
    #make sure that we're storing who is downloading, to be able to cut off unreasonable reqs
    RAILS_DEFAULT_LOGGER.info("Backup of db being download by: " + current_user.identity_url)
    
    #@response.headers["Content-Type"] = 'text/plain'
    
    backup_location = AppPref.find_by_pref_key('backup_location').pref_val
    
    render :file => backup_location, :content_type => 'application/x-compressed'
    
  end

end
