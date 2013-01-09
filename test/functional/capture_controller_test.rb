require 'test_helper'

class CaptureControllerTest < ActionController::TestCase
  test "should get image_capture" do
    get :image_capture
    assert_response :success
  end

end
