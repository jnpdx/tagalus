require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TagsController do

  it "should load the front page" do
    get :index
  end
end
