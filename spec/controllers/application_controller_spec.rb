require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    # Controller para fins de teste
    def index
      render plain: "Hello World"
    end
  end

  describe "before actions" do
    context "when devise controller" do
      before do
        allow(controller).to receive(:devise_controller?).and_return(true)
      end

      it "permits additional parameters for sign up" do
        expect(controller).to receive(:configure_permitted_parameters)
        get :index
      end
    end

    context "when not devise controller" do
      before do
        allow(controller).to receive(:devise_controller?).and_return(false)
      end

      it "does not call configure_permitted_parameters" do
        expect(controller).not_to receive(:configure_permitted_parameters)
        get :index
      end
    end

    context "user authentication" do
      it "authenticates the user before any action" do
        expect(controller).to receive(:authenticate_user!)
        get :index
      end
    end
  end
end
